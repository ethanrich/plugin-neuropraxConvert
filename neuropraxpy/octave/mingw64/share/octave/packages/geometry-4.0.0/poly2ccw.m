## Copyright (C) 2016 - Amr Mohamed
## Copyright (C) 2017 - Piyush Jain
##
## This file is part of Octave.
##
## Octave is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or
## (at your option) any later version.
##
## Octave is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with Octave; see the file COPYING.  If not,
## see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} [@var{xccw},@var{yccw}] = poly2ccw (@var{x},@var{y})
## Convert Polygons to counterclockwise contours(polygons).
##
## @var{x}/@var{y} is a cell array or NaN delimited vector of polygons, representing the x/y coordinates of the points. If x1 and y1 can contain multiple contours, represented either as NaN-separated vectors or as cell arrays, then each contour is converted to counter-clockwise ordering.
## @var{xccw}/@var{yccw} has the same format of the input.
##
## @seealso{poly2cw,ispolycw}
## @end deftypefn

## Created: 2017-07-18

function [xccw, yccw]=poly2ccw(x,y);
  if (nargin != 2)
  #case of wrong number of input arguments
   print_usage();
  endif

  if(isempty(x) || isempty(y))
  	error ('Octave:invalid-input-arg', ...
            "poly2ccw: Empty arguments");
  endif

   x = reshape(x, numel(x), 1);
   y = reshape(y, numel(y), 1);

  [xccw, yccw] = orientPolygon(x,y,"ccw");

  if(xccw(1) == xccw(2) && yccw(1) == yccw(2))
    xccw = circshift(xccw,-1);
    yccw = circshift(yccw,-1);
  endif

endfunction

%!test
%! x = [0 0 1 1 0]; y = [0 1 1 0 0];
%! [xccw,yccw] = poly2ccw(x,y);
%! xexp = [0; 1; 1; 0; 0]; yexp = [0; 0; 1; 1; 0];
%! assert (xccw,xexp);
%! assert (yccw,yexp);

%!test
%! x=[0 0 2 2 NaN 0 2 0]; y=[0 2 2 0 NaN 0 0 3];
%! [xccw,yccw]=poly2ccw(x,y);
%! xexp=[0; 2; 2; 0; NaN; 0; 2; 0];
%! yexp=[0; 0; 2; 2; NaN; 0; 0; 3];
%! assert (xccw,xexp);
%! assert (yccw,yexp);
