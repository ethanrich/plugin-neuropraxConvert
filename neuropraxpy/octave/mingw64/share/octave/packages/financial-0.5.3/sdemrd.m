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
## @deftypefn  {Function File} {@var{SDE} =} sdemrd (@var{Speed}, @var{Level}, @var{Alpha}, @var{Sigma})
## @deftypefnx {Function File} {@var{SDE} =} sdemrd (@var{Speed}, @var{Level}, @var{Alpha}, @var{Sigma}, @var{OptionName}, @var{OptionValue}, @dots{})
## Creates an object to represent a stochastic differential equation (SDE) in
## in mean-reverting drift-rate form.
##
## @center dX_t = (@var{Speed}(t) * (@var{Level}(t) - X_t))dt + (diag(X_t.^@var{Alpha}(t)) * @var{Sigma}(t))dW_t.
##
## @itemize
## @item (X_t) is an NVARS-dimensional process;
## @item (W_t) is an NBROWNS-dimensional Wiener process.
## @end itemize
##
## @itemize
## @item
## Variable: @var{Speed} An NVARS-by-NVARS matrix or a function. As a function,
## @var{Speed} returns an NVARS-by-NVARS matrix and has either exactly one input
## (time: @var{Speed}(t)) or exactly two inputs (time and space:
## @var{Speed}(t, X_t)).
## @item
## Variable: @var{Level} An NVARS-by-1 vector or a function. As a function,
## @var{Level} returns an NVARS-by-1 vector and has either exactly one input
## (time: @var{Level}(t)) or exactly two inputs (time and space:
## @var{Level}(t, X_t)).
## @end itemize
##
## The parameters @var{Alpha} and @var{Sigma} appear in the @@sde/diffusion
## documentation.
##
## See the @@sde documentation for a list of optional arguments.
##
## @seealso{drift, diffusion, sde}
## @end deftypefn

function SDE = sdemrd (Speed, Level, Alpha, Sigma, varargin)

  if (nargin < 4)
    print_usage ();
  endif

  if (ismatrix (Speed) && isreal (Speed))
    SpeedFunction = @(t, X) Speed;
    NegativeSpeed = @(t, X) -Speed;
  elseif (isa (Speed, "function_handle") && nargin (Speed) == 1)
    SpeedFunction = @(t, X) Speed (t);
    NegativeSpeed = @(t, X) -Speed (t);
  elseif (isa (Speed, "function_handle") && nargin (Speed) == 2)
    SpeedFunction = Speed;
    NegativeSpeed = -Speed;
  else
    error ("sdemrd: SPEED must either be a real matrix or a function of one or two arguments returning such a matrix.");
  endif

  if (iscolumn (Level) && isreal (Level))
    LevelFunction = @(t, X) Level;
  elseif (isa (Level, "function_handle") && nargin (Level) == 1)
    LevelFunction = @(t, X) Level (t);
  elseif (isa (Level, "function_handle") && nargin (Level) == 2)
    LevelFunction = Level;
  else
    error ("sdemrd: LEVEL must either be a real column vector or a function of one or two arguments returning such a vector.");
  endif

  SpeedLevel = @(t, X) SpeedFunction (t, X) * LevelFunction (t, X);

  Drift = drift (SpeedLevel, NegativeSpeed);
  Diffusion = diffusion (Alpha, Sigma);
  SDE = sde (Drift, Diffusion, varargin{:});

endfunction
