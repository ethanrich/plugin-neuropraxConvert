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
## @deftypefn  {Function File} {@var{semimajoraxis} =} majaxis (@var{semiminoraxis}, @var{ecc}) 
## Return the semimajor axis given the semiminoraxis (b) and eccentricity (e).
##
## Examples 
##
## Scalar input:
## @example
##  earth_b = 6356752.314245;  ## meter
##  earth_ecc = 0.081819221456;
##  a = majaxis (earth_b, earth_ecc)
##  => a =
##   6.3781e+06
## @end example
##
## Vector input:
## @example
##  planets_b = [ 6356752.314245 ; 66854000 ]; ## meter
##  planets_ecc = [ 0.081819221456 ; 0.3543164 ];
##  planets_a = majaxis ( planets_b , planets_ecc )
##  => planets_a =
##      6.3781e+06
##      7.1492e+07
## @end example
##  
## @seealso{minaxis} 
## @end deftypefn

## Function supplied by anonymous contributor, see:
## https://savannah.gnu.org/patch/index.php?9566
## For background see https://en.wikipedia.org/wiki/Flattening

function a = majaxis (b, ecc)

  if (nargin < 2)
    print_usage ();
  end

  if (! isnumeric (b) || ! isreal (b) || ! isnumeric (ecc) || ! isreal (ecc))
    error ( "majaxis : numeric input expected");
  elseif (any (ecc < 0) || any (ecc > 1))
    error ( "majaxis: eccentricity must lie in the real interval [0..1]" )
  elseif ((length (b) != 1 && length (ecc) != 1) && ((size (b) != size (ecc))))
    error ("majaxis: vectors must be the same size")
  else
    a = b ./ sqrt (1 - ecc .^ 2);
  end
  
endfunction

%!test
%!
%! earth_b = 6356752.314245;  ## meter
%! earth_ecc = 0.081819221456;
%! assert ( majaxis (earth_b, earth_ecc), 6378137.01608, 10e-6);
%! planets_b = [ 6356752.314245 ; 66854000 ]; ## meter
%! planets_ecc = [ 0.081819221456 ; 0.3543164 ];
%! assert( majaxis (planets_b, planets_ecc), [ 6378137.01608; 71492000.609327 ], 10e-6 );

%!error <numeric input expected> majaxis (0.5, "ecc")
%!error <numeric input expected> majaxis (0.5, 0.3 + 0.5i)
%!error <numeric input expected> majaxis ("b", 0.5)
%!error <numeric input expected> majaxis (0.3 + 0.5i , 0.5)
%!error <eccentricity must lie> majaxis ([10; 10; 10], [0.5; 0; -0.5])
%!error <vectors must be the same size> minaxis ( [ 6356752.314245 ; 66854000 ] , [ 0.081819221456 ; 0.3543164 ]')