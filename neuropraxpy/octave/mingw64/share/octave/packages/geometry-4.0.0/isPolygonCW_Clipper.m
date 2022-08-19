## Copyright (C) 2015-2017 Philip Nienhuis
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
## @deftypefn {Function File}  [@var{orientation}] = isPolygonCW_Clipper (@var{inpol})
## Inspect winding direction of polygon(s).
##
## Based on Clipper library (polyclipping.sf.net / 3rd Party / Matlab)
##
## @var{inpol} = Nx2 matrix of (X, Y) coordinates constituting the polygons(s)
## whose winding direction should be assessed.  Subpolygons are separated by
## [NaN NaN] rows.  
##
## Output argument @var{orientation} contains the winding direction(s) of
## each subpolygon: 0 for clockwise, 1 for counterclockwise.
##
## @end deftypefn

## Author: Philip Nienhuis <prnienhuis@users.sf.net>
## Created: 2015-05-03

function [orientation] = isPolygonCW_Clipper (inpoly)

  ## Input validation
  if (nargin < 1)
    print_usage ();
  endif
  if (! isnumeric (inpoly) || size (inpoly, 2) < 2)
    error ("ispolycw: inpoly should be a numeric Nx2 array");
  endif

  inpol = __dbl2int64__ (inpoly);

  ## Just find out orientation of polygons
  orientation = clipper (inpol);

endfunction
