## Copyright (C) 1998, 1999, 2000, 2002, 2005, 2006, 2007 Auburn University
## Copyright (C) 2010-2015   Lukas F. Reichlin
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
## @deftypefn {Function File} {@var{q} =} rot2q (@var{axis}, @var{angle})
## Create unit quaternion @var{q} which describes a rotation of
## @var{angle} radians about the vector @var{axis}.  This function uses
## the active convention where the vector @var{axis} is rotated by @var{angle}
## radians.  If the coordinate frame should be rotated by @var{angle}
## radians, also called the passive convention, this is equivalent
## to rotating the @var{axis} by @var{-angle} radians.
##
## @strong{Inputs}
## @table @var
## @item axis
## Vector @code{[x, y, z]} or @code{[x; y; z]} describing the axis of rotation.
## @item angle
## Rotation angle in radians.  The positive direction is
## determined by the right-hand rule applied to @var{axis}.
## If @var{angle} is a real-valued array, a quaternion array
## @var{q} of the same size is returned.
## @end table
##
## @strong{Outputs}
## @table @var
## @item q
## Unit quaternion describing the rotation.
## If @var{angle} is an array, @var{q(i,j)} corresponds to
## the rotation angle @var{angle(i,j)}.
## @end table
##
## @strong{Example}
## @example
## @group
## octave:1> axis = [0, 0, 1];
## octave:2> angle = pi/4;
## octave:3> q = rot2q (axis, angle)
## q = 0.9239 + 0i + 0j + 0.3827k
## octave:4> v = quaternion (1, 1, 0)
## v = 0 + 1i + 1j + 0k
## octave:5> vr = q * v * conj (q)
## vr = 0 + 0i + 1.414j + 0k
## octave:6>
## @end group
## @end example
##
## @end deftypefn

## Adapted from: quaternion by A. S. Hodel <a.s.hodel@eng.auburn.edu>
## Author: Lukas Reichlin <lukas.reichlin@gmail.com>
## Created: May 2010
## Version: 0.2

function q = rot2q (vv, theta)

  if (nargin != 2 || nargout > 1)
    print_usage ();
  endif

  if (! is_real_array (vv) || ! isvector (vv) || length (vv) != 3)
    error ("rot2q: first argument 'axis' must be a length three vector");
  endif

  if (! is_real_array (theta))
    error ("rot2q: second argument 'angle' must be a scalar");
  endif

  if (norm (vv) == 0)
    error ("rot2q: first argument 'axis' is zero");
  endif

  if (abs (norm (vv) - 1) > 1e-12)
    warning ("rot2q:axis", "rot2q: ||axis|| != 1, normalizing")
    vv = vv / norm (vv);
  endif

  if (any ((abs (theta) > 2*pi)(:)))
    warning ("rot2q:angle", "rot2q: |angle| > 2 pi, normalizing")
    theta = rem (theta, 2*pi);
  endif

  w = cos (theta ./ 2);
  st2 = sin (theta ./ 2);
  x = vv(1) .* st2;
  y = vv(2) .* st2;
  z = vv(3) .* st2;
  
  q = quaternion (w, x, y, z);

endfunction


%!shared ax, an
%! q = rot2q ([1;0;0], -1.2*pi);
%! [ax, an] = q2rot (q);
%!assert (abs (ax(1)), 1, 1e-4);
%!assert (an*ax(1), -1.2*pi, 1e-4);
