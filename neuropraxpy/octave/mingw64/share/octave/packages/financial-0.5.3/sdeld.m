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
## @deftypefn  {Function File} {@var{SDE} =} sdeld (@var{A}, @var{B}, @var{Alpha}, @var{Sigma})
## @deftypefnx {Function File} {@var{SDE} =} sdeld (@var{A}, @var{B}, @var{Alpha}, @var{Sigma}, @var{OptionName}, @var{OptionValue}, @dots{})
## Creates an object to represent a stochastic differential equation (SDE) in
## linear drift-rate form.
##
## @center dX_t = (@var{A}(t) + @var{B}(t) * X_t)dt + (diag(X_t.^@var{Alpha}(t)) * @var{Sigma}(t))dW_t
##
## @itemize
## @item (X_t) is an NVARS-dimensional process;
## @item (W_t) is an NBROWNS-dimensional Wiener process.
## @end itemize
##
## The parameters @var{A} and @var{B} appear in the @@sde/drift documentation.
##
## The parameters @var{Alpha} and @var{Sigma} appear in the @@sde/diffusion
## documentation.
##
## See the @@sde documentation for a list of optional arguments.
##
## @seealso{drift, diffusion, sde}
## @end deftypefn

function SDE = sdeld (A, B, Alpha, Sigma, varargin)

  if (nargin < 4)
    print_usage ();
  endif

  Drift = drift (A, B);
  Diffusion = diffusion (Alpha, Sigma);
  SDE = sde (Drift, Diffusion, varargin{:});

endfunction
