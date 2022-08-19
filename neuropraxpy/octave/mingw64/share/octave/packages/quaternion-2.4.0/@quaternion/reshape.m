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
## @deftypefn {Function File} {@var{q} =} reshape (@var{q}, @var{m}, @var{n}, @dots{})
## @deftypefnx {Function File} {@var{q} =} reshape (@var{q}, [@var{m} @var{n} @dots{}])
## @deftypefnx {Function File} {@var{q} =} reshape (@var{q}, @dots{}, [], @dots{})
## @deftypefnx {Function File} {@var{q} =} reshape (@var{q}, @var{size})
## Return a quaternion array with the specified dimensions (@var{m}, @var{n}, @dots{})
## whose elements are taken from the quaternion array @var{q}.  The elements of the
## quaternion are accessed in column-major order (like Fortran arrays are stored).
## @end deftypefn

## Author: Lukas Reichlin <lukas.reichlin@gmail.com>
## Created: December 2013
## Version: 0.1

function q = reshape (q, varargin)

  if (! isa (q, "quaternion"))
    print_usage ();
  endif

  q.w = reshape (q.w, varargin{:});
  q.x = reshape (q.x, varargin{:});
  q.y = reshape (q.y, varargin{:});
  q.z = reshape (q.z, varargin{:});

endfunction
