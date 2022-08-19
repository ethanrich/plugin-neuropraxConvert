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
## @deftypefn {Function File} {@var{q} =} cast (@var{q}, @var{'type'})
## Convert the components of quaternion @var{q} to data type @var{type}.
## Valid types are int8, uint8, int16, uint16, int32, uint32, int64,
## uint64, double, single and logical.
## @end deftypefn

## Author: Lukas Reichlin <lukas.reichlin@gmail.com>
## Created: December 2013
## Version: 0.1

function qret = cast (q, typ)

  if (nargin != 2 || ! ischar (typ))  # q is always a quaternion, no need to test
    print_usage ();
  endif

  if (! any (strcmp (typ, {"int8"; "uint8"; "int16"; "uint16";
                           "int32"; "uint32"; "int64"; "uint64";
                           "double"; "single"; "logical"})))
    error ("quaternion: cast: type name '%s' is not a built-in type", typ);
  endif

  ## NOTE: Without strcmp, cast could be used to apply any function to the
  ##       components of a quaternion.  Shall I create such a method with
  ##       a different name?

  w = feval (typ, q.w);
  x = feval (typ, q.x);
  y = feval (typ, q.y);
  z = feval (typ, q.z);
  
  qret = quaternion (w, x, y, z);

endfunction
