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
## @deftypefn  {Function File} {@var{BM} =} bm (@var{Mu}, @var{Sigma})
## @deftypefnx {Function File} {@var{BM} =} bm (@var{Mu}, @var{Sigma}, @var{OptionName}, @var{OptionValue}, @dots{})
## Creates an object to represent an arithmetic Brownian motion.
##
## @center dX_t = @var{Mu}(t)dt + @var{Sigma}(t)dW_t.
##
## See the @@sde documentation for a list of optional arguments.
##
## @seealso{sde}
## @end deftypefn

function BM = bm (Mu, Sigma, varargin)

  if (nargin < 2)
    print_usage ();
  endif

  ## Infer NVARS
  NVARS = 0;
  if (isnumeric (Mu))
    NVARS = rows (Mu);
  elseif (isnumeric (Sigma))
    NVARS = rows (Sigma);
  else
    NVARS = sdenvars (varargin{:});
  endif

  BM = sdeld (Mu, zeros (NVARS, NVARS), zeros (NVARS, 1), Sigma, varargin{:});

endfunction

