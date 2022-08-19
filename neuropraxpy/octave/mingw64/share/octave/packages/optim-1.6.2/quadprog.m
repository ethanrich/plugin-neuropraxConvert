## Copyright (C) 2015 Asma Afzal
## Copyright (C) 2013-2015 Julien Bect
## Copyright (C) 2000-2015 Gabriele Pannocchia
##
## Octave is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or (at
## your option) any later version.
##
## Octave is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
## General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with Octave; see the file COPYING.  If not, see
## <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} {} quadprog (@var{H}, @var{f})
## @deftypefnx {Function File} {} quadprog (@var{H}, @var{f}, @var{A}, @var{b})
## @deftypefnx {Function File} {} quadprog (@var{H}, @var{f}, @var{A}, @var{b}, @var{Aeq}, @var{beq})
## @deftypefnx {Function File} {} quadprog (@var{H}, @var{f}, @var{A}, @var{b}, @var{Aeq}, @var{beq}, @var{lb}, @var{ub})
## @deftypefnx {Function File} {} quadprog (@var{H}, @var{f}, @var{A}, @var{b}, @var{Aeq}, @var{beq}, @var{lb}, @var{ub}, @var{x0})
## @deftypefnx {Function File} {} quadprog (@var{H}, @var{f}, @var{A}, @var{b}, @var{Aeq}, @var{beq}, @var{lb}, @var{ub}, @var{x0}, @var{options})
## @deftypefnx {Function File} {[@var{x}, @var{fval}, @var{exitflag}, @var{output}, @var{lambda}] =} quadprog (@dots{})
## Solve the quadratic program
## @example
## @group
## min 0.5 x'*H*x + x'*f
##  x
## @end group
## @end example
## subject to
## @example
## @group
## @var{A}*@var{x} <= @var{b},
## @var{Aeq}*@var{x} = @var{beq},
## @var{lb} <= @var{x} <= @var{ub}.
## @end group
## @end example
##
## The initial guess @var{x0} and the constraint arguments (@var{A} and
## @var{b}, @var{Aeq} and @var{beq}, @var{lb} and @var{ub}) can be set to
## the empty matrix (@code{[]}) if not given.  If the initial guess
## @var{x0} is feasible the algorithm is faster.
##
## @var{options} can be set with @code{optimset}, currently the only
## option is @code{MaxIter}, the maximum number of iterations (default:
## 200).
##
## Returned values:
##
## @table @var
## @item x
## Position of minimum.
##
## @item fval
## Value at the minimum.
##
## @item exitflag
## Status of solution:
##
## @table @code
## @item 0
## Maximum number of iterations reached.
##
## @item -2
## The problem is infeasible.
##
## @item -3
## The problem is not convex and unbounded
##
## @item 1
## Global solution found.
##
## @item 4
## Local solution found.
## @end table
##
## @item output
## Structure with additional information, currently the only field is
## @code{iterations}, the number of used iterations.
##
## @item lambda
## Structure containing Lagrange multipliers corresponding to the
## constraints. For equality constraints, the sign of the multipliers
## is chosen to satisfy the equation
## @example
## 0.5 H * x + f + A' * lambda_inequ + Aeq' * lambda_equ = 0 .
## @end example
## If lower and upper bounds are equal, or so close to each other that
## they are considered equal by the algorithm, only one of these
## bounds is considered active when computing the solution, and a
## positive lambda will be placed only at this bound.
##
## @end table
##
## This function calls Octave's @code{__qp__} back-end algorithm internally.
## @end deftypefn

## PKG_ADD: [~] = __all_opts__ ("quadprog");

## adapted from Octaves qp.m with enhanced handling of lambda by Asma
## Afzal <asmaafzal5@gmail.com>
##
## modified by Olaf Till <i7tiol@t-online.de>

function varargout = quadprog (H, f, varargin)

  if (nargin == 1 && ischar (H) && strcmp (H, "defaults"))
    varargout{1} = optimset ("MaxIter", 200);
    return;
  endif

  maxnargs = 10;

  nargs = nargin ();
  nout = nargout ();

  ## disallow, among others, incomplete pairs (matrix and vector) of
  ## constraint arguments, but allow giving only lower bounds, since
  ## specifying an empty matrix for upper bounds is allowed anyway
  if (nargs < 2 || nargs == 3 || nargs == 5 || nargs > maxnargs)
    print_usage();
  endif

  fname = "quadprog";

  allargin = horzcat (varargin, cell (1, maxnargs - nargs));

  [Ain, bin, Aeq, beq, lb, ub, x0, options] = allargin{:};

  if (isempty (options))
    options = struct ();
  elseif (! isstruct (options))
    error ("%s: options must be empty or a structure", fname);
  endif

  maxit = optimget (options, "MaxIter", 200);

  ## Checking the quadratic penalty
  if (! issquare (H))
    error ("%s: quadratic penalty matrix not square", fname);
  elseif (! ishermitian (H))
    ## warning ("quadratic penalty matrix not hermitian");
    H = (H + H')/2;
  endif
  n = rows (H);

  ## Checking linear penalty (if empty it is resized to the right
  ## dimension and filled with 0).
  f = check_vector (f, n, fname, "linear penalty");

  ## Checking the initial guess (if empty it is resized to the right
  ## dimension and filled with 0).
  x0 = check_vector (x0, n, fname, "initial guess");

  lambda = struct ("lower", [], "upper", [], "eqlin", [], "ineqlin", []);

  ## Equality constraint matrices
  if (isempty (Aeq) && isempty (beq))
    Aeq = zeros (0, n);
    beq = zeros (0, 1);
    n_eq = 0;
  else
    [n_eq, n1] = size (Aeq);
    if (n1 != n)
      error ("%s: equality constraint matrix has incorrect column dimension",
             fname);
    endif
    if (! isvector (beq) || numel (beq) != n_eq)
      error ("%s: equality constraint matrix and vector have inconsistent dimensions",
             fname);
    endif
    beq = beq(:);
  endif

  ## Inequality constraint matrices
  if (isempty (Ain) && isempty (bin))
    Ain = zeros (0, n);
    bin = zeros (0, 1);
  else
    [n_in, n1] = size (Ain);
    if (n1 != n)
      error ("%s: inequality constraint matrix has incorrect column dimension",
             fname);
    endif
    if (! isvector (bin) || numel (bin) != n_in)
      error ("%s: inequality constraint matrix and vector have inconsistent dimensions",
             fname);
    endif
    ## change from quadprog- to __qp__-conventions
    Ain = -Ain;
    bin = -bin;
    ##
    idx_ineq = isinf (bin) & bin < 0;
    ## Discard inequality constraints that have -Inf bounds since those
    ## will never be active but keep the index for ordering of lambda.
    bin(idx_ineq) = [];
    Ain(idx_ineq, :) = [];
  endif

  ## Bound constraints
  ##
  ## Discard lower bounds of -inf and upper bounds of +inf since those
  ## will never be active.
  if (! isempty (lb))
    if (! isvector (lb) || numel (lb) != n)
      error ("%s: lower bounds have incorrect dimensions", fname);
    elseif (isempty (ub))
      idx_lb = ! (isinf (lb) & lb < 0);
      Ain = [Ain; eye(n)(idx_lb,:)];
      bin = [bin; lb(idx_lb,1)];
    endif
  endif
  if (! isempty (ub))
    if (! isvector (ub) || numel (ub) != n)
      error ("%s: upper bounds have incorrect dimensions", fname);
    elseif (isempty (lb))
      idx_ub = ! (isinf (ub) & ub > 0);
      Ain = [Ain; -eye(n)(idx_ub,:)];
      bin = [bin; -ub(idx_ub,1)];
    endif
  endif
  count_not_ineq = 0;
  idx_bounds_ineq = true (n, 1);
  idx_bounds_eq = false (n, 1);
  if (! isempty (lb) && ! isempty (ub))
    rtol = sqrt (eps);
    ## index upper and lower bounds far enough apart from each other
    ## -- the others will be treated as equality constraints
    idx_bounds_ineq = abs (ub - lb) >= rtol * (1 + abs (lb));
    idx_bounds_eq = ! idx_bounds_ineq;
    idx_lb = ! (isinf (lb) & lb < 0);
    idx_ub = ! (isinf (ub) & ub > 0);
    if (any (ub < lb & idx_bounds_ineq))
      error ("%s: some upper bounds lower than lower bounds", fname);
    endif
    ## possibly add to equality constraints
    Aeq = vertcat (Aeq, eye (n)(idx_bounds_eq, :));
    beq = vertcat (beq, .5 * (lb(idx_bounds_eq, 1) ...
                              + ub(idx_bounds_eq, 1)));
    ## possibly add to inequality constraints
    Ain = vertcat (Ain,
                   eye (n)(idx_bounds_ineq & idx_lb, :),
                   - eye (n)(idx_bounds_ineq & idx_ub, :));
    bin = vertcat (bin,
                   lb(idx_bounds_ineq & idx_lb, 1),
                   - ub(idx_bounds_ineq & idx_ub, 1));

    count_not_ineq = sum (idx_bounds_eq);
  endif

  n_eq = numel (beq);
  n_in = numel (bin);

  ## Now we should have the following QP:
  ##
  ##   min_x  0.5*x'*H*x + x'*f
  ##   s.t.   Aeq*x = beq
  ##          A*x >= b

  ## Check if the initial guess is feasible.
  if (isa (x0, "single") || isa (H, "single") || isa (f, "single")
      || isa (Aeq, "single") || isa (beq, "single"))
    rtol = sqrt (eps ("single"));
  else
    rtol = sqrt (eps);
  endif

  eq_infeasible = (n_eq > 0 && norm (Aeq * x0 - beq) > rtol * (1 + abs (beq)));
  in_infeasible = (n_in > 0 && any (Ain * x0 - bin < -rtol * (1 + abs (bin))));

  exitflag = 0;

  if (isdefinite (H) != 1)
    exitflag = 2;
  endif

  if (exitflag == 0 && (eq_infeasible || in_infeasible))
      ## The initial guess is not feasible.
      ## First define xbar that is feasible with respect to the equality
      ## constraints.
      if (eq_infeasible)
        if (rank (Aeq) < n_eq)
          error ("%s: equality constraint matrix must be full row rank",
                 fname);
        endif
        xbar = pinv (Aeq) * beq;
      else
        xbar = x0;
      endif

    ## Check if xbar is feasible with respect to the inequality
    ## constraints also.
    if (n_in > 0)
      res = Ain * xbar - bin;
      if (any (res < -rtol * (1 + abs (bin))))
        ## xbar is not feasible with respect to the inequality
        ## constraints.  Compute a step in the null space of the
        ## equality constraints, by solving a QP.  If the slack is
        ## small, we have a feasible initial guess.  Otherwise, the
        ## problem is infeasible.
        if (n_eq > 0)
          Z = null (Aeq);
          if (isempty (Z))
            ## The problem is infeasible because Aeq is square and full
            ## rank, but xbar is not feasible.
            exitflag = 6;
          endif
        endif

        if (exitflag != 6)
          ## Solve an LP with additional slack variables to find
          ## a feasible starting point.
          gamma = eye (n_in);
          if (n_eq > 0)
            Atmp = [Ain*Z, gamma];
            btmp = -res;
          else
            Atmp = [Ain, gamma];
            btmp = bin;
          endif
          ctmp = [zeros(n-n_eq, 1); ones(n_in, 1)];
          lb = [-Inf(n-n_eq,1); zeros(n_in,1)];
          ub = [];
          ctype = repmat ("L", n_in, 1);
          [P, dummy, status] = glpk (ctmp, Atmp, btmp, lb, ub, ctype);
          if ((status == 0)
              && all (abs (P(n-n_eq+1:end)) < rtol * (1 + norm (btmp))))
            ## We found a feasible starting point
            if (n_eq > 0)
              x0 = xbar + Z * P(1:n-n_eq);
            else
              x0 = P(1:n);
            endif
          else
            ## The problem is infeasible
            exitflag = 6;
          endif
        endif
      else
        ## xbar is feasible.  We use it a starting point.
        x0 = xbar;
      endif
    else
      ## xbar is feasible.  We use it a starting point.
      x0 = xbar;
    endif
  endif

  if (exitflag == 0)
    ## The initial (or computed) guess is feasible.
    ## We call the solver.
    [x, qp_lambda, exitflag, iter] = ...
    __qp__wrapper (x0, H, f, Aeq, beq, Ain, bin, maxit, rtol);

  else
    iter = 0;
    x = x0;
  endif

  varargout = cell (1, nout);

  varargout{1} = x;

  if (nout >= 2)
    varargout{2} = 0.5 * x' * H * x + f' * x;;
  endif

  if (nout >= 3)
    switch (exitflag)
      case 0
        varargout{3} = 1;
      case 1
        varargout{3} = 4;
      case 2
        varargout{3} = -3;
      case 3
        varargout{3} = 0;
      case 6
        varargout{3} = -2;
    endswitch
  endif

  if (nout >= 4)
    varargout{4}.iterations = iter;
  endif

  if (nout >= 5 && exitflag == 0)
    lm_idx = 1; lambda_not_ineq = [];
    ## Pick multipliers corresponding to equality constraints first if
    ## present
    if (n_eq > 0)
      ## Matlab specifies in its online help pages the condition
      ## 'gradient f + lambda * gradient equality_constraints = 0',
      ## which determines this sign of lambda for equality
      ## constraints. The difference to __sqp__ probably results from
      ## the different 'direction' of _in_equality constraints (<=
      ## versus >=), which are usually handled together with equality
      ## constraints in the algorithm.
      lambda.eqlin = -qp_lambda(lm_idx:lm_idx + n_eq - count_not_ineq
                                       - 1);
      ## Multipliers corresponding to too close bounds making equality
      ## constraints
      lambda_not_ineq = -qp_lambda(lm_idx + n_eq - count_not_ineq:
                                   lm_idx + n_eq -1);
      lm_idx += n_eq;
    endif
    ## Pick multipliers corresponding to inequality constraints if
    ## present
    if (! isempty (allargin{1}))
      ineq_tmp = qp_lambda(lm_idx:lm_idx + sum (! idx_ineq) - 1);
      lambda.ineqlin = ineq_tmp;
      lm_idx = lm_idx + sum (! idx_ineq);
    endif

    ## Multipliers corresponding to bounds. Multipliers of too close
    ## bounds, having been treated as equality constraints, have to be
    ## inserted here (for one of these bounds only, otherwise we'd
    ## have an additional term with respect to the implicitely used
    ## Lagrangian at the result). The derivative of the equality
    ## constraint, given the way this constraint is (implicitely)
    ## formulated in this algorithm, is the same as the derivative of
    ## the corresponding upper bound, so lambda is assigned to the
    ## upper bound if it's positive. If it's negative, this can't be
    ## done (bounds correspond to inequality constraints), so it is
    ## negated and assigned to the lower bound instead.
    pos_idx = ! (neg_idx = lambda_not_ineq < 0);
    idx_pos_lambda = idx_neg_lambda = false (n, 1);
    idx_pos_lambda(idx_bounds_eq) = pos_idx;
    idx_neg_lambda(idx_bounds_eq) = neg_idx;

    ## Pick multipliers corresponding to lower bounds if present
    if (! isempty (allargin{5}))
      lambda.lower = zeros (n, 1);
      lb_tmp = qp_lambda(lm_idx:lm_idx + sum (idx_lb) - count_not_ineq
                                - 1);
      ## Take care of the position of too close and -Inf bounds
      idx = idx_bounds_ineq & idx_lb;
      lambda.lower(idx) = lb_tmp;
      lambda.lower(idx_neg_lambda) = -lambda_not_ineq(neg_idx);
      lambda.lower = lambda.lower(:);
      lm_idx += sum (idx_lb) - count_not_ineq;
    endif
    ## Pick multipliers corresponding to upper bounds if present
    if (! isempty (allargin{6}))
      lambda.upper = zeros (n, 1);
      ub_tmp = qp_lambda(lm_idx:lm_idx + sum (idx_ub) - count_not_ineq
                                - 1);
      ## Take care of the position of -Inf bounds
      idx = idx_bounds_ineq & idx_ub;
      lambda.upper(idx) = ub_tmp;
      lambda.upper(idx_pos_lambda) = lambda_not_ineq(pos_idx);
      lambda.upper = lambda.upper(:);
    endif
    varargout{5} = lambda;
  endif

endfunction

function vec = check_vector (vec, n, fname, vecname)

  if (isempty (vec))
    vec = zeros (n, 1);
  else
    if (! isvector (vec))
      error ("%s: %s must be a vector", fname, vecname);
    endif
    if (numel (vec) != n)
      error ("%s: %s has incorrect length", fname, vecname);
    endif
    vec = vec(:);
  endif

endfunction

%!test
%!  C = [0.9501    0.7620    0.6153    0.4057
%!      0.2311    0.4564    0.7919    0.9354
%!      0.6068    0.0185    0.9218    0.9169
%!      0.4859    0.8214    0.7382    0.4102
%!      0.8912    0.4447    0.1762    0.8936];
%!  %% Linear Inequality Constraints
%!  d = [0.0578; 0.3528; 0.8131; 0.0098; 0.1388];
%!  A =[0.2027    0.2721    0.7467    0.4659
%!      0.1987    0.1988    0.4450    0.4186
%!      0.6037    0.0152    0.9318    0.8462];
%!  b =[0.5251; 0.2026; 0.6721];
%!  %% Linear Equality Constraints
%!  Aeq = [3 5 7 9];
%!  beq = 4;
%!  %% Bound constraints
%!  lb = -0.1*ones(4,1);
%!  ub = ones(4,1);
%!  H = C' * C;
%!  f = -C' * d;
%!  [x, obj, flag, output, lambda]=quadprog (H, f, A, b, Aeq, beq, lb, ub);
%! assert (x, [-.1; -.1; .1599; .4090], .0001);
%! assert (obj, -0.3194, .0001);
%! assert (flag, 1);
%! assert (lambda.lower, [.0674; .2499; 0; 0], .0001);
%! assert (lambda.upper, [0; 0; 0; 0]);

%!demo
%!  C = [0.9501    0.7620    0.6153    0.4057
%!      0.2311    0.4564    0.7919    0.9354
%!      0.6068    0.0185    0.9218    0.9169
%!      0.4859    0.8214    0.7382    0.4102
%!      0.8912    0.4447    0.1762    0.8936];
%!  %% Linear Inequality Constraints
%!  d = [0.0578; 0.3528; 0.8131; 0.0098; 0.1388];
%!  A =[0.2027    0.2721    0.7467    0.4659
%!      0.1987    0.1988    0.4450    0.4186
%!      0.6037    0.0152    0.9318    0.8462];
%!  b =[0.5251; 0.2026; 0.6721];
%!  %% Linear Equality Constraints
%!  Aeq = [3 5 7 9];
%!  beq = 4;
%!  %% Bound constraints
%!  lb = -0.1*ones(4,1);
%!  ub = ones(4,1);
%!  H = C' * C;
%!  f = -C' * d;
%!  [x, obj, flag, output, lambda]=quadprog (H, f, A, b, Aeq, beq, lb, ub)
