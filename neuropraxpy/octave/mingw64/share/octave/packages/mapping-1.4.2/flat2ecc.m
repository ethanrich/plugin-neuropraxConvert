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
## @deftypefn  {Function File} {@var{ecc} =} flat2ecc (@var{flat}) 
## Return the eccentricity given a flattening
##
## Examples:
##
## Scalar input:
## @example
##    f_earth = 0.0033528;
##    flat2ecc (f_earth)
##    => 0.081819
## @end example
##
## Vector input:
## @example
##    flat = 0 : .01 : .05;
##    flat2ecc (flat)
##    ans =
##       0.00000   0.14107   0.19900   0.24310   0.28000   0.31225
## @end example
##
## @seealso{ecc2flat}
## @end deftypefn

## Function supplied by anonymous contributor, see:
## https://savannah.gnu.org/patch/index.php?9492

function ec = flat2ecc (fl)

  if nargin < 1
    print_usage ();
  endif

  if ( ischar ( fl ) )
    error ("flat2ecc: numeric input expected");
  elseif (any (fl < 0) || any (fl >= 1))
    error ("flat2ecc: flattening must lie in the real interval [0..1)")
  else
    ec = sqrt (2 * fl - fl .^ 2);
  endif

  endfunction

%!test
%! flat = 0.00335281317793612; 
%! f_vec = 0:.01:.05;
%! assert (flat2ecc (flat), 0.0818192214560008, 10^-12 )
%! assert (flat2ecc (f_vec), [0 , .141067, .198997, .2431049, .28, .31225], 10^-6);

%!error <numeric input expected> flat2ecc ("a")
%!error <flattening> flat2ecc(1)
