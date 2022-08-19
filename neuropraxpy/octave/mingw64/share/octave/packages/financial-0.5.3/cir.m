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
## @deftypefn  {Function File} {@var{CIR} =} cir (@var{Speed}, @var{Level}, @var{Sigma})
## @deftypefnx {Function File} {@var{CIR} =} cir (@var{Speed}, @var{Level}, @var{Sigma}, @var{OptionName}, @var{OptionValue}, @dots{})
## Creates an object to represent a Cox-Ingersoll-Ross (CIR) mean-reverting
## square root diffusion.
##
## @center dX_t = (@var{Speed}(t) * (@var{Level}(t) - X_t))dt + (diag(X_t.^1/2) * @var{Sigma}(t))dW_t.
##
## See the @@sde documentation for a list of optional arguments.
##
## @seealso{sde}
## @end deftypefn

function CIR = cir (Speed, Level, Sigma, varargin)

  if (nargin < 3)
    print_usage ();
  endif

  ## Infer NVARS
  NVARS = 0;
  if (isnumeric (Speed))
    NVARS = rows (Speed);
  elseif (isnumeric (Level))
    NVARS = rows (Level);
  elseif (isnumeric (Sigma))
    NVARS = rows (Sigma);
  else
    NVARS = sdenvars (varargin{:});
  endif

  CIR = sdemrd (Speed, Level, ones (NVARS, 1) * .5, Sigma, varargin{:});

endfunction

## Bond pricing test
%!test
%! InitialInterestRate = 0.03; Speed = 1.; MeanInterestRate = 0.04; Volatility = 0.3; ExpiryTime = 1.;
%! Simulations = 1e4; Timesteps = 100;
%! SDE = cir (Speed, MeanInterestRate, Volatility, "StartState", InitialInterestRate);
%! [Paths, ~, ~] = simByEuler (SDE, Timesteps, "DeltaTime", ExpiryTime / Timesteps, "NTRIALS", Simulations, "NSTEPS", 1, "Antithetic", true, "Processes", @(t, X) max(X, 0));
%! BondApproximate = mean (exp (-(sum (Paths) - InitialInterestRate) * ExpiryTime / Timesteps));
%! h = sqrt (Speed * Speed + 2 * Volatility * Volatility);
%! d = (2 * h + (Speed + h) * (exp (ExpiryTime * h) - 1));
%! A = ( (2 * h * exp ((Speed + h) * ExpiryTime / 2)) / d )^((2 * Speed * MeanInterestRate) / (Volatility * Volatility));
%! B = 2 * (exp (ExpiryTime * h) - 1) / d;
%! Bond = A * exp (-B * InitialInterestRate);
%! assert (BondApproximate, Bond, 1e-3);

