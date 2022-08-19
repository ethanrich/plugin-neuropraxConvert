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
## @deftypefn  {Function File} {@var{semiminoraxis} =} minaxis (@var{semimajoraxis}, @var{ecc}) 
## Return the semiminor axis given the semimmajor axis (a) and eccentricity (ecc).
## 
## Examples 
##
## Scalar input:
## @example
##  earth_a = 6378137; %m
##  earth_ecc = 0.081819221456;
##  earth_b = minaxis (earth_a, earth_ecc)
##  => earth_b = 
##      6.3568e+06
## @end example
##
## Vector input:
## @example
##  planets_a = [ 6378137 ; 66854000 ];
##  planets_ecc = [ 0.081819221456 ; 0.3543164 ];
##  planets_b = minaxis (planets_a , planets_ecc)
##  => planets_b =
##      6.3568e+06
##      6.2517e+07
## @end example
## 
## @seealso{majaxis} 
## @end deftypefn

## Function supplied by anonymous contributor, see:
## https://savannah.gnu.org/patch/index.php?9566
## For background see https://en.wikipedia.org/wiki/Flattening

function b = minaxis (a, ecc)
  
  if (nargin < 2)
    print_usage ();
  end

  if (! isnumeric (a) || ! isreal (a) || ! isnumeric (ecc) || ! isreal (ecc))
    error ("minaxis : numeric input expected");
  elseif (any (ecc < 0) || any (ecc > 1))
    error ("minaxis: eccentricity must lie in interval [0..1]")
  elseif ((length (a) != 1 && length(ecc) != 1) && ((size (a) != size (ecc))))
    error ("minaxis: vectors must be the same size")
  else
    b = a .* sqrt ( 1 - ecc .^ 2 );
  end
  
endfunction

%!test
%!
%! earth_a = 6378137;
%! earth_ecc = 0.081819221456;
%! assert ( minaxis (earth_a, earth_ecc), 6356752.2982157, 10e-8 )
%! planets_a = [ 6378137 ; 66854000 ];
%! planets_ecc = [ 0.081819221456 ; 0.3543164 ];
%! assert ( minaxis (planets_a, planets_ecc), [ 6356752.29821572 ; 62516886.8951319 ], 10e-8 )

%!error <numeric input expected> minaxis (0.5, "ecc")
%!error <numeric input expected> minaxis (0.5, 0.3 + 0.5i)
%!error <numeric input expected> minaxis ("a", 0.5)
%!error <numeric input expected> minaxis (0.3 + 0.5i , 0.5)
%!error <vectors must be the same size> minaxis ( [ 6378137 ; 66854000 ], [ 0.081819221456 ; 0.3543164 ]')
%!error <eccentricity must lie> minaxis ([10; 10; 10], [0.5; 0; -0.5])
