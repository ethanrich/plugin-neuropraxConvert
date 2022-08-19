## Copyright (C) 2015-2022 Oscar Monerris Belda
## 
## This program is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or
## (at your option) any later version.
## 
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
## 
## You should have received a copy of the GNU General Public License
## along with this program.  If not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*- 
## @deftypefn {Function File} {@var{xwrap} =} wrapTo2Pi (@var{x})
##
## Wraps x into the [0 to 2pi] interval
##
## @var{x}: angle in radians (single value, vector or ND matrix).
##
## @var{xwrap}: output value(s) in the range [0 .. 2*pi] radians.
## The interval [0 .. 2*pi] is a closed interval: values equal to
## zero or negative even multiples of pi are mapped to 0, values
## equal to an even multiple of pi are mapped to 2*pi.
##
## Example:
## @example
## wrapTo2Pi ([-2*pi, -pi, 0, pi; 0.1, pi, 4*pi, 5*pi])
## ans =
##   0.00000   3.14159   0.00000   3.14159
##   0.10000   3.14159   6.28319   3.14159
## @end example
##
## @seealso{wrapTo180, wrapTo360, wraptoPi}
## @end deftypefn

function xwrap = wrapTo2Pi(x)

  xwrap = rem (x-pi, 2*pi);
  idx = find (abs (xwrap) > pi);
  xwrap(idx) -= 2*pi * sign (xwrap(idx));
  xwrap += pi;

endfunction

%!test
%! x = -9:0.1:9;
%! xw = wrapTo2Pi (x);
%! assert (sin (x), sin (xw), 8 * eps)
%! assert (cos (x), cos (xw), 8 * eps)
%! assert (! any (xw < 0))
%! assert (! any (xw > 2 * pi))

%% Test Matlab compatibility as regards closed interval (esp. left)
%!test
%! assert (wrapTo2Pi ([-2*pi, -pi, 0, pi; 0.1, pi, 4*pi, 5*pi]), ...
%!                     [0, pi, 0, pi; 0.1, pi, 2*pi, pi], 1e-13);
