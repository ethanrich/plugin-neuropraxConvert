## Copyright (C) 2019 Juan Pablo Carbajal
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
## @deftypefn {Function File} {@var{shape} = } polygon2shape (@var{polygon})
## Converts a polygon to a shape with edges defined by smooth polynomials.
##
## @var{polygon} is a N-by-2 matrix, each row representing a vertex.
## @var{shape} is a N-by-1 cell, where each element is a pair of polynomials
## compatible with polyval.
##
## In its current state, the shape is formed by polynomials of degree 1. Therefore
## the shape representation costs more memory except for colinear points in the
## polygon.
##
## @seealso{shape2polygon, simplifyPolygon, polyval}
## @end deftypefn

function shape = polygon2shape (polygon)

  # Filter colinear points
  polygon = simplifyPolygon_geometry (polygon);

  np = size(polygon,1);
  # polygonal shapes are memory inefficient!!
  # TODO filter the regions where edge angles are canging slowly and fit
  # polynomial of degree 3;
  pp = nan (2*np,2);

  # Transform edges into polynomials of degree 1;
  # pp = [(p1-p0) p0];
  pp(:,1) = diff(polygon([1:end 1],:)).'(:);
  pp(:,2) = polygon.'(:);

  shape = mat2cell(pp, 2*ones (1,np), 2);

endfunction

%!test
%! pp = [0 0; 1 0; 1 1; 0 1];
%! s = polygon2shape (pp);
