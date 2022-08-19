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
## @deftypefn  {Function File} {@var{heston} =} heston (@var{Return}, @var{Speed}, @var{Level}, @var{Volatility})
## @deftypefnx {Function File} {@var{heston} =} heston (@var{Return}, @var{Speed}, @var{Level}, @var{Volatility}, @var{OptionName}, @var{OptionValue}, @dots{})
## Creates an object to represent a Heston stochastic volatility model.
##
## @center dX_1 = (@var{Return}(t) * X_1)dt + (sqrt (X_2) * X_1)dW_1;
## @center dX_2 = (@var{Speed}(t) * (@var{Level}(t) - X_2))dt + (sqrt (X_2) * @var{Volatility}(t))dW_2.
##
## See the @@sde documentation for a list of optional arguments.
##
## @seealso{sde}
## @end deftypefn

function heston = heston (Return, Speed, Level, Volatility, varargin)

  if (nargin < 4)
    print_usage ();
  endif

  if (isscalar (Return) && isreal (Return))
    ReturnFunction = @(t, X) Return;
  elseif (isa (Return, "function_handle") && nargin (Return) == 1)
    ReturnFunction = @(t, X) Return (t);
  elseif (isa (Return, "function_handle") && nargin (Return) == 2)
    ReturnFunction = Return;
  else
    error ("heston: RETURN must either be a real scalar or a function of one or two arguments returning such a scalar");
  endif

  if (isscalar (Speed) && isreal (Speed))
    SpeedFunction = @(t, X) Speed;
  elseif (isa (Speed, "function_handle") && nargin (Speed) == 1)
    SpeedFunction = @(t, X) Speed (t);
  elseif (isa (Speed, "function_handle") && nargin (Speed) == 2)
    SpeedFunction = Speed;
  else
    error ("heston: SPEED must either be a real scalar or a function of one or two arguments returning such a scalar");
  endif

  if (isscalar (Level) && isreal (Level))
    LevelFunction = @(t, X) Level;
  elseif (isa (Level, "function_handle") && nargin (Level) == 1)
    LevelFunction = @(t, X) Level (t);
  elseif (isa (Level, "function_handle") && nargin (Level) == 2)
    LevelFunction = Level;
  else
    error ("heston: LEVEL must either be a real scalar or a function of one or two arguments returning such a scalar");
  endif

  if (isscalar (Volatility) && isreal (Volatility))
    VolatilityFunction = @(t, X) Volatility;
  elseif (isa (Volatility, "function_handle") && nargin (Volatility) == 1)
    VolatilityFunction = @(t, X) Volatility (t);
  elseif (isa (Volatility, "function_handle") && nargin (Volatility) == 2)
    VolatilityFunction = Volatility;
  else
    error ("heston: VOLATILITY must either be a real scalar or a function of one or two arguments returning such a scalar");
  endif

  ## TODO: Optimize
  Drift = @(t, X) [ReturnFunction(t, X) * X(1); SpeedFunction(t, X) * (LevelFunction(t, X) - X(2))];
  Diffusion = @(t, X) [sqrt(X(2)) * X(1) 0.;0. VolatilityFunction(t, X) * sqrt(X(2))];

  heston = sde (Drift, Diffusion, varargin{:});

endfunction
