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
## @deftypefn {Function File} {@var{ecc} =} n2ecc (@var{n})
## This returns the eccentricity given the third flattening (n).
##
## Examples:
##
## Scalar input:
## @example
##  n_earth = 0.0016792;
##  ecc_earth = n2ecc (n_earth)
##  => ecc_earth = 0.081819
## @end example 
##
## Vector input:
## @example
##  n_vec = [ 0.0016792 0.033525 ];
##  ecc = n2ecc (n_vec)
##  => ecc =
##	 0.081819     0.35432
## @end example
##
## @seealso{n2ecc}
## @end deftypefn

## Function supplied by anonymous contributor, see:
## https://savannah.gnu.org/patch/index.php?9566
## For background see https://en.wikipedia.org/wiki/Flattening

function ecc = n2ecc (n)

  if (nargin < 1)
    print_usage ();
  end
  if (! isnumeric (n) || ! isreal (n) )
    error ("n2ecc: numeric input expected");
  elseif (any (n < 0) || any (n > 1))
    error ("n2ecc: n should lie in the real interval [0..1]" )
  else
    ecc = sqrt (4 * n ./ (1 + n) .^2);
  end
  
endfunction

%!test
%!
%! n_earth = 0.001679221647179929;
%! n_jupiter = 0.03352464537391420;
%! n_vec = [ n_earth  n_jupiter ];
%! assert (n2ecc (n_earth) , .081819221456 , 10e-12); 
%! assert (n2ecc (n_vec), [0.08181922 0.3543164], 10e-8)

%!error <numeric input expected> n2ecc ("n")
%!error <numeric input expected> n2ecc (0.5 + 3i)
%!error <n should lie> n2ecc (-1)
%!error <n should lie> n2ecc (2)
%!error <n should lie> n2ecc (-Inf)
%!error <n should lie> n2ecc (Inf)

