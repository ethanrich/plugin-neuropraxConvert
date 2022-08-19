## Copyright (C) 2013   Willem Atsma
## 
## This program is free software: you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation, either version 3 of the License, or
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
## @deftypefn {Function File} {@var{q} =} rotm2q (@var{R})
## Convert 3x3 rotation matrix @var{R} to unit quaternion @var{q}.
## @end deftypefn

## Author: Willem Atsma <willem.atsma@tanglebridge.com>
## Based on C code from <http://www.euclideanspace.com/>
## Created: May 2013
## Version: 0.1

function q = rotm2q (R)

  if (nargin != 1)
    print_usage ();
  endif
  
  if (! is_real_array (R) || ! isequal (size (R), [3, 3]))
    error ("rotm2q: require a (3x3) rotation matrix");
  endif

  T = trace (R);
  
  if (T > 0)
    s = 0.5 / sqrt (T+1);
    w = 0.25 / s;
    x = (R(3,2) - R(2,3)) * s;
    y = (R(1,3) - R(3,1)) * s;
    z = (R(2,1) - R(1,2)) * s;
  else
    if (R(1,1) > R(2,2) && R(1,1) > R(3,3))
      s = 2 * sqrt (1 + R(1,1) - R(2,2) - R(3,3));
      w = (R(3,2) - R(2,3)) / s;
      x = 0.25 * s;
      y = (R(1,2) + R(2,1)) / s;
      z = (R(1,3) + R(3,1)) / s;
    elseif (R(2,2) > R(3,3))
      s = 2 * sqrt (1 + R(2,2) - R(1,1) - R(3,3));
      w = (R(1,3) - R(3,1)) / s;
      x = (R(1,2) + R(2,1)) / s;
      y = 0.25 * s;
      z = (R(2,3) + R(3,2) ) / s;
    else
      s = 2 * sqrt (1 + R(3,3) - R(1,1) - R(2,2));
      w = (R(2,1) - R(1,2)) / s;
      x = (R(1,3) + R(3,1)) / s;
      y = (R(2,3) + R(3,2)) / s;
      z = 0.25 * s;
    endif
  endif

  q = quaternion (w, x, y, z);

endfunction


%!test
%! R = eye (3);
%! q = rotm2q (R);
%! assert (q.w, 1, 1e-4);
%! assert (q.x, 0, 1e-4);
%! assert (q.y, 0, 1e-4);
%! assert (q.z, 0, 1e-4);

%!test
%! R = [[1;0;0], [0;0;1], [0;-1;0]];
%! q = rotm2q (R);
%! [ax, an] = q2rot (q);
%! assert (ax(:), [1;0;0], 1e-4);
%! assert (an, pi/2, 1e-4);
