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
## Subscripted assignment for quaternions.
## Used by Octave for "q.key = value".
##
## @strong{Subscripts}
## @table @var
## @item q.w
## Assign real-valued array @var{val} to scalar part @var{w} of quaternion @var{q}.
##
## @item q.x, q.y, q.z
## Assign real-valued array @var{val} to component @var{x}, @var{y} or @var{z}
## of the vector part of quaternion @var{q}.
##
## @item q.s
## Assign scalar part of quaternion @var{val} to scalar part of quaternion @var{q}.
## The vector part of @var{q} is left untouched.
##
## @item q.v
## Assign vector part of quaternion @var{val} to vector part of quaternion @var{q}.
## The scalar part of @var{q} is left untouched.
##
## @item q(@dots{})
## Assign @var{val} to certain elements of quaternion array @var{q}, e.g. @code{q(3, 2:end) = val}.
## @end table

## Author: Lukas Reichlin <lukas.reichlin@gmail.com>
## Created: November 2011
## Version: 0.3

function q = subsasgn (q, idx, val)

  switch (idx(1).type)
    case "()"                                                    # q(...) = val
      if (length (idx(1).subs) == 1 && isa (val, "quaternion"))  # required by horzcat, vertcat, cat, ...
        q(idx(1).subs{:}) = val;                                 # q = cellfun (@quaternion, varargin)
      else                                                       # general case
        val = quaternion (val);
        w = subsasgn (q.w, idx, val.w);
        x = subsasgn (q.x, idx, val.x);
        y = subsasgn (q.y, idx, val.y);
        z = subsasgn (q.z, idx, val.z);
        q = quaternion (w, x, y, z);
      endif

    case "."                                                     # q.w = val
      if (is_real_array (val))
        if (! size_equal (subsref (q.w, idx(2:end)), val))
          error ("quaternion: subsasgn: invalid argument size (%s), require dimensions (%s)", ...
                 regexprep (num2str (size (val), "%d "), " ", "x"), ...
                 regexprep (num2str (size (subsref (q.w, idx(2:end))), "%d "), " ", "x"));
        endif
        switch (tolower (idx(1).subs))
          case {"w", "e"}
            q.w = subsasgn (q.w, idx(2:end), val);
          case {"x", "i"}
            q.x = subsasgn (q.x, idx(2:end), val);
          case {"y", "j"}
            q.y = subsasgn (q.y, idx(2:end), val);
          case {"z", "k"}
            q.z = subsasgn (q.z, idx(2:end), val);
          otherwise
            error ("quaternion: subsasgn: invalid subscript name '%s'", idx(1).subs);
        endswitch
      elseif (isa (val, "quaternion"))
        if (! size_equal (subsref (q.w, idx(2:end)), val.w))
          error ("quaternion: subsasgn: invalid argument size (%s), require dimensions (%s)", ...
                 regexprep (num2str (size (val), "%d "), " ", "x"), ...
                 regexprep (num2str (size (subsref (q.w, idx(2:end))), "%d "), " ", "x"));
        endif
        switch (tolower (idx(1).subs))
          case "s"
            q.w = subsasgn (q.w, idx(2:end), val.w);
          case "v"
            q.x = subsasgn (q.x, idx(2:end), val.x);
            q.y = subsasgn (q.y, idx(2:end), val.y);
            q.z = subsasgn (q.z, idx(2:end), val.z);
          otherwise
            error ("quaternion: subsasgn: invalid subscript name '%s'", idx(1).subs);
        endswitch
      else
        error ("quaternion: subsasgn: invalid argument type, require real-valued array");
      endif

    otherwise
      error ("quaternion: subsasgn: invalid subscript type '%s'", idx(1).type);
  endswitch

endfunction
