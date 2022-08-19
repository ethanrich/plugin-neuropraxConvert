## Copyright (C) 2017-2022 Philip Nienhuis
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
## along with this program.  If not, see
## <http://www.gnu.org/licenses/>.

## -*- texinfo -*- 
## @deftypefn {Function File} [@var{Xo}, @var{Yo}] = polycut (@var{Xi}, @var{Yi})
## @deftypefnx {Function File} [@var{Xo}, @var{Yo}, @var{Zo}] = polycut (@var{Xi}, @var{Yi}, @var{Zi})
## @deftypefnx {Function File} [@var{XY_o}] = polycut (@var{XY_i})
## Reorder nested multipart polygons in such a way that branch cuts aren't
## drawn when using the patch command.
##
## Normally when drawing multipart nested polygons (with holes and other
## polygons inside the holes; polygon parts separated by NaNs) holes will be
## filled.  Connecting the polygon parts by deleting the NaNs leads to edges
## of some polygon parts to be drawn across neighboring polygon parts.
## polycut reorders the polygon parts such that the last vertices of polygon
## parts have minimum distance to the first vertices of the next parts,
## avoiding the connecting lines ("branch cuts") to show up in the drawing.
##
## Input consists of separate X, Y, and -optionally- Z vectors, or an Nx2 or
## Nx3 matrix of vertex coordinates (X, Y) or (X, Y, Z).  If individual X and
## Y vectors were input, the output consists of the same number of vectors.
## If an Nx 2 or Nx3 array was input, the output will be an Nx2 or Nx3 matrix
## as well.
##
## polycut is a mere wrapper around the function polygon2patch in the OF
## geometry package.
##
## @end deftypefn

## Author: Philip Nienhuis <prnienhuis@users.sf.net>
## Created: 2017-11-10

function [X, Y, Z] = polycut (varargin)

  if (isempty (which ("polygon2patch")))
    error (["function polygon2patch not found. OF geometry package ", ...
            "installed and loaded?"]);
  endif
  [X, Y, Z] = polygon2patch (varargin{:});

endfunction
