## Copyright (C) 2016 Parsiad Azimzadeh <parsiad.azimzadeh@gmail.com>
##
## This program is free software; you can redistribute it and/or modify it under
## the terms of the GNU Lesser General Public License as published by the Free
## Software Foundation; either version 3 of the License, or (at your option) any
## later version.
##
## This program is distributed in the hope that it will be useful, but WITHOUT
## ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
## FITNESS FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License
## for more details.
##
## You should have received a copy of the GNU Lesser General Public License
## along with this program; if not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn  {Function File} {@var{GBM} =} gbm (@var{Return}, @var{Sigma})
## @deftypefnx {Function File} {@var{GBM} =} gbm (@var{Return}, @var{Sigma}, @var{OptionName}, @var{OptionValue}, @dots{})
## Creates an object to represent a geometric Brownian motion (GBM).
##
## @center dX_t = (@var{Return}(t) * X_t)dt + (diag(X_t) * @var{Sigma}(t))dW_t
##
## See the @@sde documentation for a list of optional arguments.
##
## @seealso{sde}
## @end deftypefn

function GBM = gbm (Return, Sigma, varargin)

  if (nargin < 2)
    print_usage ();
  endif

  ## Infer NVARS
  NVARS = 0;
  if (isnumeric (Return))
    NVARS = rows (Return);
  elseif (isnumeric (Sigma))
    NVARS = rows (Sigma);
  else
    NVARS = sdenvars (varargin{:});
  endif

  GBM = cev (Return, ones (NVARS, 1), Sigma, varargin{:});

endfunction

## Options pricing tests
%!test
%! AssetPrice = 100.; RiskFreeRate = 0.04; Dividends = 0.01; Volatility = 0.2; ExpiryTime = 1.;
%! Simulations = 1e6; Timesteps = 10;
%! SDE = gbm (RiskFreeRate - Dividends, Volatility, "StartState", AssetPrice);
%! [Paths, ~, ~] = simByEuler (SDE, 1, "DeltaTime", ExpiryTime, "NTRIALS", Simulations, "NSTEPS", Timesteps, "Antithetic", true);
%! Strike = 100.;
%! CallApproximate = exp (-RiskFreeRate * ExpiryTime) * mean (max (Paths(end, 1, :) - Strike, 0.));
%! [Call, ~] = blsprice (AssetPrice, Strike, RiskFreeRate, ExpiryTime, Volatility, Dividends);
%! assert (CallApproximate, Call, 1e-1);

