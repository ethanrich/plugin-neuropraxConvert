## Copyright (C) 2017-2019 Philip Nienhuis
## 
## This program is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or
## (at your option) any later version.
## 
## This program is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
## 
## You should have received a copy of the GNU General Public License
## along with this program.  If not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*- 
## @deftypefn {} {@var{oline}} = clipPolyline (@var{inpol}, @var{clippol}, @var{op})
## Clip (possibly composite) polylines with polygon(s) using one of boolean
## methods.
##
## @var{inpol} = Nx2 matrix of (X, Y) coordinates constituting the polylines(s)
## to be clipped.  Polyline sections are separated by [NaN NaN] rows.
## @var{clippol} = another Nx2 matrix of (X, Y) coordinates representing the
## clip polygon(s).   @var{clippol} may comprise separate and/or concentric
## polygons (the latter with holes).
##
## The argument @var{op}, the boolean operation, can be:
##
## @itemize
## @item 0: difference @var{inpol} - @var{clippol}
##
## @item 1: intersection ("AND") of @var{inpol} and @var{clippol} (= default)
## @end itemize
##
## Output array @var{oline} will be an Nx2 array of polyline sections
## resulting from the requested boolean operation.
##
## The optional argument @var{library} specifies which library to use for clipping.
## Currently only @asis{"clipper"} is implemented.
##
## @seealso{clipPolygon}
## @end deftypefn

## Author: Philip Nienhuis <prnienhuis@users.sf.net>
## Created: 2017-03-21

function [olin, nlin] = clipPolyline (p1, p2, op, library = "clipper")

  if ~(ismember (tolower (library), {"clipper"}))
    error ('Octave:invalid-fun-call', "clipPolyline: unimplemented polygon clipping library: '%s'", library);
  endif
  [olin, nlin] = clipPolyline_clipper (p1, p2, op);

endfunction


%!demo
%! sline = [0, 6.5; 1.25, 4; 1.25, 0; NaN, NaN; 0.25, 7; 1.75, 4; 1.75, 0];
%! for ii=1:10
%!   sline = [sline; [NaN NaN]; [ii/2+0.25, 7; ii/2+1.75, 4; ii/2+1.75, 0]];
%! endfor
%! pol2a = [1 2; 7 4; 4 7; 1 2; 2.5 3; 4 5.5; 5.5 4; 2.5 3; 1 2];
%! figure ();
%! hold on
%! patch (pol2a(:, 1), pol2a(:, 2), 'facecolor', 'y', 'edgecolor', 'b', 'linewidth', 2);
%! [olin, nlin] = clipPolyline_clipper (sline, pol2a, 1);
%! plot (olin(:, 1), olin(:, 2), 'r', 'linewidth', 3);
%! [olin, nlin] = clipPolyline (sline, pol2a, 0);
%! plot (olin(:, 1), olin(:, 2), 'g', 'linewidth', 3);
%! grid on;
%! box on;
%! axis equal;
%! legend ({"Clip polygon", "AND", "OR"});
%! title ("Demo: clipping polylines with polygons");
