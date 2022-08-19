## Copyright (C) 2016-2017 Juan Pablo Carbajal
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
## @deftypefn {} {@var{ccw} =} isPolygonCCW (@var{p})
## @deftypefnx {} {@var{ccw} =} isPolygonCCW (@var{px}, @var{py})
## Returns true if the polygon @var{p} are oriented Counter-Clockwise.
##
## @var{p} is a N-by-2 array containing coordinates of vertices. The coordinates
## of the vertices of the polygon can also be given as two N-by-1 arrays
## @var{px}, @var{py}.
##
## Optional third argument @var{library} can be one of "geometry" or
## "clipper". In the latter case the potentially faster Clipper polygon
## library will be invoked to assess winding directions.  The default is
## "geometry".
##
## If any polygon is self-crossing, the result is undefined.
##
## If @var{p} is a cell, each element is considered a polygon, the
## resulting @var{cww} is a cell of the same size.
##
## @seealso{polygonArea}
## @end deftypefn

## Author: Juan Pablo Carbajal <ajuanpi+dev@gmail.com>

function ccw = isPolygonCCW (px, py=[], lib="geometry")

  ## case of wrong number of input arguments
  if (nargin > 3 || nargin < 1)
    print_usage ();
  endif

  if (ischar (py))
    py = lower (py);
    if (ismember (py, {"geometry", "clipper"}))
      lib = py;
      py = [];
    else
      error ('Octave:invalid-fun-call', "use of '%s' not implemented", lib);
    endif
  endif
  if (! isempty (py))
    if (! strcmp (typeinfo (px), typeinfo (py)))
      error ('Octave:invalid-input-arg', 'X and Y should be of the same type');
    endif
    if (any (size (px) != size (py)) )
      error ('Octave:invalid-input-arg', 'X and Y should be of the same size');
    endif
  endif

  if (iscell (px))
    ## Cell Array Format
    ## Call this function on each cell
    if (isempty (py))
      py = cell (size (px));
    endif

    ccw = cellfun (@(u,v) isPolygonCCW (u,v,lib), px, py, "unif", 0);

  else
    ## Input are matrices
    ## merge them to one
    px = [px py];
    if (isempty (px))
      error ("isPolygonCW: empty input polygon encountered");
    elseif (strcmpi (lib, "clipper"))
      ## Clipper can do all of them in one call
      ccw = logical (isPolygonCW_Clipper (px));
      return
    endif

    if (any (isnan (px(:))))
      ## Inputs are many polygons separated with NaN
      ## Split them and call this function on each of them
      px  = splitPolygons (px);
      ccw = cellfun (@(u) isPolygonCCW (u,[],lib), px);

    else ## Here do the actual work
      ccw = polygonArea (px) > 0;

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

## Native testing
%!assert (isPolygonCCW (pccw));
%!assert (isPolygonCCW (pxccw, pyccw));
%!assert (isPolygonCCW ({pxccw, pxccw}, {pyccw, pyccw}), {true, true});
%!assert (~isPolygonCCW (pcw));
%!assert (isPolygonCCW ({pccw;pcw}), {true;false});
%!assert (isPolygonCCW(pnan), [true; false]);
%!assert (isPolygonCCW({pnan,pcw}),{[true;false], false});

## Clipper testing
%!assert (isPolygonCCW (pccw,[],"clipper"));
%!assert (isPolygonCCW (pxccw, pyccw,"clipper"));
%!assert (isPolygonCCW ({pxccw, pxccw}, {pyccw, pyccw},"clipper"), {true, true});
%!assert (~isPolygonCCW (pcw,[],"clipper"));
%!assert (isPolygonCCW ({pccw;pcw},[],"clipper"), {true;false});
%!xtest assert (isPolygonCCW(pnan,[],"clipper"), [true; false]);
%!xtest assert (isPolygonCCW({pnan,pcw},[],"clipper"),{[true; false], false});
