## Copyright (C) 2015 Asma Afzal
##
## Octave is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or (at
## your option) any later version.
##
## Octave is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
## General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with Octave; see the file COPYING. If not, see
## <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} {} lsqlin (@var{C}, @var{d}, @var{A}, @var{b})
## @deftypefnx {Function File} {} lsqlin (@var{C}, @var{d}, @var{A}, @var{b}, @var{Aeq}, @var{beq}, @var{lb}, @var{ub})
## @deftypefnx {Function File} {} lsqlin (@var{C}, @var{d}, @var{A}, @var{b}, @var{Aeq}, @var{beq}, @var{lb}, @var{ub}, @var{x0})
## @deftypefnx {Function File} {} lsqlin (@var{C}, @var{d}, @var{A}, @var{b}, @var{Aeq}, @var{beq}, @var{lb}, @var{ub}, @var{x0}, @var{options})
## @deftypefnx {Function File} {[@var{x}, @var{resnorm}, @var{residual}, @var{exitflag}, @var{output}, @var{lambda}] =} lsqlin (@dots{})
## Solve the linear least squares program
## @example
## @group
## min 0.5 sumsq(C*x - d)
## x
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
## the empty matrix (@code{[]}) if not given. If the initial guess
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
## @item resnorm
## Scalar value of objective as sumsq(C*x - d).
##
## @item residual
## Vector of solution residuals C*x - d.
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
## The problem is not convex and unbounded.
##
## @item 1
## Global solution found.
##
## @end table
##
## @item output
## Structure with additional information, currently the only field is
## @code{iterations}, the number of used iterations.
##
## @item lambda
## Structure containing Lagrange multipliers corresponding to the
## constraints.
##
## @end table
##
## This function calls the more general function @code{quadprog}
## internally.
##
## @seealso{quadprog}
## @end deftypefn

## PKG_ADD: [~] = __all_opts__ ("lsqlin");

function varargout = lsqlin (C, d, A, b, varargin)

  nargs = nargin ();

  n_out = nargout ();

  if (nargs == 1 && ischar (C) && strcmp (C, "defaults"))
    varargout{1} = optimset ("MaxIter", 200);
    return;
  endif

  maxnargs = 10;

  if (nargs < 4 || nargs > 4 && nargs < 8 || nargs > maxnargs)
    print_usage();
  endif
  
  ## do the argument mapping
  Ch = C';
  in_args = horzcat ({Ch * C}, {real(- Ch * d)}, {A}, {b}, varargin);

  varargout = cell (1, n_out);

  if (n_out > 2)
    ## We don't need to know if original n_out was 3 or 2.
    n_out--;
  endif

  quadprog_out = cell (1, max (n_out, 1));

  [quadprog_out{:}] = quadprog (in_args{:});

  varargout{1} = quadprog_out{1};

  if (n_out >= 2)
    ## The residuals have to be calculated as intermediate values
    ## anyway, so compute varargout{3} even if not requested.
    varargout{3} = C * quadprog_out{1} - d;
    varargout{2} = sumsq (varargout{3});
  endif

  varargout(4:end) = quadprog_out(3:end);
endfunction

%!test
%!shared C,d,A,b
%! C = [0.9501,0.7620,0.6153,0.4057;...
%!     0.2311,0.4564,0.7919,0.9354;...
%!     0.6068,0.0185,0.9218,0.9169;...
%!     0.4859,0.8214,0.7382,0.4102;...
%!     0.8912,0.4447,0.1762,0.8936];
%! d = [0.0578;    0.3528;    0.8131;    0.0098;    0.1388];
%! A =[0.2027,    0.2721,    0.7467,   0.4659;...
%!    0.1987,    0.1988,    0.4450,   0.4186;...
%!    0.6037 , 0.0152,    0.9318,    0.8462];
%! b =[0.5251;0.2026;0.6721];
%! Aeq = [3, 5, 7, 9];
%! beq = 4;
%! lb = -0.1*ones(4,1);
%! ub = 2*ones(4,1);
%! [x,resnorm,residual,exitflag] = lsqlin(C,d,A,b,Aeq,beq,lb,ub);
%! assert(x,[-0.10000;  -0.10000;   0.15991;   0.40896],10e-5)
%! assert(resnorm,0.16951,10e-5)
%! assert(residual, [0.035297; 0.087623;  -0.353251;   0.145270;   0.121232],10e-5)
%! assert(exitflag,1)

%!test
%! Aeq = [];
%! beq = [];
%! lb = [];
%! ub = [];
%! x0 = 0.1*ones(4,1);
%! x = lsqlin(C,d,A,b,Aeq,beq,lb,ub,x0);
%! [x,resnorm,residual,exitflag] = lsqlin(C,d,A,b,Aeq,beq,lb,ub,x0);
%! assert(x,[ 0.12986;  -0.57569 ;  0.42510;   0.24384],10e-5)
%! assert(resnorm,0.017585,10e-5)
%! assert(residual, [-0.0126033;  -0.0208040;  -0.1295084;  -0.0057389;   0.01372462],10e-5)
%! assert(exitflag,1)

%!demo
%!  C = [0.9501    0.7620    0.6153    0.4057
%!      0.2311    0.4564    0.7919    0.9354
%!      0.6068    0.0185    0.9218    0.9169
%!      0.4859    0.8214    0.7382    0.4102
%!      0.8912    0.4447    0.1762    0.8936];
%!  d = [0.0578; 0.3528; 0.8131; 0.0098; 0.1388];
%!  %% Linear Inequality Constraints
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
%!  [x, resnorm, residual, flag, output, lambda] = lsqlin (C, d, A, b, Aeq, beq, lb, ub)
