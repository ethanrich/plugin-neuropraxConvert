## Copyright (C) 2013   Willem Atsma
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
## @deftypefn {Function File} {@var{q} =} mean (@var{q})
## @deftypefnx {Function File} {@var{q} =} mean (@var{q}, @var{dim})
## @deftypefnx {Function File} {@var{q} =} mean (@var{q}, @var{opt})
## @deftypefnx {Function File} {@var{q} =} mean (@var{q}, @var{dim}, @var{opt})
## Compute the mean of the elements of the quaternion array @var{q}.
##
## @example
## mean (q) = mean (q.w) + mean (q.x)*i + mean (q.y)*j + mean (q.z)*k
## @end example
##
## See @code{help mean} for more information and a description of the
## parameters @var{dim} and @var{opt}.
## @end deftypefn

## Author: Willem Atsma <willem.atsma@tanglebridge.com>
## Created: June 2013
## Version: 0.1

function q = mean (q, varargin)

  if (! isa (q, "quaternion"))
    print_usage ();
  endif

  w = mean (q.w, varargin{:});
  x = mean (q.x, varargin{:});
  y = mean (q.y, varargin{:});
  z = mean (q.z, varargin{:});

  q = quaternion (w, x, y, z);
   
endfunction
