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
## @deftypefn {Function File} {} lsqcurvefit (@var{fun}, @var{x0}, @var{xdata}, @var{ydata})
## @deftypefnx {Function File} {} lsqcurvefit (@var{fun}, @var{x0}, @var{xdata}, @var{ydata}, @var{lb}, @var{ub})
## @deftypefnx {Function File} {} lsqcurvefit (@var{fun}, @var{x0}, @var{xdata}, @var{ydata}, @var{lb}, @var{ub}, @var{options})
## @deftypefnx {Function File} {} lsqcurvefit (@var{problem})
## @deftypefnx {Function File} {[@var{x}, @var{resnorm}, @var{residual}, @var{exitflag}, @var{output}, @var{lambda}, @var{jacobian}] =} lsqcurvefit (@dots{})
## Solve nonlinear least-squares (nonlinear data-fitting) problems
## @example
## @group
## min [EuclidianNorm (f(x, xdata) - ydata)] .^ 2
##  x
## @end group
## @end example
##
## The first four input arguments must be provided with non-empty
## initial guess @var{x0}. For a given input @var{xdata}, @var{ydata}
## is the observed output. @var{ydata} must be the same size as the
## vector (or matrix) returned by @var{fun}. The optional bounds
## @var{lb} and @var{ub} should be the same size as @var{x0}.
##
## @code{lsqcurvefit} may also be called with a single structure
## argument with the fields @code{fun}, @code{x0}, @code{xdata},
## @code{ydata}, @code{lb}, @code{ub}, and @code{options}, resembling
## the separate input arguments above. For compatibility reasons,
## field @code{fun} may also be called @code{objective}. Additionally,
## the structure must have the field @code{solver}, set to
## @qcode{"lsqcurvefit"}.
##
## @var{options} can be set with @code{optimset}.
## Follwing Matlab compatible options
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
##    Maximum number of iterations allowed. Default: 20.
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
## Coefficients to best fit the nonlinear function fun(x,xdata) to the observed values ydata.
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
## m-by-n matrix, where @var{jacobian}(i,j) is the partial derivative of @var{fun(i)} with respect to @var{x(j)}
## If @code{Jacobian} is set to "on" in @var{options} then @var{fun} must return a second argument providing a user-sepcified Jacobian. Otherwise, lsqnonlin approximates the Jacobian using finite differences.
## @end table
##
## This function is a compatibility wrapper. It calls the more general @code{nonlin_curvefit} function internally.
##
## @seealso{lsqnonlin, nonlin_residmin, nonlin_curvefit}
## @end deftypefn

## PKG_ADD: [~] = __all_opts__ ("lsqcurvefit");

function varargout = lsqcurvefit (varargin)

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
      error ("lsqcurvefit: PROBLEM must be a structure");
    endif
    if (! strcmp (problem.solver, "lsqcurvefit"))
      error ('lsqcurvefit: problem.solver must be set to "lsqcurvefit"');
    endif

    varargin = evaluate_problem_structure (problem,
                                           {{true, "objective", "fun"},
                                            {true, "x0"},
                                            {true, "xdata"},
                                            {true, "ydata"},
                                            {false, "lb"},
                                            {false, "ub"},
                                            {false, "options"}});
                                            
    nargs = numel (varargin);

  endif

  if (nargs < 4 || nargs==5 || nargs > 7)
    print_usage ();
  endif

  if (! isreal (varargin{2}))
    error("Function does not accept complex inputs. Split into real and imaginary parts")
  endif

  modelfun = varargin{1};
  out_args = nargout ();
  varargout = cell (1, out_args);
  in_args{1} = varargin{1};
  in_args{2} = varargin{2}(:);
  in_args(3:4) = varargin(3:4);

  if (nargs >= 6)
    ## bounds are specified in a different way for nonlin_curvefit
    settings = optimset ("lbound", varargin{5}(:),
                         "ubound", varargin{6}(:));

    if (nargs == 7)

      ## Jacobian function is specified in a different way for
      ## nonlin_curvefit
      if (strcmpi (optimget (varargin{7}, "Jacobian"), "on"))
          settings = optimset (settings,
                               "dfdp", @(p, varargin) computeJacob (modelfun, p, in_args{3}));
      endif

      ## apply default values which are possibly different from those of
      ## nonlin_curvefit
      FinDiffType = optimget (varargin{7}, "FinDiffType", "forward");
      if (strcmpi (FinDiffType, "forward"))
        FinDiffRelStep_default = sqrt (eps);
      elseif (strcmpi (FinDiffType, "central"))
        FinDiffRelStep_default = eps^(1/3);
      else
        error ("unknown value of option 'FinDiffType': %s",
               FinDiffType);
      endif
      FinDiffRelStep = optimget (varargin{7}, "FinDiffRelStep", FinDiffRelStep_default);
      TolFun = optimget (varargin{7}, "TolFun", TolFun_default);
      MaxIter = optimget (varargin{7}, "MaxIter", MaxIter_default);
      TypicalX = optimget (varargin{7}, "TypicalX", TypicalX_default);
      Display = optimget (varargin{7}, "Display", "off");
      if (! iscell (OutputFcn = optimget (varargin{7}, "OutputFcn", {})))
        OutputFcn = {OutputFcn};
      endif

      if (! strcmpi (Display, "off"))
        if (strcmpi (Display, "iter-detailed") || strcmpi (Display, "final")...
        || strcmpi (Display, "final-detailed"))
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

    in_args{5} = settings;
  endif

  n_out = max (1, min (out_args, 5));

  if (n_out > 2)
    n_out--;
  endif

  curvefit_out = cell (1, n_out);

  [curvefit_out{:}] =  nonlin_curvefit (in_args{:});

  [row, col] = size (in_args{2});
  varargout{1} = reshape (curvefit_out{1}, row, col);

  if (out_args >= 2)
    varargout{2} = sumsq (curvefit_out{2} - in_args{4});
  endif

  if (out_args >= 3)
    varargout{3} = curvefit_out{2} - in_args{4};
  endif

  if (out_args >= 4)
    varargout{4} = curvefit_out{3};
  endif

  if (out_args >= 5)
    outp = curvefit_out{4};
    if (isfield (outp, "lambda")) # not set if stopped by user_interaction
      outp = rmfield (outp, 'lambda');
    endif
    if (isfield (outp, "user_interaction"))
      outp = rmfield (outp, "user_interaction");
    endif
    outp.iterations = outp.niter;
    outp = rmfield (outp, "niter");
    varargout{5} = outp;
  endif

  if (out_args >= 6)
    if (isfield (outp, "lambda")) # not set if stopped by user_interaction
      varargout{6}.lower = curvefit_out{4}.lambda.lower;
      varargout{6}.upper = curvefit_out{4}.lambda.upper;
    else
      varargout{6} = [];
    endif
  endif

  if (out_args >= 7)
    info = curvefit_stat (modelfun, curvefit_out{1}, in_args{3}, in_args{4},
                          optimset (settings, "ret_dfdp", true));
    varargout{7} = info.dfdp;
  endif

endfunction

function Jacob = computeJacob (modelfun, p, xdata)
  [~, Jacob] = modelfun (p, xdata);
endfunction

function user_interaction = compute_user_interaction (OutputFcn)
  n = numel (OutputFcn);
  user_interaction = cell (1, n);
  for i = 1:n;
    user_interaction{i} = @(p, vals, state) deal (OutputFcn{i} (p, vals, state), {} ) ;
  endfor
endfunction

%!test
%! xdata = [0 .3 .8 1.1 1.6 2.3];
%! ydata = [.82 .72 .63 .60 .55 .50];
%! yhat = @(p,x) p(1) + p(2)*exp(-x);
%! opt = optimset('TolFun',1e-100);
%! [p, resnorm, residual] = lsqcurvefit(yhat,[1 1], xdata, ydata,[0 0],[],opt);
%! assert (p, [ 0.47595; 0.34132], 1e-5)
%! assert (resnorm, 3.2419e-004, 1e-8)
%! assert(residual, [-2.7283e-003, 8.8079e-003, -6.8307e-004, -1.0432e-002, -5.1366e-003, 1.0172e-002], 1e-5)

%!test
%! problem.solver = "lsqcurvefit";
%! problem.objective = @(p,x) p(1) + p(2)*exp(-x);
%! problem.x0 = [1, 1];
%! problem.xdata = [0 .3 .8 1.1 1.6 2.3];
%! problem.ydata = [.82 .72 .63 .60 .55 .50];
%! problem.lb = [0, 0];
%! problem.ub = [];
%! problem.options = optimset('TolFun',1e-100);
%! [p, resnorm, residual] = lsqcurvefit (problem);
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
%!  function [F,J] = myfun (p, x)
%!    F = p(1) * exp (-p(2) * x);
%!    if nargout > 1
%!      J = [exp(- p(2) * x), - p(1) * x .* exp(- p(2) * x)];
%!    endif
%!  endfunction
%!
%!  [c, resnorm, residual, flag, output, lambda, jacob] = ...
%!      lsqcurvefit (@ (varargin) myfun(varargin{:}), p0, x, y, lb,  ub, opts)
