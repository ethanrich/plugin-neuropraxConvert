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
## @deftypefn {Function File} {} get (@var{q})
## @deftypefnx {Function File} {@var{value} =} get (@var{q}, @var{"key"})
## @deftypefnx {Function File} {[@var{val1}, @var{val2}, @dots{}] =} get (@var{q}, @var{"key1"}, @var{"key2"}, @dots{})
## Access key values of quaternion objects.
##
## @strong{Keys}
## @table @var
## @item w
## Return scalar part @var{w} of quaternion @var{q} as a built-in type.
##
## @item x, y, z
## Return component @var{x}, @var{y} or @var{z} of the vector part of 
## quaternion @var{q} as a built-in type.
##
## @item s
## Return scalar part of quaternion @var{q}.  The vector part of @var{q}
## is set to zero.
##
## @item v
## Return vector part of quaternion @var{q}.  The scalar part of @var{q}
## is set to zero.
## @end table
## @end deftypefn

## Author: Lukas Reichlin <lukas.reichlin@gmail.com>
## Created: April 2014
## Version: 0.1

function varargout = get (q, varargin)

  if (! isa (q, "quaternion"))
    error ("quaternion: get: first argument must be a quaternion");
  endif
  
  if (! all (cellfun (@ischar, varargin)))
    error ("quaternion: get: key names must be strings");
  endif

  if (nargin == 1)
    [keys, vals] = keys_vals (q);
    nrows = numel (keys);
    str = strjust (strvcat (keys), "right");
    str = horzcat (repmat ("   ", nrows, 1), str, repmat (":  ", nrows, 1), strvcat (vals));
    disp (str);
  else
    for k = 1 : (nargin-1)
      key = varargin{k};
      idx = substruct (".", key);
      varargout{k} = subsref (q, idx);
    endfor
  endif

endfunction
