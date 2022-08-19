## Copyright (C) 2016 Philip Nienhuis
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
## @deftypefn {} {@var{outpol} =} joinPolygons (@var{inpol})
## Convert a cell style set of polygons into an array of subpolygons
## separated by NaN rows.
##
## @var{inpol} is expected to be an Nx1 (column) cell array with each cell
## containing either a matrix of Mx1 (X), Mx2 (X,Y), or Mx3 (X,Y,Z) coordinates.
##
## @var{outpol} is a numeric Px1, Px2 or Px3 array os subpolygons each
## separated by a row of NaN values.
##
## @seealso{splitPolygons}
## @end deftypefn

## Author: Philip Nienhuis <prnienhuis@users.sf.net>
## Created: 2016-05-10

function [polys] = joinPolygons (poly)

  if (! iscell (poly))
    error ('Octave:invalid-input-arg', 'joinPolygons: cell array expected');
  elseif (isempty (poly))
    polys = [];
    return
  elseif (isvector (poly) && any (cellfun (@(p)isrow(p) && numel(p) != 1, poly)))
    error ('Octave:invalid-input-arg', 'joinPolygons: column vectors expected');
  endif

  XY(1:2:2*size (poly, 1), :) = [{poly{:}}'];
  XY(2:2:2*size (poly, 1) - 1, :) = NaN (1, size (poly{1}, 2));
  polys = cell2mat (XY);

endfunction

%!test
%! assert (joinPolygons ({1,2}), [1 2]);

%!test
%! assert (joinPolygons ({}), []);

%!test
%! XY = joinPolygons ({[1 6; 2 5; 3 4]; [4 3; 5 2; 6 1]});
%! assert (XY, [1 6; 2 5; 3 4; NaN NaN; 4 3; 5 2; 6 1]);

%!error <joinPolygons: cell array expected> joinPolygons ([1 2 NaN 3 4], [56 NaN 78])
%!error <joinPolygons: column vectors expected>  joinPolygons ({[1,0], [0,2]});
