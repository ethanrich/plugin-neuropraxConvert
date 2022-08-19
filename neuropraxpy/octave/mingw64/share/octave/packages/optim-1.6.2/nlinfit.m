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
## @deftypefn {Function File} {} nlinfit (@var{X}, @var{Y}, @var{modelfun}, @var{beta0})
## @deftypefnx {Function File} {} nlinfit (@var{X}, @var{Y}, @var{modelfun}, @var{beta0}, @var{options})
## @deftypefnx {Function File} {} nlinfit (@dots{}, @var{Name}, @var{Value})
## @deftypefnx {Function File} {[@var{beta}, @var{R}, @var{J}, @var{CovB}, @var{MSE}] =} nlinfit (@dots{})
## Nonlinear Regression.
##
## @example
## @group
## min [EuclidianNorm (Y - modelfun (beta, X))] ^ 2
## beta
## @end group
## @end example
##
## @var{X} is a matrix of independents, @var{Y} is the observed output and @var{modelfun} is the nonlinear regression model function.
## @var{modelfun} should be specified as a function handle, which
## accepts two inputs: an array of coefficients and an array of
## independents -- in that order.
## The first four input arguments must be provided with non-empty initial guess of the coefficients @var{beta0}.
## @var{Y} and @var{X} must be the same size as the vector (or matrix) returned by @var{fun}.
## @var{options} is a structure containing estimation algorithm options. It can be set using @code{statset}.
## Follwing Matlab compatible options are recognized:
##
## @code{TolFun}
##    Minimum fractional improvement in objective function in an iteration
##    (termination criterium). Default: 1e-6.
##
## @code{MaxIter}
##    Maximum number of iterations allowed. Default: 400.
##
## @code{DerivStep}
##    Step size factor. The default is eps^(1/3) for finite differences gradient
##    calculation.
##
## @code{Display}
##    String indicating the degree of verbosity. Default: "off".
##    Currently only supported values are "off" (no messages) and "iter"
##    (some messages after each iteration).
##
## Optional @var{Name}, @var{Value} pairs can be provided to set additional options.
## Currently the only applicable name-value pair is 'Weights', w,
## where w is the array of real positive weight factors for the
## squared residuals.
##
## Returned values:
##
## @table @var
## @item beta
## Coefficients to best fit the nonlinear function modelfun (beta, X) to the observed values Y.
##
## @item R
## Value of solution residuals: @code{modelfun (beta, X) - Y}.
## If observation weights are specified then @var{R} is the array of
## weighted residuals: @code{sqrt (weights) .* modelfun (beta, X) - Y}.
##
## @item J
## A matrix where @code{J(i,j)} is the partial derivative of @code{modelfun(i)} with respect to @code{beta(j)}.
## If observation weights are specified, then @var{J} is the weighted
## model function Jacobian: @code{diag (sqrt (weights)) * J}.
##
## @item CovB
##
## Estimated covariance matrix of the fitted coefficients.
##
## @item MSE
## Scalar valued estimate of the variance of error term. If the model Jacobian is full rank, then MSE = (R' * R)/(N-p),
## where N is the number of observations and p is the number of estimated coefficients.
## @end table
##
## This function is a compatibility wrapper. It calls the more general @code{nonlin_curvefit}
## and @code{curvefit_stat} functions internally.
##
## @seealso{nonlin_residmin, nonlin_curvefit, residmin_stat, curvefit_stat}
## @end deftypefn

## Author: Asma Afzal
##
## modified by Olaf Till

## PKG_ADD: [~] = __all_stat_opts__ ("nlinfit");

function varargout = nlinfit (X, Y, modelfun, beta0, varargin)

  nargs = nargin ();

  TolFun_default = 1e-8;
  MaxIter_default = 100;
  DerivStep_default = eps ^ (1/3);

  if (nargs == 1 && ischar (X) && strcmp (X, "defaults"))
    varargout{1} = statset ("DerivStep", DerivStep_default,
                            "TolFun", TolFun_default,
                            "MaxIter", MaxIter_default,
                            "Display", "off");
    return;
  endif

  if (nargs < 4 || nargs==6 || nargs > 7)
    print_usage ();
  endif

  if (! isreal (beta0))
    error("Function does not accept complex inputs. Split into real and imaginary parts")
  endif

  out_args = nargout ();
  varargout = cell (1, out_args);
  in_args = {modelfun, beta0(:), X, Y};

  settings = struct ();

  if (nargs >= 5)
    if (! isempty (varargin{1}))
      ## Apply default values which are possibly different from those of
      ## nonlin_curvefit
      DerivStep = statget (varargin{1}, "DerivStep", DerivStep_default);
      TolFun = statget (varargin{1}, "TolFun", TolFun_default);
      MaxIter = statget (varargin{1}, "MaxIter", MaxIter_default);
      Display = statget (varargin{1}, "Display", "off");

      if (! strcmpi (Display, "off"))
        if (strcmpi (Display, "final"))
          Display = "iter";
        endif
      endif

      settings = optimset ("FinDiffRelStep", DerivStep,
                           "TolFun", TolFun,
                           "Display", Display,
                           "MaxIter", MaxIter);
    endif

    if (nargs == 7)
      ## Weights are specified in a different way for nonlin_curvefit
      if (strcmpi (varargin{2}, "weights") )
        weights = sqrt (varargin{3});
        if (size(weights) != size(Y))
          error ("Weights should be the same size as the observed output Y");
        endif
        settings = optimset (settings, "weights", weights);
      else
        error ("Unsupported Name-value pair input.")
      endif
    endif

    in_args{5} = settings;
  endif

  n_out = max (1, min (out_args, 2));

  nlinfit_out = cell (1, n_out);

  [nlinfit_out{:}] =  nonlin_curvefit (in_args{:});

  varargout{1} = nlinfit_out{1};

  if (out_args >= 2)
    if (nargs == 7)
      ## Weighted residual
      varargout{2} = weights .* (in_args{4} - nlinfit_out{2});
    else
      varargout{2} = in_args{4} - nlinfit_out{2};
    endif
  endif

  if (out_args >= 3)
    info = curvefit_stat (modelfun, nlinfit_out{1}, in_args{3}, in_args{4},
                          optimset (settings, "ret_dfdp", true,
                                    "ret_covp", true,
                                    "objf_type", "wls"));
    if (nargs == 7)
      ## Weighted Jacobian
      varargout{3} = diag (weights(:)) * info.dfdp;
    else
      varargout{3} = info.dfdp;
    endif
  endif

  if (out_args >= 4)
    varargout{4} = info.covp;
  endif

  if (out_args >= 5)
    varargout{5} = (varargout{2}' * varargout{2}) / (numel (in_args{3}) - numel (in_args{2}));
  endif
endfunction

%!test
%! modelfun = @(b, x) (b(1) + b(2) * exp (- b(3) * x));
%! b = [1;3;2];
%! v = rande ("state");
%! rande ("seed", 1234);
%! xdata = exprnd (2,100,1);
%! rande ("state", v);
%! v = randn ("state");
%! randn ("seed", 1234);
%! ydata = modelfun (b,xdata) + normrnd (0,0.1,100,1);
%! randn ("state", v);
%! beta0 = [2;2;3];
%! beta = nlinfit(xdata,ydata,modelfun,beta0);
%! assert (beta, [1;3;2], 1e-1)


%!demo
%! modelfun = @(b, x) (b(1) + b(2) * exp (- b(3) * x));
%! %% actual value
%! beta_without_noise = [1; 3; 2];
%! x = [3.49622; 0.33751; 1.25675; 3.66981; 0.26237; 5.51095; ...
%!      2.11407; 1.48774; 6.22436; 2.04519];
%! y_actual = modelfun (beta_without_noise, x);
%! noise = [0.176110; -0.066850; 0.231000; -0.047570; -0.108230; ...
%!          0.122790; 0.062940; 0.151510; 0.116010; -0.097460];
%! y_noisy = y_actual + noise;
%! %% initial guess
%! beta0 = [2; 2; 2];
%! %% weights vector
%! weights = [5; 16; 1; 20; 12; 11; 17; 8; 11; 13];
%! [beta, R, J, covb, mse] = nlinfit (x, y_noisy, modelfun, beta0)
%! [beta_w, R_w, J_w, covb_w, mse_w] = nlinfit (x, y_noisy, modelfun, beta0, [], "weights", weights)
