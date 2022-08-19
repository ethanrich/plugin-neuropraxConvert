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
## @deftypefn {Function File} {@var{phi} =} geodeticLatitudeFromParametric (@var{beta}, @var{flattening}) 
## @deftypefnx {Function File} {@var{phi} =} geodeticLatitudeFromParametric (@var{beta}, @var{flattening}, @var{angleUnit}) 
## Returns geodetic latitude (phi) given parametric latitude and flattening.
##
## Parametric latitude (@var{beta}) is also known as a reduced latitude.
## The default input and output is in degrees; use optional third parameter
## @var{angleUnit} for radians.  @var{beta} can be a scalar, vector, matrix
## or any ND array.  @var{flattening} must be a scalar value in the interval
## [0..1).
##
## Examples:
## Scalar input:
## @example
## phi = geodeticLatitudeFromParametric (45, 0.0033528)
## => phi =
##  45.096
## @end example
##
## Also can use radians:
## @example
## phi = geodeticLatitudeFromParametric (pi/4, 0.0033528, "radians")
## => phi =
##  0.78708
## @end example
##
## Vector Input:
## @example
## beta = 35:5:45;
## phi = geodeticLatitudeFromParametric (beta, 0.0033528)
## => phi =
##  35.09      40.095      45.096
## @end example
##
## @seealso{geocentricLatitude, geodeticLatitudeFromGeocentric, parametricLatitude} 
## @end deftypefn

## Function supplied by anonymous contributor, see:
## https://savannah.gnu.org/patch/index.php?9640

function phi = geodeticLatitudeFromParametric (beta, flattening, angleUnit="degrees")
  
  if (nargin < 2)
    print_usage ();
  endif

  if (! isnumeric (beta) || ! isreal (beta) || ...
      ! isnumeric (flattening) || ! isreal (flattening))
    error ("geodeticLatitudeFromParametric : numeric input expected");
  elseif (! isscalar (flattening))
    error ("geodeticLatitudeFromParametric: scalar value expected for flattening");
  elseif (flattening < 0 || flattening >= 1)
    error ("geodeticLatitudeFromParametric: flattening must lie in the real interval [0..1)" );
  elseif (! ischar (angleUnit) ||! ismember (lower (angleUnit(1)), {"d", "r"}))
    error ("geodeticLatitudeFromParametric: angleUnit should be one of 'degrees' or 'radians'");
  endif

  if (strncmpi (angleUnit, "r", 1) == 1)
    phi = atan2 (tan (beta), (1 - flattening)) ;
  else 
    phi = atan2d (tand (beta), (1 - flattening)) ;
  endif
  
endfunction

%!test
%! earth_flattening  =  0.0033528 ;
%! assert ( geodeticLatitudeFromParametric (45, earth_flattening), 45.0962122, 10e-6);
%! assert ( geodeticLatitudeFromParametric (pi/4, earth_flattening, 'radians'), 0.78708, 10e-6);

%!error <numeric input expected> geodeticLatitudeFromParametric (0.5, "flat")
%!error <numeric input expected> geodeticLatitudeFromParametric (0.5, 5i)
%!error <numeric input expected> geodeticLatitudeFromParametric ("beta", 0.0033528)
%!error <numeric input expected> geodeticLatitudeFromParametric (5i, 0.0033528 )
%!error <scalar value expected> geodeticLatitudeFromParametric ([45 50], [0.7 0.8])
%!error <flattening must lie> geodeticLatitudeFromParametric (45, 1)
%!error <angleUnit> geodeticLatitudeFromParametric (45, 0.0033528, "km")
