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
## @deftypefn {Function File} {} set (@var{q})
## @deftypefnx {Function File} {} set (@var{q}, @var{"key"}, @var{value}, @dots{})
## @deftypefnx {Function File} {@var{qret} =} set (@var{q}, @var{"key"}, @var{value}, @dots{})
## Set or modify properties of quaternion objects.
## If no return argument @var{qret} is specified, the modified quaternion object is stored
## in input argument @var{q}.  @command{set} can handle multiple keys in one call:
## @code{set (q, 'key1', val1, 'key2', val2, 'key3', val3)}.
## @code{set (q)} prints a list of the object's key names.
##
## @strong{Keys}
## @table @var
## @item w
## Assign real-valued array @var{val} to scalar part @var{w} of quaternion @var{q}.
##
## @item x, y, z
## Assign real-valued array @var{val} to component @var{x}, @var{y} or @var{z}
## of the vector part of quaternion @var{q}.
##
## @item s
## Assign scalar part of quaternion @var{val} to scalar part of quaternion @var{q}.
## The vector part of @var{q} is left untouched.
##
## @item v
## Assign vector part of quaternion @var{val} to vector part of quaternion @var{q}.
## The scalar part of @var{q} is left untouched.
## @end table
## @end deftypefn

## Author: Lukas Reichlin <lukas.reichlin@gmail.com>
## Created: April 2014
## Version: 0.1

function qret = set (q, varargin)

  if (! isa (q, "quaternion"))
    error ("quaternion: set: first argument must be a quaternion");
  endif

  if (nargin == 1)      # set (q)
    [keys, vals] = keys_vals (q);
    nrows = numel (keys);
    str = strjust (strvcat (keys), "right");
    str = horzcat (repmat ("   ", nrows, 1), str, repmat (":  ", nrows, 1), strvcat (vals));
    disp (str);
    if (nargout != 0)
      qret = q;
    endif
  else                  # set (q, "key", val, ...)
    if (rem (nargin-1, 2))
      error ("quaternion: set: keys and values must come in pairs");
    endif
    if (! all (cellfun (@ischar, varargin(1:2:end))))
      error ("quaternion: set: key names must be strings");
    endif
    for k = 1 : 2: (nargin-1)
      key = varargin{k};
      val = varargin{k+1};
      idx = substruct (".", key);
      q = subsasgn (q, idx, val);
    endfor
    if (nargout == 0)   # set (q, "key1", val1, ...)
      assignin ("caller", inputname (1), q);
    else                # q = set (q, "key1", val1, ...)
      qret = q;
    endif
  endif

endfunction
