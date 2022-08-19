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
## Subscripted reference for quaternions.  Used by Octave for "q.w".
##
## @strong{Subscripts}
## @table @var
## @item q.w
## Return scalar part @var{w} of quaternion @var{q} as a built-in type.
##
## @item q.x, q.y, q.z
## Return component @var{x}, @var{y} or @var{z} of the vector part of 
## quaternion @var{q} as a built-in type.
##
## @item q.s
## Return scalar part of quaternion @var{q}.  The vector part of @var{q}
## is set to zero.
##
## @item q.v
## Return vector part of quaternion @var{q}.  The scalar part of @var{q}
## is set to zero.
##
## @item q(@dots{})
## Extract certain elements of quaternion array @var{q}, e.g. @code{q(3, 2:end)}.
## @end table

## Author: Lukas Reichlin <lukas.reichlin@gmail.com>
## Created: May 2010
## Version: 0.6

function ret = subsref (q, s)

  if (numel (s) == 0)
    ret = q;
    return;
  endif

  switch (s(1).type)
    case "."                                # q.w
      switch (tolower (s(1).subs))
        case {"w", "e"}                     # scalar part, returned as built-in type
          ret = subsref (q.w, s(2:end));
        case {"x", "i"}
          ret = subsref (q.x, s(2:end));
        case {"y", "j"}
          ret = subsref (q.y, s(2:end));
        case {"z", "k"}
          ret = subsref (q.z, s(2:end));
        case "s"                            # scalar part, vector part set to zero
          q.x = q.y = q.z = zeros (size (q.w), class (q.w));
          ret = subsref (q, s(2:end));
        case "v"                            # vector part, scalar part set to zero
          q.w = zeros (size (q.w), class (q.w));
          ret = subsref (q, s(2:end));
        otherwise
          error ("quaternion: invalid subscript name '%s'", s(1).subs);
      endswitch

    case "()"                               # q(...)
      w = subsref (q.w, s(1));
      x = subsref (q.x, s(1));
      y = subsref (q.y, s(1));
      z = subsref (q.z, s(1));
      tmp = quaternion (w, x, y, z);
      ret = subsref (tmp, s(2:end));
      
    otherwise
      error ("quaternion: invalid subscript type '%s'", s(1).type);
  endswitch

endfunction
