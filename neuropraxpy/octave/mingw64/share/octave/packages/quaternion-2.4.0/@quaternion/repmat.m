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
## @deftypefn  {Function File} {@var{qret} =} repmat (@var{q}, @var{m})
## @deftypefnx {Function File} {@var{qret} =} repmat (@var{q}, @var{m}, @var{n})
## @deftypefnx {Function File} {@var{qret} =} repmat (@var{q}, [@var{m} @var{n}])
## @deftypefnx {Function File} {@var{qret} =} repmat (@var{q}, [@var{m} @var{n} @var{p} @dots{}])
## Form a block quaternion matrix @var{qret} of size @var{m} by @var{n},
## with a copy of quaternion matrix @var{q} as each element.
## If @var{n} is not specified, form an @var{m} by @var{m} block matrix.
## @end deftypefn

## Author: Lukas Reichlin <lukas.reichlin@gmail.com>
## Created: July 2014
## Version: 0.1

function q = repmat (a, varargin)

  if (! isa (a, "quaternion"))
    print_usage ();
  endif
  
  w = repmat (a.w, varargin{:});
  x = repmat (a.x, varargin{:});
  y = repmat (a.y, varargin{:});
  z = repmat (a.z, varargin{:});

  q = quaternion (w, x, y, z);

endfunction
