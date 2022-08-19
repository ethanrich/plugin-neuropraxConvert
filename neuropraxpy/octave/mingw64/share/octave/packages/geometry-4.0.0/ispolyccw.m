## Copyright (C) 2016 - Juan Pablo Carbajal
## Copyright (C) 2017 - Piyush Jain
##
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program. If not, see <http://www.gnu.org/licenses/>.

## Author: Juan Pablo Carbajal <ajuanpi+dev@gmail.com>

## -*- texinfo -*-
## @deftypefn {} {@var{ccw} =} ispolyccw (@var{p})
## @deftypefnx {} {@var{ccw} =} ispolyccw (@var{px}, @var{py})
## Returns true if the polygon @var{p} are oriented Counter-Clockwise.
##
## @var{p} is a N-by-2 array containing coordinates of vertices. The coordinates
## of the vertices of the polygon can also be given as two N-by-1 arrways
## @var{px}, @var{py}.
##
## If polygon is self-crossing, the result is undefined.
##
## If x and y contain multiple contours, either in NaN-separated vector form or in cell array form, ispolyccw returns a logical array containing one true or false value per contour.
##
## If @var{points} is a cell, each element is considered a polygon, the
## resulting @var{cww} array has the same shape as the cell.
##
## @seealso{polygonArea}
## @end deftypefn

function ccw = ispolyccw (px, py)
  
  if (nargin > 3 || nargin < 1)
    print_usage ();
  endif

  if(nargin == 1)
    px = reshape(px, numel(px)/2, 2);
  else
    px = reshape(px, numel(px), 1);
    py = reshape(py, numel(py), 1);
    px = [px py];
  endif

  ccw = isPolygonCCW(px);

end

%!shared pccw, pcw, ph
%! pccw = pcw = [0 0; 1 0; 1 1; 0 1];
%! pcw([2 4],:) = pcw([4 2], :);
%! ph = [pccw; nan(1,2); 0.5*pcw+[0.25 0.25]];

%!assert (ispolyccw (pccw));
%!assert (~ispolyccw (pcw));
%!assert (ispolyccw ({pccw;pcw}), {true false});
%!assert (ispolyccw(ph),[true;false]);

%!test
%! phcw = [pcw; nan(1,2); 0.5*pccw+[0.25 0.25]];
%! assert (ispolyccw(phcw),[false;true]);

%!test
%! x=[0 0 2 2 NaN 0 2 0]; y=[0 2 2 0 NaN 0 0 3];
%! assert(ispolyccw(x,y),[false;true]);
