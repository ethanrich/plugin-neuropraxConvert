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
## Equal to operator for two quaternions.  Used by Octave for "q1 == q2".

## Author: Lukas Reichlin <lukas.reichlin@gmail.com>
## Created: May 2010
## Version: 0.4

function bool = eq (a, b)

  if (nargin != 2)
    error ("quaternion: eq: this is a binary operator");
  endif

  a = quaternion (a);
  b = quaternion (b);

  bool = (a.w == b.w) & (a.x == b.x) & (a.y == b.y) & (a.z == b.z);

endfunction


%!test
%! a = quaternion (2, 3, 4, 5);
%! b = quaternion (2, -3, 4, 5);
%! assert (a == a, true);
%! assert (a == b, false);
