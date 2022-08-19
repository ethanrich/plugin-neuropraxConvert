## Copyright (C) 2018-2022 Philip Nienhuis
## 
## This program is free software; you can redistribute it and/or modify it under
## the terms of the GNU General Public License as published by the Free Software
## Foundation; either version 3 of the License, or (at your option) any later
## version.
## 
## This program is distributed in the hope that it will be useful, but WITHOUT
## ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
## FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
## details.
## 
## You should have received a copy of the GNU General Public License along with
## this program; if not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} {@var{psi} =}  geocentricLatitude (@var{phi}, @var{flattening}) 
## @deftypefnx {Function File} {@var{psi} =}  geocentricLatitude (@var{phi}, @var{flattening}, @var{angleUnit}) 
## Return geocentric latitude (psi) given geodetic latitude (phi) and flattening.
##
## The default input and output is in degrees; use optional third parameter
## @var{angleUnit} for radians.  @var{phi} can be a scalar, vector, matrix or
## any ND array.  @var{flattening} must be a scalar value in the interval
## [0..1).
##
## Examples 
## Scalar input:
## @example
## psi = geocentricLatitude (45, 0.0033528)
## => psi =
##  44.8076
## @end example
##
## Also can use radians:
## @example
## psi = geocentricLatitude (pi/4, 0.0033528, "radians")
## => psi =
##  0.78204
## @end example
##
## Vector Input:
## @example
## phi = 35:5:45;
## psi = geocentricLatitude (phi, 0.0033528)
## => psi =
##  34.819      39.811      44.808
## @end example
##
## @seealso{parametricLatitude, geodeticLatitudeFromGeocentric, geodeticLatitudeFromParametric} 
## @end deftypefn

## Function supplied by anonymous contributor, see:
## https://savannah.gnu.org/patch/index.php?9640

function psi = geocentricLatitude (phi, flattening, angleUnit="degrees")

  if (nargin < 2 || isempty (angleUnit))
    print_usage ();
  endif
  
  if (! isnumeric (phi) || ! isreal (phi) || ...
      ! isnumeric (flattening) || ! isreal (flattening))
    error ("geocentricLatitude: numeric input expected for args #1 and #2");
  elseif (! isscalar (flattening))
    error ("geocentricLatitude: scalar value expected for flattening");
  elseif (flattening < 0 || flattening >= 1)
    error ("geocentricLatitude: flattening must lie in the real interval [0..1)" )
  elseif (! ischar (angleUnit) || ! ismember (lower (angleUnit(1)), {"d", "r"}))
    error ("geocentricLatitude: angleUnit should be one of 'degrees' or 'radians'");
  endif

  ## Make sure phi and (later on) flattening are element-wise conformant
  if (strncmpi (angleUnit, "r", 1) == 1)
    ## Insight From: Fundamentals of Astrodynamics and Applications,
    ## (David Vallado 3rd edition pg 148)
    psi = atan ((1 - flattening)^2 * tan (phi));
  else
    psi = atand ((1 - flattening)^2 * tand (phi));
  end
  
endfunction


%!test
%! earth_flattening = 0.0033528;
%! assert (geocentricLatitude (45, earth_flattening), 44.8075766, 10e-6);
%! assert (geocentricLatitude (pi/4, earth_flattening, 'radians'), 0.78204, 10e-6);

%!error <numeric input expected> geocentricLatitude (0.5, "flat")
%!error <numeric input expected> geocentricLatitude (0.5, 5i)
%!error <numeric input expected> geocentricLatitude ("phi", 0.0033528)
%!error <numeric input expected> geocentricLatitude (5i, 0.0033528 )
%!error <scalar value expected> geocentricLatitude ([45 50], [0.7 0.8])
%!error <flattening must lie> geocentricLatitude (45, 1)
%!error <angleUnit> geocentricLatitude (45, 0.0033528, "km")
