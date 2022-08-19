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
## @deftypefn {Function File} {@var{q} =} sum (@var{q})
## @deftypefnx {Function File} {@var{q} =} sum (@var{q}, @var{dim})
## @deftypefnx {Function File} {@var{q} =} sum (@dots{}, @var{'native'})
## @deftypefnx {Function File} {@var{q} =} sum (@dots{}, @var{'double'})
## @deftypefnx {Function File} {@var{q} =} sum (@dots{}, @var{'extra'})
## Sum of elements along dimension @var{dim}.  If @var{dim} is omitted,
## it defaults to the first non-singleton dimension.
## See @code{help sum} for more information.
## @end deftypefn

## Author: Lukas Reichlin <lukas.reichlin@gmail.com>
## Created: December 2013
## Version: 0.1

function q = sum (q, varargin)

  if (! isa (q, "quaternion"))
    print_usage ();
  endif

  q.w = sum (q.w, varargin{:});
  q.x = sum (q.x, varargin{:});
  q.y = sum (q.y, varargin{:});
  q.z = sum (q.z, varargin{:});

endfunction
