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
## @deftypefn {Function File} {@var{beta} =} parametricLatitude (@var{phi}, @var{flattening}) 
## @deftypefnx {Function File} {@var{beta} =} parametricLatitude (@var{phi}, @var{flattening}, @var{angleUnit}) 
## Returns parametric latitude given geodetic latitude (phi) and flattening.
##
## The parametric latitude @var{beta} is also known as a reduced latitude.
## The default input and output is in degrees; use optional third parameter
## @var{angleUnit} for radians.  @var{phi} can be a scalar, vector, matrix
## or any ND array.  @var{flattening} must be a scalar value in the interval
## [0..1).
##
## Examples:
## Scalar input:
## @example
## beta = parametricLatitude (45, 0.0033528)
## => beta =
##  44.904
## @end example
##
## Also can use radians:
## @example
## beta = parametricLatitude (pi/4, 0.0033528, "radians")
## => beta =
##  0.78372
## @end example
##
## Vector Input:
## @example
## phi = 35:5:45;
## beta = parametricLatitude (phi, 0.0033528)
## => beta =
##  34.91      39.905      44.904
## @end example
## @seealso{geocentricLatitude , geodeticLatitudeFromGeocentric , geodeticLatitudeFromParametric} 
## @end deftypefn

## Function supplied by anonymous contributor, see:
## https://savannah.gnu.org/patch/index.php?9640

function beta = parametricLatitude (phi, flattening, angleUnit="degrees")
  
  if (nargin < 2)
    print_usage ();
  endif
 
  if (! isnumeric (phi) || ! isreal (phi) || ...
      ! isnumeric (flattening) || ! isreal (flattening))
    error ("parametricLatitude : numeric input expected");
  elseif (! isscalar (flattening))
    error ("parametricLatitude: scalar value expected for flattening");
  elseif (flattening < 0 || flattening >= 1)
    error ("parametricLatitude: flattening must lie in the real interval [0..1)" );
  elseif (! ischar (angleUnit) ||! ismember (lower (angleUnit(1)), {"d", "r"}))
    error ("parametricLatitude: angleUnit should be one of 'degrees' or 'radians'");
  endif

  if (strncmpi (angleUnit, "r", 1) == 1)
    ## From: Algorithms for global positioning. Kai Borre and Gilbert Strang pg 371 
    beta = atan ((1 - flattening) * tan (phi));
  else
    beta = atand ((1 - flattening) * tand (phi));
  end
  

endfunction

%!test
%! earth_flattening = 0.0033528 ;
%! assert (parametricLatitude (45, earth_flattening), 44.903787, 10e-6)
%! assert (parametricLatitude (pi/4, earth_flattening, 'radians'), 0.78372, 10e-6)

%!error <numeric input expected> parametricLatitude (0.5, "flat")
%!error <numeric input expected> parametricLatitude (0.5, 5i)
%!error <numeric input expected> parametricLatitude ("phi", 0.0033528)
%!error <numeric input expected> parametricLatitude (5i, 0.0033528 )
%!error <scalar value expected> parametricLatitude ([45 50], [0.7 0.8])
%!error <flattening must lie> parametricLatitude (45, 1)
%!error <angleUnit> parametricLatitude (45, 0.0033528, "km")
