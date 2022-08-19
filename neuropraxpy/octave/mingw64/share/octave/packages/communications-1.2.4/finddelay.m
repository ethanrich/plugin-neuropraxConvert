## Copyright (C) 2021 The Octave Project Developers
## Copyright (C) 2006 Robert T. Short <rtshort@ieee.org>
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
## @deftypefn {Function File} {@var{d} =} finddelay (@var{x}, @var{y})
## Estimate the delay between times series @var{x} and time series @var{y} by
## correlating and finding the peak.  The index of the peak correlation
## is returned in @var{d}.
##
## Inputs:
## @itemize         
## @var{x}, @var{y}: signals
## @end itemize
##
## Output:
## @itemize
## @var{d}: The delay between the two signals
## @end itemize
## 
## Example:
## @example
## x = [0, 0, 1, 2, 3];
## y = [1, 2, 3];
## d = finddelay (x, y)
## d = -2
## @end example
## @seealso{xcorr}
## @end deftypefn

function d = finddelay (x, y)

  ## Check arguments and set defaults.

  if (nargin != 2)
    print_usage();
  endif
  
  [R, lag] = xcorr (x, y);
  d = -(lag(R == max (R)));
  
  if (abs (d) == 0) #TODO better method for L52 so no -0
    d = 0;
  endif
  
  d = min (d);
  
  ## zLs method passes 2 of 4 tests
  ## [R, lag] = xcorr(x, y);
  ## [a b] = max(R);
  ## D = abs (b - length(x)); 
  
  ## Robert Short method passes 1 of 4 tests
  ## x = x(:); 
  ## y = y(:);
  ## N1 = length (x);     % total data length
  ## N2 = length (y);     % 
  ## c = zeros (N2- N1 + 1, 1);
  
  ## for (idx = 1: N2 - N1)
  ##   c(idx) = x'*y(idx: idx + N1 - 1) / N1;
  ## end
  ## [m, d] = max (abs (c));

endfunction
%!test
%! d = finddelay([0, 0, 1, 2, 3], [1, 2, 3]);
%! assert (d, -2)

%!test
%! d = finddelay([1, 2, 3], [0, 0, 1, 2, 3]);
%! assert (d, 2)