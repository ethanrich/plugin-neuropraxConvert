## Copyright (C) 2016-2022 Philip Nienhuis
##
## This program is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or
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
## @deftypefn {} {@var{mp} =} isShapeMultipart (@var{x}, @var{y})
## Checks if a polygon or polyline consists of multiple parts separated by
## NaN rows.
##
## @var{x} and @var{y} must be vectors with the same orientation (either
## row vectors of column vectors).
##
## Output argument @var{mp} is zero (false) if the shape contains no NaN
## rows, otherwise it equals the number of polygon/polyline shape parts.
##
## @seealso{}
## @end deftypefn

## Author: Philip Nienhuis <prnienhuis@users.sf.net>
## Created: 2016-05-22

function mp = isShapeMultipart (x, y)

  if (nargin  < 2)
    print_usage ();
  endif
  if (isrow (x) != isrow (y))
    error ("isShapeMultipart: x and y must be both row vectors or both column vectors")
  endif
  if (numel (x) != numel (y))
    error ("isShapeMultipart: incompatible input vectors");
  endif

  mp = 0;
  mp_x = find (isnan (x));
  mp_y = find (isnan (y));
  if (! isempty (mp_x) && ! isempty (mp_y) && numel (mp_x) == numel (mp_y))
    if (any (mp_x - mp_y))
      error ("isShapeMultipart: NaN positions don't match");
    else
      mp = numel (mp_x) + 1;
    endif
  endif

endfunction


%!test
%! assert (isShapeMultipart ([0 1 0], [1 0 0]), 0);

%!test
%! h = [0 0 1 NaN 2 2 NaN 3 3];
%! k = [0 1 0 NaN 2 3 NaN 3 2];
%! assert (isShapeMultipart (h, k), 3);

%!error <x and y must be both> isShapeMultipart ([0 0 1 NaN 2 2 NaN 3 3], ...
%!                                               [0 1 0 NaN 2 3 NaN 3 2]')
%!error <NaN positions don't match> isShapeMultipart ([0 1 NaN 2 3 NaN 4], ...
%!                                                    [0 1 NaN 2 NaN 3 4])
%!error <incompatible input> isShapeMultipart ([0 0 1 NaN 2 2 NaN 3 3], ...
%!                                       [0 1 0 NaN 2 3 NaN 3])
