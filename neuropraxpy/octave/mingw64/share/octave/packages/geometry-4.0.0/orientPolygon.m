## Copyright (C) 2016 - Juan Pablo Carbajal
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
## @deftypefn {} {@var{q} =} orientPolygon (@var{p})
## @deftypefnx {} {@dots{} =} orientPolygon (@var{p}, [], @var{dir})
## @deftypefnx {} {[@var{qx} @var{qy}] =} orientPolygon (@var{px}, @var{py})
## @deftypefnx {} {@dots{} =} orientPolygon (@var{px}, @var{py}, @var{dir})
## Orient polygon counterclockwise or clockwise.
##
## @var{p} is a N-by-2 array containing coordinates of vertices. The coordinates
## of the vertices of the polygon can also be given as two N-by-1 arrways
## @var{px}, @var{py}. It can also be cells of polygons or NaN separated polygons.
## The output has the same format as the input.
##
## The optional argument @var{dir} can be @asis{"ccw"} or @asis{"cw"}.
## By default it orients polygon counterclockwise (@code{@var{dir} == "ccw"}).
## To orient the polygon clockwise, use @code{@var{dir} == "cw"}.
##
## Holes are treated as independet polygons, that is a cw polygon with a cw hole
## will be seen as two cw polygons.
##
## If polygon is self-crossing, the result is undefined.
##
## @seealso{isPolygonCCW}
## @end deftypefn

function [x y] = orientPolygon (x, y=[], d = "ccw");
  #case of wrong number of input arguments
  if (nargin > 3 || nargin < 1)
    print_usage ();
  endif

  if (!isempty (y))
    if (!strcmp (typeinfo (x), typeinfo (y)))
      error ('Octave:invalid-input-arg', 'X and Y should be of the same type');
    endif
    if(any (size (x) != size (y)) )
      error ('Octave:invalid-input-arg', 'X and Y should be of the same size');
    endif
  endif

  # define orientation mode
  mode_ccw = strcmpi (d, "ccw");

  if (iscell (x))
    # Cell Array Format
    # Call this function on each cell
    if (isempty (y))
      y = cell (size (x));
    endif

    [x y] = cellfun (@(u,v) orientPolygon (u,v,d), x, y, "unif", 0);

  else
    # Input are matrices
    # merge them to one
    x = [x y];

    if any (isnan (x(:)))
      # Inputs are many polygons separated with NaN
      # Split them and call this function on each of them
      x = splitPolygons (x);
      x = cellfun (@(u) orientPolygon (u,[],d), x, "unif", 0);
      x = joinPolygons (x);

    else ## Here do the actual work
      #Check the orientation of the polygons
      if ( (!isPolygonCCW (x) && mode_ccw) || (isPolygonCCW (x) && !mode_ccw) );
         x = reversePolygon (x);
      endif
    endif

    if (!isempty (y))
      y = x(:,2);
      x = x(:,1);
    endif

  endif

endfunction

%!shared pccw, pcw, pxccw, pyccw, pxnan, pynan, pnan
%! pccw  = [0 0; 1 0; 1 1; 0 1];
%! pcw   = reversePolygon (pccw);
%! pxccw = pccw(:,1);
%! pyccw = pccw(:,2);
%! pxnan = [2; 2; 0; 0; NaN; 0; 0; 2];
%! pynan = [0; 2; 2; 0; NaN; 0; 3; 0];
%! pnan  = [pxnan pynan];

%!test
%! x = orientPolygon (pccw,[],"ccw");
%! assert (x, pccw);

%!test
%! x = orientPolygon (pccw,[],"cw");
%! assert (x, pcw);

%!test
%! x = orientPolygon (pcw,[],"ccw");
%! assert (x, pccw);

%!test
%! x = orientPolygon (pcw,[],"cw");
%! assert (x, pcw);

%!test
%! x = orientPolygon (pnan,[],"cw");
%! y = splitPolygons (pnan);
%! y = joinPolygons ({reversePolygon(y{1}); y{2}});
%! assert (x, y);

%!test
%! x = orientPolygon (pnan,[],"ccw");
%! y = splitPolygons (pnan);
%! y = joinPolygons ({y{1}; reversePolygon(y{2})});
%! assert (x, y);

%!test
%! [x y] = orientPolygon (pxccw,pyccw,"ccw");
%! assert ([x y], pccw);

%!test
%! [x y] = orientPolygon (pxccw,pyccw,"cw");
%! assert ([x y], pcw);
