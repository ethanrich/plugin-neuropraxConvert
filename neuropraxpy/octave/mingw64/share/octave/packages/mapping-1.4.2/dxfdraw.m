## Copyright (C) 2016-2022 Philip Nienhuis
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
## @deftypefn {} [@var{h}] = dxfdraw (@var{dxf})
## @deftypefnx {} [@var{h}] = dxfdraw (@var{dxf}, @var{clr})
## @deftypefnx {} [@var{h}] = dxfdraw (@dots{}, @var{name}, @var{value}, @dots{})
## Draw a map of a DXF file based on a DXF cell array or DXF drawing struct.
##
## Input argument @var{dxf} is the name of a DXF cell array (see
## dxfread.m), or the name of a DXF file, or a DXF drawing struct made
## by dxfparse.
##
## @var{clr} is the color used to draw the DXF contents.  All lines and
## arcs are drawn in the same color; similar for all filled surfaces.  
## For points, lines and polylines this can be a 3x1 RGB vector or a color
## code. For polygons it can be a 2x1 vector of color codes or a 2x3 double
## array of RGB entries.  The default is [0.7 0.7 0.7; 0.8 0.9 0.99].
##
## In addition several graphics properties can be specified, e.g., linestyle
## and linewidth. No checks are performed whether these are valid for the
## entities present in the DXF cell array or file.
##
## Currently the following entities are supported: POINT, LINE, POLYLINE,
## LWPOLYLINE, CIRCLE, ARC and 3DFACE.  For drawing CIRCLE and ARC entities
## functions from the geometry packge are required.
##
## Optional output argument @var{h} is the graphics handle of the resulting
## map.
##
## @seealso{dxfread, dxfparse}
## @end deftypefn

## Author: Philip Nienhuis <prnienhuis@users.sf.net>
## Created: 2016-01-25

function [h] = dxfdraw (dxf, clr=[0.7 0.7 0.7; 0.8 0.9 0.99], varargin)

  if (isstruct (dxf))
    ## Cursory validation
    fldnm = fieldnames (dxf);
    if (! all (ismember({"i3d", "ic", "ia", "j3", "jr", "il", "ip"}, fldnm)))
      error ("dxfdraw: invalid struct input for arg #1");
    endif

  else
    if (isempty (dxf))
      return

    elseif (iscell (dxf))
      ## Cursory Q-checks: minumum 3 columns, col 1 & 3 numeric, col #2 character
      if (size (dxf, 2) < 3 || ! all (all (cellfun (@isnumeric, dxf(:, [1, 3])))) ...
          || ! all (cellfun (@ischar, dxf(:, 2))))
        error ("dxfdraw: input arg #1 does not look like a valid dxf cell array");
      endif

    elseif (ischar (dxf))
      ## Maybe a DXF file?
      [~, ~, ext] = fileparts (dxf);
      if (isempty (ext) || ! strcmpi (ext, ".dxf"))
        ## Just add a .dxf suffix
        dxf = [dxf ".dxf"];
      endif
      fid = fopen (dxf);
      if (fid < 0)
        error ("File '%s' not found", dxf);
      else
        fclose (fid);
      endif
      ## Read DXF file into DXF cell array
      dxf = dxfread (dxf);

    else
      error (["dxfdraw: DXF cell array, DXF file name, or DXF drawing ", ...
              "struct expected for arg #1 "]);
    endif
  
    ## parse DXF cell array into a DXF drawing struct
    dxf = dxfparse (dxf, 0);
  endif

  ## We should have a valid struct now. Extract data
  i3d = dxf.i3d;
  is = dxf.is;
  ir = dxf.ir;
  ic = dxf.ic;
  ia = dxf.ia;
  j3 = dxf.j3;
  jr = dxf.jr;
  il = dxf.il;
  ip = dxf.ip;
  jf = dxf.jf;
  jw = dxf.jw;
  jl = dxf.jl;
  XYZ = dxf.XYZ;
  XYZp = dxf.XYZp;
  XY = dxf.XY;
  CIRCLES = dxf.CIRCLES;
  ARCS = dxf.ARCS;
  VRT3 = dxf.VRT3;
  FAC3 = dxf.FAC3;
  LWP = dxf.LWP;
  LWV = dxf.LWV;
  VRTS = dxf.VRTS;
  FACP = dxf.FACP;
  ## dxf not needed from here, clear it as it may hold lots of RAM needed for plot
  clear dxf;

  h = figure ();
  hold on;
  axis equal;

  if (i3d)
    if (is > 0)
      plot3 (XYZp(:, 1), XYZp(:, 2), XYZp(:, 3), "color", clr(1, :), varargin{:});
    endif
    if (ir > 0)
      plot3 (XYZ(:, 1), XYZ(:, 2), XYZ(:, 3), "color", clr(1, :), varargin{:});
    endif
    if (ic > 0)
      drawCircle3d (CIRCLES, "color", clr(1, :), varargin{:});
    endif
    if (ia > 0)
      drawCircleArc3d (ARCS, "color", clr(1, :), varargin{:});
    endif
    if (j3 > 0)
      patch ("vertices", VRT3, "faces", FAC3, "edgecolor", clr(1, :), ...
             "facecolor", clr(2, :), varargin{:}); 
    endif

  else
    if (is > 0)
      plot (XYZp(:, 1), XYZp(:, 2), "color", clr(1, :), varargin{:});
    endif
    if (ir > 0)
      plot (XYZ(:, 1), XYZ(:, 2), "color", clr(1, :), varargin{:});
    endif
    if (ic > 0)
      drawCircle (CIRCLES, "color", clr(1, :), varargin{:});
    endif
    if (ia > 0)
      drawCircleArc (ARCS, "color", clr(1, :), varargin{:});
    endif
    if (jr > 0)
      plot (XY(:, 1), XY(:, 2), "color", clr(1, :), varargin{:});
    endif
    if (il > 0)
      LWV(jw+1:end, :) = [];
      LWV(LWV == 0) = NaN;
      patch ("vertices", LWP, "faces", LWV, "edgecolor", clr(1, :), ...
            "facecolor", clr(2, :), varargin{:}); 
    endif

  endif

  if (ip > 0)
    FACP(jf+1:end, :) = [];
    FACP(FACP == 0) = NaN;
    if (! i3d)
      VRTS(:, 3) = [];
    endif
    patch ("vertices", VRTS, "faces", FACP, "edgecolor", clr(1, :), ...
           "facecolor", clr(2, :), varargin{:});
  endif

endfunction
