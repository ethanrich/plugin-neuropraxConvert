## Copyright (C) 2015 Asma Afzal
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
## @deftypefn {Function File} {} lsqnonlin (@var{fun}, @var{x0})
## @deftypefnx {Function File} {} lsqnonlin (@var{fun}, @var{x0}, @var{lb}, @var{ub})
## @deftypefnx {Function File} {} lsqnonlin (@var{fun}, @var{x0}, @var{lb}, @var{ub}, @var{options})
## @deftypefnx {Function File} {[@var{x}, @var{resnorm}, @var{residual}, @var{exitflag}, @var{output}, @var{lambda}, @var{jacobian}] =} lsqnonlin (@dots{})
## Solve nonlinear least-squares (nonlinear data-fitting) problems
## @example
## @group
## min [EuclidianNorm(f(x))] .^ 2
##  x   
## @end group
## @end example
## 
## @var{fun} computes residuals from given parameters. The initial
## guess of the parameters @var{x0} must be provided while the bounds
## @var{lb} and @var{ub}) can be set to the empty matrix (@code{[]})
## if not given.
##
## @code{lsqnonlin} may also be called with a single structure
## argument with the fields @code{fun}, @code{x0}, @code{lb},
## @code{ub}, and @code{options}, resembling the separate input
## arguments above. For compatibility reasons, field @code{fun} may
## also be called @code{objective}. Additionally, the structure must
## have the field @code{solver}, set to @qcode{"lsqnonlin"}.
##
## @var{options} can be set with @code{optimset}. Follwing Matlab compatible options
## are recognized:
## 
## @code{Algorithm}
##    String specifying backend algorithm. Currently available "lm_svd_feasible"
##    only. 
##
## @code{TolFun}
##    Minimum fractional improvement in objective function in an iteration 
##    (termination criterium). Default: 1e-6. 
##
## @code{TypicalX}
##    Typical values of x. Default: 1.
##
## @code{MaxIter}
##    Maximum number of iterations allowed. Default: 400.
##
## @code{Jacobian}
##    If set to "on", the function @var{fun} must return a second output
##    containing a user-specified Jacobian. The Jacobian is computed using
##    finite differences otherwise. Default: "off"
##
## @code{FinDiffType}
##    "centered" or "forward" (Default) type finite differences estimation.
##
## @code{FinDiffRelStep}
##    Step size factor. The default is sqrt(eps) for forward finite differences,
##    and eps^(1/3) for central finite differences
##
## @code{OutputFcn}
##    One or more user-defined functions, either as a function handle or as a
##    cell array of function handles that an optimization function calls at each
##    iteration. The function definition has the following form:
##
##    @code{stop = outfun(x, optimValues, state)}
##    
##    @code{x} is the point computed at the current iteration.
##    @code{optimValues} is a structure containing data from the current
##    iteration in the following fields:
##    "iteration"- number of current iteration.
##    "residual"- residuals.
##    @code{state} is the state of the algorithm: "init" at start,
##    "iter" after each iteration and "done" at the end.
##
## @code{Display}
##    String indicating the degree of verbosity. Default: "off". 
##    Currently only supported values are "off" (no messages) and "iter" 
##    (some messages after each iteration).    
##
## Returned values:
##
## @table @var
## @item x
## Position of minimum.
##
## @item resnorm
## Scalar value of objective as squared EuclidianNorm(f(x)).
##
## @item residual
## Value of solution residuals f(x).
##
## @item exitflag
## Status of solution:
##
## @table @code
## @item 0
## Maximum number of iterations reached.
##
## @item 2
## Change in x was less than the specified tolerance.
##
## @item 3
## Change in the residual was less than the specified tolerance.
##
## @item -1
## Output function terminated the algorithm.
## @end table
##
## @item output
## Structure with additional information, currently the only field is
## @code{iterations}, the number of used iterations.
##
## @item lambda
## Structure containing Lagrange multipliers at the solution @var{x} sepatared by constraint type (@var{lb} and @var{ub}).
##
## @item jacobian
## m-by-n matrix, where @var{jacobian(i,j)} is the partial derivative of @var{fun(i)} with respect to @var{x(j)}
## Default: lsqnonlin approximates the Jacobian using finite differences. If @code{Jacobian} is set to "on" in 
## @var{options} then @var{fun} must return a second argument providing a user-sepcified Jacobian .
## @end table
##
## This function is a compatibility wrapper. It calls the more general @code{nonlin_residmin} function internally.
##
## @seealso{lsqcurvefit, nonlin_residmin, nonlin_curvefit}
## @end deftypefn

## PKG_ADD: [~] = __all_opts__ ("lsqnonlin");

function varargout = lsqnonlin (varargin)

  nargs = nargin ();
  
  TolFun_default = 1e-6;
  MaxIter_default = 400;
  TypicalX_default = 1;
  
  if (nargs == 1 && ischar (varargin{1}) && strcmp (varargin{1}, "defaults"))
    varargout{1} = optimset ("FinDiffRelStep", [],
               "FinDiffType", "forward",
               "TypicalX", TypicalX_default,
               "TolFun", TolFun_default,
               "MaxIter", MaxIter_default,
               "Display", "off",
               "Jacobian", "off",
               "OutputFcn", {},
               "Algorithm", "lm_svd_feasible");
    return;
  endif

  if (nargs == 1)

    problem = varargin{1};

    if (! isstruct (problem))
      error ("lsqnonlin: PROBLEM must be a structure");
    endif
    if (! strcmp (problem.solver, "lsqnonlin"))
      error ('lsqnonlin: problem.solver must be set to "lsqnonlin"');
    endif

    varargin = evaluate_problem_structure (problem,
                                           {{true, "objective", "fun"},
                                            {true, "x0"},
                                            {false, "lb"},
                                            {false, "ub"},
                                            {false, "options"}});
                                            
    nargs = numel (varargin);

  endif

  if (nargs < 2 || nargs==3 || nargs > 5)
    print_usage ();
  endif

  if (! isreal (varargin{2}))
    error ("Function does not accept complex inputs. Split into real and imaginary parts")
  endif

  modelfun = varargin{1};
  out_args = nargout ();
  varargout = cell (1, out_args);
  in_args{1} = varargin{1};
  in_args{2} = varargin{2}(:);

  settings = struct ();
  if (nargs >= 4)
    ## bounds are specified in a different way for nonlin_residmin
    settings = optimset ("lbound", varargin{3}(:),
                         "ubound", varargin{4}(:));

    if (nargs == 5)
      ## Jacobian function is specified in a different way for
      ## nonlin_residmin
      if (strcmpi (optimget (varargin{5}, "Jacobian"), "on"))
          settings = optimset (settings,
                               "dfdp", @(p) computeJacob (modelfun, p));
      endif

      ## apply default values which are possibly different from those of
      ## nonlin_residmin
      FinDiffType = optimget (varargin{5}, "FinDiffType", "forward");
      if (strcmpi (FinDiffType, "forward"))
        FinDiffRelStep_default = sqrt (eps);
      elseif (strcmpi (FinDiffType, "central"))
        FinDiffRelStep_default = eps^(1/3);
      else
        error ("unknown value of option 'FinDiffType': %s",
               FinDiffType);
      endif
      FinDiffRelStep = optimget (varargin{5}, "FinDiffRelStep",
                       FinDiffRelStep_default);
      TolFun = optimget (varargin{5}, "TolFun", TolFun_default);
      MaxIter = optimget (varargin{5}, "MaxIter", MaxIter_default);
      TypicalX = optimget (varargin{5}, "TypicalX", TypicalX_default);
      Display = optimget (varargin{5}, "Display", "off");
      if (! iscell (OutputFcn = optimget (varargin{5}, "OutputFcn", {})))
        OutputFcn = {OutputFcn};
      endif

      if (! strcmpi (Display, "off"))
        if (strcmpi (Display, "iter-detailed") ||
            strcmpi (Display, "final") ||
            strcmpi (Display, "final-detailed"))
          Display = "iter";
        endif
      endif

      ## 'user_interaction' must return an additional informational
      ## output argument
      user_interaction = compute_user_interaction (OutputFcn);

      settings = optimset (settings, "FinDiffRelStep", FinDiffRelStep,
                           "FinDiffType", FinDiffType,
                           "TolFun", TolFun,
                           "TypicalX", TypicalX,
                           "MaxIter", MaxIter,
                           "Display", Display,
                           "user_interaction", user_interaction);
    endif

    in_args{3} = settings;
  endif

  n_out = max (1, min (out_args, 5));

  if (n_out > 2)
    n_out--;
  endif

  residmin_out = cell (1, n_out);

  [residmin_out{:}] =  nonlin_residmin (in_args{:});

  varargout{1} = residmin_out{1};

  if (out_args >= 2)
    varargout{2} = sumsq (residmin_out{2});
  endif

  if (out_args >= 3)
    varargout{3} = residmin_out{2};
  endif

  if (out_args >= 4)
    varargout{4} = residmin_out{3};
  endif

  if (out_args >= 5)
    outp = residmin_out{4};
    if (isfield (outp, "lambda")) # not set if stopped by user_interaction
      outp = rmfield (outp, "lambda");
    endif
    if (isfield (outp, "user_interaction"))
      outp = rmfield (outp, "user_interaction");
    endif
    varargout{5} = outp;
  endif

  if (out_args >= 6)
    if (isfield (outp, "lambda")) # not set if stopped by user_interaction
      varargout{6}.lower = residmin_out{4}.lambda.lower;
      varargout{6}.upper = residmin_out{4}.lambda.upper;
    else
      varargout{6} = [];
    endif
  endif

  if (out_args >= 7)
    info = residmin_stat (modelfun, residmin_out{1}, optimset (settings, "ret_dfdp", true));
    varargout{7} = info.dfdp;
  endif

endfunction

function Jacob = computeJacob (modelfun, p)
  [~, Jacob] = modelfun (p);
endfunction

function user_interaction = compute_user_interaction (OutputFcn)
  n = numel (OutputFcn);
  user_interaction = cell (1, n);
  for i = 1:n;
    user_interaction{i} = @(p, vals, state) deal (OutputFcn{i} (p, vals, state), {} ) ;
  endfor
endfunction

%!test
%! t = [0 .3 .8 1.1 1.6 2.3];
%! y = [.82 .72 .63 .60 .55 .50];
%! yhat = @(c,t) c(1) + c(2)*exp(-t);
%! opt = optimset('TolFun',1e-10);
%! [c,resnorm,residual] = lsqnonlin(@(c)yhat(c,t)-y,[1 1],[0 0],[],opt);
%! assert (c, [ 0.47595; 0.34132], 1e-5)
%! assert (resnorm, 3.2419e-004, 1e-8)
%! assert(residual, [-2.7283e-003, 8.8079e-003, -6.8307e-004, -1.0432e-002, -5.1366e-003, 1.0172e-002], 1e-5)

%!test
%! problem.solver = "lsqnonlin";
%! xdata = [0 .3 .8 1.1 1.6 2.3];
%! ydata = [.82 .72 .63 .60 .55 .50];
%! problem.objective = @(p) p(1) + p(2)*exp(-xdata) - ydata;
%! problem.x0 = [1, 1];
%! problem.lb = [0, 0];
%! problem.ub = [];
%! problem.options = optimset('TolFun',1e-100);
%! [p, resnorm, residual] = lsqnonlin (problem);
%! assert (p, [ 0.47595; 0.34132], 1e-5)
%! assert (resnorm, 3.2419e-004, 1e-8)
%! assert(residual, [-2.7283e-003, 8.8079e-003, -6.8307e-004, -1.0432e-002, -5.1366e-003, 1.0172e-002], 1e-5)

%!demo
%!  %% Example for user specified Jacobian.
%!
%!  %% independents
%!  x = [1:10:100]';
%!  %% observed data
%!  y =[9.2160e-001, 3.3170e-001, 8.9789e-002, 2.8480e-002, 2.6055e-002,...
%!     8.3641e-003,  4.2362e-003,  3.1693e-003,  1.4739e-004,  2.9406e-004]';
%!  %% initial values:
%!  p0=[0.8; 0.05];
%!  %% bounds
%!  lb=[0; 0]; ub=[];
%!  %% Jacobian setting
%!  opts = optimset ("Jacobian", "on")
%!
%!  %% model function:
%!  function [F,J] = myfun (p, x, y)
%!    F = p(1) * exp (-p(2) * x) - y;
%!    if nargout > 1
%!      J = [exp(- p(2) * x), - p(1) * x .* exp(- p(2) * x)];
%!    endif
%!  endfunction
%!
%!  [c, resnorm, residual, flag, output, lambda, jacob] = ...
%!      lsqnonlin(@(p) myfun(p, x, y), p0, lb,  ub, opts)
