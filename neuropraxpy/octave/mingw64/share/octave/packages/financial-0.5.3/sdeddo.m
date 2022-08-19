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
## @deftypefn  {Function File} {@var{SDE} =} sdeddo (@var{DriftRate}, @var{DiffusionRate})
## @deftypefnx {Function File} {@var{SDE} =} sdeddo (@var{DriftRate}, @var{DiffusionRate}, @var{OptionName}, @var{OptionValue}, @dots{})
## Creates an object to represent a stochastic differential equation (SDE) using
## drift and diffusion objects.
##
## @center dX_t = @var{DriftRate}(t, X_t)dt + @var{DiffusionRate}(t, X_t)dW_t.
##
## @itemize
## @item (X_t) is an NVARS-dimensional process;
## @item (W_t) is an NBROWNS-dimensional Wiener process.
## @end itemize
##
## @itemize
## @item
## Variable: @var{DriftRate} A drift object.
## @item
## Variable: @var{DiffusionRate} A diffusion object.
## @end itemize
##
## See the @@sde documentation for a list of optional arguments.
##
## @seealso{drift, diffusion, sde}
## @end deftypefn

function SDE = sdeddo (DriftRate, DiffusionRate, varargin)

  if (nargin < 2)
    print_usage ();
  endif

  if (! isa (DriftRate, "drift"))
    error ("sdeddo: DRIFTRATE must be a drift object");
  endif

  if (! isa (DiffusionRate, "diffusion"))
    error ("sdeddo: DIFFUSIONRATE must be a diffusion object");
  endif

  SDE = sde (DriftRate, DiffusionRate, varargin{:});

endfunction
