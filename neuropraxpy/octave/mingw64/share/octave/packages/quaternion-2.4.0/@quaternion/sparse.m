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
## @deftypefn {Function File} {@var{sq} =} sparse (@var{fq})
## Return a sparse quaternion representation @var{sq} from
## full quaternion @var{fq}.
## @end deftypefn

## Author: Lukas Reichlin <lukas.reichlin@gmail.com>
## Created: December 2013
## Version: 0.1

function q = sparse (q)

  if (nargin != 1)
    print_usage ();
  endif
  
  q.w = sparse (q.w);
  q.x = sparse (q.x);
  q.y = sparse (q.y);
  q.z = sparse (q.z);

endfunction
