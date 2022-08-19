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
## @deftypefn {Function File} {@var{q} =} tril (@var{q})
## @deftypefnx {Function File} {@var{q} =} tril (@var{q}, @var{k})
## @deftypefnx {Function File} {@var{q} =} tril (@var{q}, @var{k}, @var{'pack'})
## Return a new quaternion matrix formed by extracting the lower
## triangular part of the quaternion @var{q}, and setting all
## other elements to zero.  The second argument @var{k} is optional,
## and specifies how many diagonals above or below the main diagonal
## should also be included.  Default value for @var{k} is zero.
## If the option "pack" is given as third argument, the extracted
## elements are not inserted into a matrix, but rather stacked
## column-wise one above other.
## @end deftypefn

## Author: Lukas Reichlin <lukas.reichlin@gmail.com>
## Created: December 2013
## Version: 0.1

function q = tril (q, varargin)

  if (! isa (q, "quaternion"))
    print_usage ();
  endif

  q.w = tril (q.w, varargin{:});
  q.x = tril (q.x, varargin{:});
  q.y = tril (q.y, varargin{:});
  q.z = tril (q.z, varargin{:});

endfunction
