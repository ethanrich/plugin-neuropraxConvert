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
## @deftypefn  {Function File} {@var{flat} =} flat2ecc (@var{ecc}) 
## Return flattening given an eccentricity 
##
## Exmples:
##
## Scalar input:
## @example
##  e_earth = .081819221456;
##  f_earth = ecc2flat (e_earth) 
##  => f_earth = 0.0033528 
## @end example
##
## Vector input:
## @example
##  ec = 0 : .01 : .05;
##  f = ecc2flat (ec)
##  => f =
##        0.0000000   0.0000500   0.0002000   0.0004501   0.0008003   0.0012508
## @end example
## 
## @seealso{flat2ecc}
## @end deftypefn

## Function supplied by anonymous contributor, see:
## https://savannah.gnu.org/patch/index.php?9492

function ff = ecc2flat (ec)  

  if nargin < 1
    print_usage ();
  endif

  if (! isnumeric (ec))
    error ("ecc2flat: numeric input expected");
  elseif (any (ec < 0) || any (ec >= 1))
    error ("ecc2flat: eccentricity must lie in the real interval [0..1)");
  else
    ff = 1 - sqrt (1 - ec.^2);
  endif

endfunction 

%!test
%! ec = 0.081819221456;
%! ev = 0 : 0.01 : 0.05;
%! assert (ecc2flat (ec), 0.00335281317793612, 10^-12);
%! assert (ecc2flat (ev), [0, 5e-5, 2e-4, 4.501e-4, 8.0032e-4, 0.00125078], 10^-6);

%!error <numeric input expected> ecc2flat ("a")
%!error <eccentricity> ecc2flat(1)
