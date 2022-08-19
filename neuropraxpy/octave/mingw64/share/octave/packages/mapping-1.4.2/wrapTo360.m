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
## @deftypefn {Function File} {@var{xwrap} =} wrapTo360 (@var{x})
##
## Wraps X into the [0 to 360] interval.
##
## @var{x}: angle(s) in degrees (single value, vector or ND matrix).
##
## @var{xwrap}: output value(s) in the range [0 .. 360] degrees.
## The interval [0 .. 360] is a closed interval: values equal to
## zero or negative even multiples of 360 are mapped to 0, values
## equal to an even multiple of 360 are mapped to 360.
##
## Example:
## @example
## wrapTo360 ([-720, -360, 0; 10, 360, 720])
## ans =
##     0     0     0
##    10   360   360
## @end example
##
## @seealso{wrapTo180, wrapToPi, wrapTo2Pi}
## @end deftypefn

function xwrap = wrapTo360(x)

  xwrap = rem (x-180, 360);
  idx = find (abs (xwrap) > 180);
  xwrap(idx) -= 360 * sign (xwrap(idx));
  xwrap += 180;

endfunction

%!test
%! x = -800:0.1:800;
%! xw = wrapTo360 (x);
%! assert (sind (x), sind (xw), 16 * eps)
%! assert (cosd (x), cosd (xw), 16 * eps)
%! assert (! any (xw < 0))
%! assert (! any (xw > 360))

%% Test Matlab compatibility as regards closed interval (esp. left)
%!test
%! assert (wrapTo360 ([-720, -360, 0; 10, 360, 720]), ...
%!         [0, 0, 0; 10, 360, 360], 1e-13);
