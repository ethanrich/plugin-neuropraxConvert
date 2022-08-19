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
## @deftypefn {Function File} {@var{bool} =} isreal (@var{q})
## Return true if the vector part of quaternion @var{q} is zero
## and false otherwise.
## @end deftypefn

## Author: Lukas Reichlin <lukas.reichlin@gmail.com>
## Created: December 2013
## Version: 0.1

function bool = isreal (q)

  if (nargin != 1)
    print_usage ();
  endif

  ## bool = all ((abs(q.x) < eps  &  abs(q.y) < eps  &  abs(q.z) < eps)(:));
  bool = all ((q.x == 0  &  q.y == 0  &  q.z == 0)(:));

endfunction
