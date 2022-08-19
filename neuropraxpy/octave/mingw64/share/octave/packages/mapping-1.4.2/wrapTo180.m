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
## @deftypefn {Function File} {@var{xwrap} =} wrapTo180 (@var{x})
##
## Wraps X into the [-180 to 180] interval.  
##
## @var{x}: angle(s) in degrees (single value, vector or ND-matrix).  
##
## @var{xwrap}: output value(s) in the range [-180 .. 180] degrees.
## The interval [-180 .. 180] is a closed interval: values equal to
## negative odd multiples of -180 are mapped to -180, values equal
## to an odd multiple of 180 are mapped to 180.
##
## @example
##  wrapTo180 ([-181, -180, -50; 180, 200, 460])
##  ans =
##   179  -180   -50
##   180  -160   100
## @end example
##
## @seealso{unwrap, wrapToPi, wrapTo2Pi}
## @end deftypefn

function xwrap = wrapTo180 (x)

  xwrap = rem (x, 360);
  idx = find (abs (xwrap) > 180);
  xwrap(idx) -= 360 * sign (xwrap(idx));

endfunction


%!test
%! x = -800:0.1:800;
%! xw = wrapTo180 (x);
%! assert (sind (x), sind (xw), 16 * eps)
%! assert (cosd (x), cosd (xw), 16 * eps)
%! assert (! any (xw < -180))
%! assert (! any (xw > 180))

%!test
%! c = [-721.1, -718.9, -481.3, -479.99, -361, -359, -200, -180-(1e-14), -180, ...
%!      -180-(2e-14), -160, -eps, 0, eps, 160, 180, 180+(1e-14), 180+(2e-14), 200];
%! assert (wrapTo180 (c), [-1.10, 1.10, -121.30, -119.99, -1.0, 1.0, 160.0, ...
%!                         -180.0, -180.0, 180.0, -160.0, -0.0, 0.0, 0.0, ...
%!                         160.0, 180.0, 180.0, -180.0, -160.0], 1e-13);
