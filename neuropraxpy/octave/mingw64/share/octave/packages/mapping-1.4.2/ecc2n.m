## Copyright (C) 2018-2022 Philip Nienhuis
##
## This program is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or (at
## your option) any later version.
##
## This program is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
## General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; see the file COPYING.  If not, see
## <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} {@var{n} =} ecc2n (@var{ecc})
## This returns the third flattening given an eccentricity.
##
## Examples:
##
## Scalar input:
## @example
##  e_earth = 0.081819221456;
##  n_earth = ecc2n (e_earth)
##  => n_earth = 0.0016792
## @end example 
##
## Vector input:
## @example
##  e_vec = [ 0.081819221456  0.3543164 ]
##  n = ecc2n (e_vec)
##  => n =
##	 0.0016792    0.033525
## @end example
##
## @seealso{n2ecc}
## @end deftypefn

## Function supplied by anonymous contributor, see:
## https://savannah.gnu.org/patch/index.php?9566
## For background see https://en.wikipedia.org/wiki/Flattening

function n = ecc2n ( ecc )
  
  if (nargin < 1)
    print_usage ();
  end
  
  if (! isnumeric (ecc) || ! isreal (ecc))
    error ("ecc2n: numeric input expected");
  elseif (any (ecc < 0) || any (ecc > 1))
    error ("ecc2n: eccentricity should lie in real interval [0..1]")
  else
    B = (4 ./ ecc.^2 - 2); ## Taken from e^2 = 4n / (1+n)^2
    ## Use to get in the form n^2 - Bn + 1 = 0
    ## From testing the other definition of third flattening (a-b)/(a+b)
    ## Use the - version for the quadratic equation
    n = (B - sqrt (B .^2 - 4)) ./ 2;
  end

endfunction

%!test
%!
%! ecc_earth = .081819221456;
%! ecc_jupiter =  0.3543164;
%! e_vec = [ ecc_earth ecc_jupiter ];
%! assert ( ecc2n ( ecc_earth ) , 0.001679222 , 10e-10 ); 
%! assert ( ecc2n ( e_vec ), [0.0016792    0.03352464],10e-8);

%!error <numeric input expected> ecc2n ("ecc")
%!error <numeric input expected> ecc2n (0.5 + 3i)
%!error <n should lie> n2ecc (-1)
%!error <n should lie> n2ecc (2)
%!error <n should lie> n2ecc (-Inf)
%!error <n should lie> n2ecc (Inf)

