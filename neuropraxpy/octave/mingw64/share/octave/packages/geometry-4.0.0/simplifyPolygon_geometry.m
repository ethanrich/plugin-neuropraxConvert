## Copyright (C) 2012-2019 Juan Pablo Carbajal
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
## Updated: 2019-05-14

## -*- texinfo -*-
## @deftypefn {Function File} {@var{spoly} = } simplifyPolygon_geometry (@var{poly})
## Simplify a polygon using the Ramer-Douglas-Peucker algorithm.
##
## @var{poly} is a N-by-2 matrix, each row representing a vertex.
##
## @seealso{simplifyPolyline_geometry, shape2polygon}
## @end deftypefn

function polygonsimp = simplifyPolygon_geometry (polygon, varargin)

  polygonsimp = simplifyPolyline_geometry (polygon,varargin{:});

  # Remove parrallel consecutive edges
  PL = polygonsimp(1:end-1,:);
  PC = polygonsimp(2:end,:);
  PR = polygonsimp([3:end 1],:);
  a  = PL - PC;
  b  = PR - PC;
  tf = find (isParallel(a,b))+1;
  polygonsimp (tf,:) = [];

endfunction

%!test
%!  P = [0 0; 1 0; 0 1];
%!  P2 = [0 0; 0.1 0; 0.2 0; 0.25 0; 1 0; 0 1; 0 0.7; 0 0.6; 0 0.3; 0 0.1];
%! assert(simplifyPolygon_geometry (P2),P,min(P2(:))*eps)

%!demo
%!
%!  P = [0 0; 1 0; 0 1];
%!  P2 = [0 0; 0.1 0; 0.2 0; 0.25 0; 1 0; 0 1; 0 0.7; 0 0.6; 0 0.3; 0 0.1];
%!  Pr = simplifyPolygon_geometry (P2);
%!
%!  cla
%!  drawPolygon(P,'or;Reference;');
%!  hold on
%!  drawPolygon(P2,'x-b;Redundant;');
%!  drawPolygon(Pr,'*g;Simplified;');
%!  hold off
%!
%! # --------------------------------------------------------------------------
%! # The two polygons describe the same figure, a triangle. Extra points are
%! # removed from the redundant one.
