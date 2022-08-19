## Copyright (C) 2015 Parsiad Azimzadeh <parsiad.azimzadeh@gmail.com>
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
## @deftypefn  {Function File} {@var{DiffusionRate} =} diffusion (@var{Alpha}, @var{Sigma})
## Creates an object to represent the diffusion rate of a stochastic
## differential equation (SDE).
##
## @center @var{DiffusionRate}(t, X_t) = diag(X_t.^Alpha(t)) * V(t)
## @center dX_t = DriftRate(t, X_t)dt + @var{DiffusionRate}(t, X_t)dW_t.
##
## @itemize
## @item (X_t) is an NVARS-dimensional process;
## @item (W_t) is an NBROWNS-dimensional Wiener process.
## @end itemize
##
## @itemize
## @item
## Variable: @var{Alpha} An NVARS-by-1 vector or a function. As a function,
## @var{Alpha} returns an NVARS-by-1 vector and has either exactly one input
## (time: @var{Alpha}(t)) or exactly two inputs (time and space:
## @var{Alpha}(t, X_t)).
## @item
## Variable: @var{Sigma} An NVARS-by-NBROWNS matrix or a function. As a
## function, @var{Sigma} returns an NVARS-by-NBROWNS matrix and has either
## exactly one input (time: @var{Sigma}(t)) or exactly two inputs (time and
## space: @var{Sigma}(t, X_t)).
## @end itemize
##
## @seealso{drift}
## @end deftypefn

function DiffusionRate = diffusion (Alpha, Sigma)

  ## Check number of arguments
  if (nargin != 2)
    print_usage();
  endif

  if (iscolumn (Alpha) && isreal (Alpha))
    DiffusionRate.Alpha = @(t, X) Alpha;
    DiffusionRate.IsAlphaConstant = true;
  elseif (isa (Alpha, "function_handle") && nargin (Alpha) == 1)
    DiffusionRate.Alpha = @(t, X) Alpha(t);
    DiffusionRate.IsAlphaConstant = false;
  elseif (isa (Alpha, "function_handle") && nargin (Alpha) == 2)
    DiffusionRate.Alpha = Alpha;
    DiffusionRate.IsAlphaConstant = false;
  else
    error ("diffusion: Alpha must either be a real column vector or a function of one or two arguments returning such a vector.");
  endif

  if (ismatrix (Sigma) && isreal (Sigma) && ((! isreal (Alpha)) || size (Sigma, 1) == size (Alpha, 1)))
    DiffusionRate.Sigma = @(t, X) Sigma;
    DiffusionRate.IsSigmaConstant = true;
  elseif (isa (Sigma, "function_handle") && nargin (Sigma) == 1)
    DiffusionRate.Sigma = @(t, X) Sigma(t);
    DiffusionRate.IsSigmaConstant = false;
  elseif (isa (Sigma, "function_handle") && nargin (Sigma) == 2)
    DiffusionRate.Sigma = Sigma;
    DiffusionRate.IsSigmaConstant = false;
  else
    error ("diffusion: Sigma must either be a real matrix with number of rows equal to the dimension of Alpha or a function of one or two arguments returning such a matrix.");
  endif

  DiffusionRate.Rate = @(t, X) bsxfun (@times, DiffusionRate.Sigma (t, X), ...
                                       bsxfun (@power, X, DiffusionRate.Alpha (t, X)));

  DiffusionRate = class (DiffusionRate, "diffusion");

endfunction

