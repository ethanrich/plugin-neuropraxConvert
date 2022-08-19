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
## @deftypefn {Function File} {@var{phi} =}  geodeticLatitudeFromGeocentric (@var{psi}, @var{flattening}) 
## @deftypefnx {Function File} {@var{phi} =}  geodeticLatitudeFromGeocentric (@var{psi}, @var{flattening}, @var{angleUnit}) 
## Return geodetic latitude (phi) given geocentric latitude (psi) and flattening.
##
## The default input and output is in degrees; use optional third parameter
## @var{angleUnit} for radians.  @var{psi} can be a scalar, vector, matrix or
## any ND array.  @var{flattening} must be a scalar value in the interval
## [0..1).
##
## Examples 
## Scalar input:
## @example
## phi = geodeticLatitudeFromGeocentric (45, 0.0033528)
## => phi =
##   45.192
## @end example
##
## Also can use radians:
## @example
## phi = geodeticLatitudeFromGeocentric (pi/4, 0.0033528, "radians")
## => phi =
##  0.78876
## @end example
##
## Vector Input:
## @example
## psi = 35:5:45;
## phi = geodeticLatitudeFromGeocentric (psi, 0.0033528)
## => phi =
##  35.181       40.19      45.192
## @end example
##
## @seealso{geocentricLatitude, geodeticLatitudeFromGeocentric, parametricLatitude} 
## @end deftypefn

## Function supplied by anonymous contributor, see:
## https://savannah.gnu.org/patch/index.php?9640

function phi = geodeticLatitudeFromGeocentric (psi, flattening, angleUnit="degrees")

  if (nargin < 2 || isempty (angleUnit))
    print_usage ();
  endif
  
  if (! isnumeric (psi) || ! isreal (psi) || ...
      ! isnumeric (flattening) || ! isreal (flattening))
    error ("geodeticLatitudeFromGeocentric: numeric input expected");
  elseif (! isscalar (flattening))
    error ("geodeticLatitudeFromGeocentric: scalar value expected for flattening");
  elseif (flattening < 0 || flattening >= 1)
    error ( "geodeticLatitudeFromGeocentric: flattening must lie in the real interval [0..1)" )
  elseif (! ischar (angleUnit) ||! ismember (lower (angleUnit(1)), {"d", "r"}))
    error ("geodeticLatitudeFromGeocentric: angleUnit should be one of 'degrees' or 'radians'");
  endif

  if (strncmpi (angleUnit, "r", 1) == 1)
    phi = atan2 (tan (psi), (1 - flattening) ^ 2);
  else 
    phi = atan2d (tand (psi), (1 - flattening) ^ 2);
  endif 

endfunction


%!test
%! earth_flattening = 0.0033528;
%! assert (geodeticLatitudeFromGeocentric (45, earth_flattening), 45.1924226, 10e-6);
%! assert (geodeticLatitudeFromGeocentric (pi/4, earth_flattening, 'radians'), 0.78876, 10e-6);

%!error <numeric input expected> geodeticLatitudeFromGeocentric (0.5, "flat")
%!error <numeric input expected> geodeticLatitudeFromGeocentric (0.5, 5i )
%!error <numeric input expected> geodeticLatitudeFromGeocentric ("psi", 0.0033528)
%!error <numeric input expected> geodeticLatitudeFromGeocentric (5i, 0.0033528 )
%!error <scalar value expected> geodeticLatitudeFromGeocentric ([45 50], [0.7 0.8])
%!error <flattening must lie> geodeticLatitudeFromGeocentric (45, 1)
%!error <angleUnit> geodeticLatitudeFromGeocentric (45, 0.0033528 ,"km")
