## Copyright (C) 2017 - Piyush Jain
## Copyright (C) 2017 - Juan Pablo Carbajal
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

## -*- texinfo -*-
## @deffn {}  [@var{outpol}, @var{npol}] = clipPolygon_mrf (@var{inpol}, @var{clippol})
## @deffnx {} [@var{outpol}, @var{npol}] = clipPolygon_mrf (@var{inpol}, @var{clippol}, @var{op})
## Perform boolean operation on polygon(s) using the algorithm by Martinez, Rueda and Feito.
##
## @var{inpol} = Nx2 matrix of (X, Y) coordinates constituting the polygons(s)
## to be clipped (subject polygon).
## @var{clippol} = Nx2 matrix of (X, Y) coordinates representing the clip polygon(s).
##
## Polygons may have multiple non-intersecting regions. The contours are separated by [Nan NaN] rows.
## Polygons may also contain holes. Holes are defined as the region enclosed within the boundaries of polygon which are not part of the polygon region. Here again, the inner and outer contours are separated by [Nan NaN] rows. Specifically, if a contour is lying inside another contour, it is automatically treated as a hole. 
##
## The following features are allowed in input polygons:
##
## @itemize
## @item 0: Contours can be described in clockwise or counterclockwise order.
##
## @item 1: Holes.
##
## @item 2: A vertex of a polygon can touch (in a point) a vertex or edge of the same polygon.
##
## @item 3: Self-intersecting polygons.
## @end itemize
##
## The following features are not allowed in input polygons:
##
## @itemize
## The intersection of two edges of the same polygon can be a point, but cannot be a segment.
## @end itemize
##
## The argument @var{op}, the boolean operation, can be:
##
## @itemize
## @item 0: difference @var{inpol} - @var{clippol}
##
## @item 1: intersection ("AND") of @var{inpol} and @var{clippol} (= default)
##
## @item 2: exclusiveOR ("XOR") of @var{inpol} and @var{clippol}
##
## @item 3: union ("OR") of @var{inpol} and @var{clippol}
## @end itemize
##
## Output array @var{outpol} will be an Nx2 array of polygons resulting from
## the requested boolean operation
##
## Optional output argument @var{npol} indicates the number of output polygons.
##
## Know more about the algorithm by Martinez, Rueda and Feito[1].
##
## [1]: @uref{http://www4.ujaen.es/~fmartin/bool_op.html}
##
## @seealso{clipPolygon_clipper,clipPolygon}
## @end deffn

## Created: 2017-06-09

function [outpol, npol] = clipPolygon_mrf (inpoly, clippoly=[], method=1)

  ## Input validation

  if (nargin < 2 || nargin > 3)
    print_usage ();
  endif

  if(isempty(inpoly) || isempty(clippoly))
    error ('Octave:invalid-input-arg', ...
            "clipPolygon_mrf: Empty polygon");
  endif

  if (! isnumeric (inpoly) || size (inpoly, 2) < 2)
    error ('Octave:invalid-input-arg', ...
            "clipPolygon_mrf: inpoly should be a numeric Nx2 array");
  endif

  if (! isnumeric (clippoly) || size (clippoly, 2) < 2)
    error ('Octave:invalid-input-arg', ...
            "clipPolygon_mrf: clippoly should be a numeric Nx2 array");
  elseif (! isnumeric (method) || method < 0 || method > 3)
    error ('Octave:invalid-input-arg', ...
            "clipPolygon_mrf: operation must be a number in the range [0..3]");
  endif

  inpol = __polytostruct__ (inpoly);

  clpol = __polytostruct__ (clippoly);

  ## Perform boolean operation
  [X, Y, npol] = polybool_mrf(inpol, clpol, method);

  if(npol == 0)
    outpol = [ , ];
  else
    outpol = [X Y];
  endif
endfunction

%!test
%! pol1 = [-0.15 -0.15; 0.45 -0.15; 0.15 0.45];
%! pol2 = [-0.05 -0.05; 0.15 0.35; 0.35 -0.05; NaN NaN;
%!        0.05 0.05; 0.25 0.05; 0.15 0.25];
%! opol_0 = [0.15 0.25; 0.05 0.05; 0.25 0.05; NaN NaN;
%!            0.15 0.35; -0.05 -0.05; 0.35 -0.05; NaN NaN;
%!           0.15 0.45; -0.15 -0.15; 0.45 -0.15];
%! npol_0 = 3;
%! opol_1= [0.15 0.25; 0.05 0.05; 0.25 0.05; NaN NaN;
%!            0.15 0.35; -0.05 -0.05; 0.35 -0.05];
%! npol_1 = 2;
%! opol_2 = [0.15 0.25; 0.05 0.05; 0.25 0.05; NaN NaN;
%!            0.15 0.35; -0.05 -0.05; 0.35 -0.05; NaN NaN;
%!            0.15 0.45; -0.15 -0.15; 0.45 -0.15];
%! npol_2 = 3;
%! opol_3 = [0.15 0.45; -0.15 -0.15; 0.45 -0.15];
%! npol_3 = 1;
%! [opol npol] = clipPolygon_mrf (pol1, pol2, 0);
%! assert(opol, opol_0);
%! assert(npol, npol_0);
%! [opol npol] = clipPolygon_mrf (pol1, pol2, 1);
%! assert(opol, opol_1);
%! assert(npol, npol_1);
%! [opol npol] = clipPolygon_mrf (pol1, pol2, 2);
%! assert(opol, opol_2);
%! assert(npol, npol_2);
%! [opol npol] = clipPolygon_mrf (pol1, pol2, 3);
%! assert(opol, opol_3);
%! assert(npol, npol_3);
%!error <clipPolygon_mrf: Empty polygon> clipPolygon_mrf([], [], 0);
%!error
%! pol1 = [0.15 0.15; 0.55 0.45; 0.15 0.75];
%! pol2 = [0.35 0.45; 0.75 0.15; 0.75 0.75];
%! clipPolygon_mrf(pol1, pol2, 4);
 
%!test  ## Bug #56506
%! subpol = [0 0; 5 5; 2.5 4;0 0];
%! clppol2 = [10 1; 16 6; 13.5 5; 10 1];
%! [a, b] = clipPolygon_mrf (subpol, clppol2, 1);
%! assert (a, []);
%! assert (b, 0);

%!demo
%! pol1 = [0.15 0.15; 0.55 0.45; 0.15 0.75];
%! pol2 = [0.35 0.45; 0.75 0.15; 0.75 0.75];
%! pol1a = polygon2patch(pol1);
%! pol2a = polygon2patch(pol2);
%! lw = 2;
%! subplot (2, 6, [2 3])
%! patch (pol1a(:, 1), pol1a(:, 2), 'facecolor', 'c', 'edgecolor', 'k', 'linewidth', lw);
%! axis image
%! grid on
%! title ("1. Subject polygon")
%!
%! subplot (2, 6, [4 5])
%! patch (pol1a(:, 1), pol1a(:, 2), 'facecolor', 'c', 'edgecolor', 'none');
%! hold on
%! patch (pol2a(:, 1), pol2a(:, 2), 'facecolor', 'y', 'edgecolor', 'b', 'linewidth', lw);
%! axis image
%! grid on
%! title "2. Clip polygon"
%!
%! op   = {"Sub -clip", "AND / Intersection", "Exclusive OR", "OR / Union"};
%! for i=1:numel(op)
%!   subplot (6, 4, [12 16]+i);
%!   [opol, npol] = clipPolygon_mrf (pol1, pol2, i-1);
%!   opol = polygon2patch (opol);
%!   patch (pol1a(:, 1), pol1a(:, 2), 'facecolor', 'c', 'edgecolor', 'none');
%!   hold on
%!   patch (pol2a(:, 1), pol2a(:, 2), 'facecolor', 'y', 'edgecolor', 'none');
%!   patch (opol(:,1),opol(:,2), 'facecolor', 'g', 'edgecolor', 'r', ...
%!         'linewidth', lw);
%!   axis image
%!   grid on
%!   title (sprintf("%d. %s", i+2, op{i}));
%!   axis off
%! endfor
%!
%! subplot (10, 4, 37);
%!   [opol, npol] = clipPolygon_mrf (pol2, pol1, 0);
%!   opol = polygon2patch (opol);
%!   patch (pol1a(:, 1), pol1a(:, 2), 'facecolor', 'c', 'edgecolor', 'none');
%!   hold on
%!   patch (pol2a(:, 1), pol2a(:, 2), 'facecolor', 'y', 'edgecolor', 'none');
%!   patch (opol(:,1),opol(:,2), 'facecolor', 'g', 'edgecolor', 'r', ...
%!         'linewidth', lw);
%!   axis image
%!   grid on
%!   axis off
%!   title "7. Clip - sub";

%!demo
%! pol1 = [1 1; 5 1; 3 7; NaN NaN; 2 2; 3 5; 4 2];
%! pol2 = [3 1; 5 6; 1 6];
%! pol1a = polygon2patch(pol1);
%! pol2a = polygon2patch(pol2);
%! lw = 2;
%! subplot (2, 6, [2 3])
%! patch (pol1a(:, 1), pol1a(:, 2), 'facecolor', 'c', 'edgecolor', 'k', 'linewidth', lw);
%! axis image
%! grid on
%! title ("1. Subject polygon")
%!
%! subplot (2, 6, [4 5])
%! patch (pol1a(:, 1), pol1a(:, 2), 'facecolor', 'c', 'edgecolor', 'none');
%! hold on
%! patch (pol2a(:, 1), pol2a(:, 2), 'facecolor', 'y', 'edgecolor', 'b', 'linewidth', lw);
%! axis image
%! grid on
%! title "2. Clip polygon"
%!
%! op   = {"Sub -clip", "AND / Intersection", "Exclusive OR", "OR / Union"};
%! for i=1:numel(op)
%!   subplot (6, 4, [12 16]+i);
%!   [opol, npol] = clipPolygon_mrf (pol1, pol2, i-1);
%!   opol = polygon2patch (opol);
%!   patch (pol1a(:, 1), pol1a(:, 2), 'facecolor', 'c', 'edgecolor', 'none');
%!   hold on
%!   patch (pol2a(:, 1), pol2a(:, 2), 'facecolor', 'y', 'edgecolor', 'none');
%!   patch (opol(:,1),opol(:,2), 'facecolor', 'g', 'edgecolor', 'r', ...
%!         'linewidth', lw);
%!   axis image
%!   grid on
%!   title (sprintf("%d. %s", i+2, op{i}));
%!   axis off
%! endfor
%!
%! subplot (10, 4, 37);
%!   [opol, npol] = clipPolygon_mrf (pol2, pol1, 0);
%!   opol = polygon2patch (opol);
%!   patch (pol1a(:, 1), pol1a(:, 2), 'facecolor', 'c', 'edgecolor', 'none');
%!   hold on
%!   patch (pol2a(:, 1), pol2a(:, 2), 'facecolor', 'y', 'edgecolor', 'none');
%!   patch (opol(:,1),opol(:,2), 'facecolor', 'g', 'edgecolor', 'r', ...
%!         'linewidth', lw);
%!   axis image
%!   grid on
%!   axis off
%!   title "7. Clip - sub";