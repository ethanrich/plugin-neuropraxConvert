## Copyright (C) 2017-2022 Philip Nienhuis
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
## @deftypefn {} {@var{dxfo} =} dxfparse (@var{dxfi})
## @deftypefnx {} {@var{dxfo} =} dxfparse (@var{dxfi}, @var{outstyle})
## Parse a DXF struct (read by dxfread) into a DXF drawing struct or
## into a mapstruct.
##
## Input arg @var{dxfi} can be a DXF cell array produced by dxfread, or a
## DXF file name (dxfparse will invoke dfread to read it).
##
## Optional numeric input argument @var{outstyle} can be used to select
## a desired output format:
##
## @itemize
## @item 0 (default)
## Return an output struct optimized for fast drawing with dxfdraw.m
##
## @item 1
## Return an output struct containing 2D (Matlab-compatible) mapstructs
## like those returned by shaperead.m.  The output struct contains a "dxfpl"
## Polyline mapstruct for LINEs and open POLYLINEs and LWPOLYLINE entities;
## a "dxfpt" Point mapstruct for POINT entities; and a "dxfpg" Polygon
## mapstucts for closed POLYLINE and LWPOLYLINE entities.
##
## @item 2
## If the DXF file is 3D, return a 3D mapstruct as returned by shaperead.m
## with Z coordinates.
## @end itemize
##
## @seealso{dxfread, dxfdraw}
## @end deftypefn

## Author: Philip Nienhuis <prnienhuis@users.sf.net>
## Created: 2017-01-07

function [dxfo] = dxfparse (dxfi, outstyle=0)

  if (isempty (dxfi))
    return

  elseif (iscell (dxfi))
    ## Cursory Q-checks: minumum 3 columns, col 1 & 3 numeric, col #2 character
    if (size (dxfi, 2) < 3 || ! all (all (cellfun (@isnumeric, dxfi(:, [1, 3])))) ...
        || ! all (cellfun (@ischar, dxfi(:, 2))))
      error ("dxfdraw: input arg #1 does not look like a valid dxf cell array");
    endif

  elseif (ischar (dxfi))
    ## Maybe a DXF file?
    [~, ~, ext] = fileparts (dxfi);
    if (isempty (ext) || ! strcmpi (ext, ".dxf"))
      ## Just add a .dxf suffix
      dxfi = [dxfi ".dxf"];
    endif
    fid = fopen (dxfi);
    if (fid < 0)
      error ("File '%s' not found", dxfi);
    else
      fclose (fid);
    endif
    ## Read DXF file
    dxfi = dxfread (dxfi);

  else
    error ("dxfdraw: DXF cell array or DXF file name expected for arg #1 ");
  endif

  ## Interpret DXF struct
  ## 1. Cast numeric parts of dxf into double to speed up processing
  dxfn = cell2mat (dxfi(:, [1, 3]));

  ## 2. Find extent of different ENTITIES in file
  idx = find (dxfn(:, 1) == 0);
  idx(idx < strmatch ("ENTITIES", dxfi(:, 2))) = [];
  idx(find (ismember (idx, strmatch ("VERTEX", dxfi(:, 2))))) = [];
  idx(find (ismember (idx, strmatch ("SEQEND", dxfi(:, 2))))) = [];

  ## 3. Is DXF 3D or not
  iz = find (cell2mat (dxfi(:, 1)) == 30);
  i3d = ! isempty (iz) && any (abs (cell2mat (dxfi(iz, 3))) > eps);

  ## 4. Preallocate XYZp array for POINTS
  ns = numel (strmatch ("POINT", dxfi(:, 2)));
  is = 0;                                         ## Pointer array row counter
  if (outstyle == 0)
    XYZp = NaN (ns*2-1, 3);
    plyrs = cell (ns, 1);
  else
    ## Preallocate 2D mapstruct. If Z is needed it'll be added automatically
    ## the first time it is referenced in one action
    dxfpt = repmat (struct ("Geometry", "Point", ...
                            "X",        NaN, ...
                            "Y",        NaN), ns, 1);
  endif

  ## 5. Preallocate XYZ array to hold LINE & POLYLINE coordinates.
  ## 2 rows + NaN row for all LINE entities
  nr = numel (strmatch ("LINE", dxfi(:, 2))) * 3;
  ## 1 NaN row for each POLYLINE
  np = numel (strmatch ("POLYLINE", dxfi(:, 2)));
  nr += np;
  jl = jp = 0;
  if (outstyle == 0)
    ## Allocate layer info
    llyrs = cell (np+nr/3, 1);
    ## 1 row for each VERTEX
    nr += numel (strmatch ("VERTEX", dxfi(:, 2)));
    ## Avoid trailing NaN row
    XYZ = NaN (nr-1, 3);
    ir = 0;                                       ## (poly)lines / llyrs row index
    ## Vertices for polygons
    VRTS = NaN (nr-1, 3);
    ## Allocate provisionally 100 vertices per facet
    FACP = NaN (np, 100);
    ip = jf = 0;                                  ## polygon vertices/faces row indices
  else
    ## We can't foretell which POLYLINES are closed or open ==> assign struct
    ## arrays large enough for polygons and polylines alike
    dxfpl = repmat (struct ("Geometry",    "Polyline", ...
                            "BoundingBox", NaN (2, 2), ...
                            "X",           NaN, ...
                            "Y",           NaN), nr, 1);
    dxfpg = repmat (struct ("Geometry",    "Polygon", ...
                            "BoundingBox", NaN (2, 2), ...
                            "X",           NaN, ...
                            "Y",           NaN), nr, 1);
  endif

  ## 6. LWPOLYLINE - no real preallocation yet, will be extended incrementally
  nw = numel (strmatch ("LWPOLYLINE", dxfi(:, 2)));
  wlyrs = cell (nw, 1);
  if (outstyle == 0)
    LWP = NaN (5000, 2);
    LWV = NaN (250, 100);
    il = jw = jr = iw = 0;                        ## polyline vertices/faces/lyrs row indices
    XY = NaN (5000, 2);
  else
    ## Extend Polyline/-gon arrays. If we have LWPOLYLINE the DXF file is 2D
    dxfpl = repmat (struct ("Geometry",    "Polyline", ...
                            "BoundingBox", NaN (2, 2), ...
                            "X",           NaN, ...
                            "Y",           NaN), nr+nw, 1);
    dxfpg = repmat (struct ("Geometry",    "Polygon", ...
                            "BoundingBox", NaN (2, 2), ...
                            "X",           NaN, ...
                            "Y",           NaN), nr+nw, 1);
  endif

  ## 7. Preallocate array for CIRCLEs
  nc = numel (strmatch ("CIRCLE", dxfi(:, 2)));
  if (i3d)
    CIRCLES = zeros (nc, 4);
  else
    CIRCLES = zeros (nc, 3);
  endif
  ic = 0;                                         ## Circle row counter
  clyrs = cell (nc, 1);

  ## 8. Preallocate array for ARCs
  na = numel (strmatch ("ARC", dxfi(:, 2), "exact"));
  if (i3d)
    ARCS = zeros (na, 6);
  else
    ARCS = zeros (na, 5);
  endif
  ia = 0;                                         ## Arc row counter
  alyrs = cell (na, 1);

  ## 9. Preallocate 3DFACE array
  n3 = numel (strmatch ("3DFACE", dxfi(:, 2)));
  VRT3 = NaN (4*n3, 3);
  FAC3 = NaN (n3, 5);
  iv = j3 = id = 0;                               ## 3Dface / dlyrs row counter
  dlyrs = cell (n3, 1);

  ## 10. Start interpreting. For each ENTITY:
  for ii=1:numel (idx) - 1
    switch dxfi{idx(ii), 2}

      case "POINT"
        x1 = dxfn(find (dxfn(idx(ii):idx(ii+1), 1) == 10) + idx(ii)-1, 2);
        y1 = dxfn(find (dxfn(idx(ii):idx(ii+1), 1) == 20) + idx(ii)-1, 2);
        z1 = dxfn(find (dxfn(idx(ii):idx(ii+1), 1) == 30) + idx(ii)-1, 2);
        lb = dxfi(find (dxfn(idx(ii):idx(ii+1), 1) == 8) + idx(ii)-1, 2){1};
        if (outstyle == 0)
          ## X, Y [,Z] coordinates
          XYZp(++is, 1) = x1;
          XYZ(is, 2)    = y1;
          if (i3d)
            XYZp(is, 3) = z1;
          endif
          plyrs{is} = lb;
          ## Leave NaN row before next point
          ++is;
        else
          dxfpt(++is).Geometry = "Point";
          dxfpt(is).X = x1;
          dxfpt(is).Y = y1;
          if (outstyle == 2 && i3d)
            dxfpt(is).Z = z1;
          endif
          dxfpt(is).LAYER = lb;
          dxfpt(is)._SOURCE_ = "DXF_POINT";
        endif

      case "LINE"
        ## X, Y [,Z] coordinates of end points
        x1 = dxfn(find (dxfn(idx(ii):idx(ii+1), 1) == 10) + idx(ii)-1, 2);
        y1 = dxfn(find (dxfn(idx(ii):idx(ii+1), 1) == 20) + idx(ii)-1, 2);
        x2 = dxfn(find (dxfn(idx(ii):idx(ii+1), 1) == 11) + idx(ii)-1, 2);
        y2 = dxfn(find (dxfn(idx(ii):idx(ii+1), 1) == 21) + idx(ii)-1, 2);
        lb = dxfi(find (dxfn(idx(ii):idx(ii+1), 1) == 8) + idx(ii)-1, 2){1};
        if (i3d)
          z1 = dxfn(find (dxfn(idx(ii):idx(ii+1), 1) == 30) + idx(ii)-1, 2);
          z2 = dxfn(find (dxfn(idx(ii):idx(ii+1), 1) == 31) + idx(ii)-1, 2);
        endif
        if (outstyle == 0)
          XYZ(++ir, 1) = x1;
          XYZ(ir, 2)   = y1;
          XYZ(++ir, 1) = x2;
          XYZ(ir, 2)   = y2;
          if (i3d)
            XYZ(ir-1, 3) = z1;
            XYZ(ir, 3)   = z2;
          endif
          llyrs{++jl} = lb;
          ++ir;
        else
          dxfpl(++jl).Geometry = "Polyline";
          dxfpl(jl).X = [x1 x2];
          dxfpl(jl).Y = [y1 y2];
          dxfpl(jl).BoundingBox = [min(x1, x2) min(y1, y2); max(x1, x2) max(y1, y2)];
          if (outstyle == 2 && i3d)
            dxfpl(jl).Z = [z1 z2];
          endif
          dxfpl(jl).LAYER = lb;
          dxfpl(jl)._SOURCE_ = "DXF_LINE";
        endif

      case "POLYLINE"
        ## Find nr. of vertices
        jv = strmatch ("VERTEX", dxfi(idx(ii):idx(ii+1), 2)) + idx(ii) - 1;
        nv = numel (jv);
        ## Get polyline flag and check if it's a closed one (i.e., a polygon)
        pflags = uint8 (dxfn(find (dxfn(idx(ii):idx(ii+1), 1) == 70) + idx(ii) - 1, 2));
        ## Polygon / closed polyline. Get vertices
        xx = dxfn(find (dxfn(jv(1):idx(ii+1), 1) == 10) + jv(1) - 1, 2);
        yy = dxfn(find (dxfn(jv(1):idx(ii+1), 1) == 20) + jv(1) - 1, 2);
        lb = dxfi(find (dxfn(idx(ii):idx(ii+1), 1) == 8) + idx(ii)-1, 2){1};
        if (i3d)
          zz = dxfn(find (dxfn(jv(1):idx(ii+1), 1) == 30) + jv(1) - 1, 2);
        endif
        if (outstyle == 0)
          if (bitget (pflags, 1))
            ## Polygon / closed polyline. Get vertices
            VRTS(++ip:ip+nv-1, 1) = xx;
            VRTS(ip:ip+nv-1, 2)   = yy;
            if (i3d)
              VRTS(ip:ip+nv-1, 3) = zz;
            endif
            ip += nv - 1;
            ++jf;
            ## Update faces
            FACP(jf, 1:nv+1) = [ (ip-nv + 1 : ip) (ip - nv + 1) ];
          else
            ## Open polyline
            XYZ(++ir:ir+nv-1, 1) = xx;
            XYZ(ir:ir+nv-1, 2)   = yy;
            if (i3d)
              XYZ(ir:ir+nv-1, 3) = zz;
            endif
            ir += nv;
          endif
          llyrs(++jl) = lb;
        else
          if (bitget (pflags, 1))
            ## Polygon / closed polyline
            dxfpg(++jp).Geometry = "Polygon";
            dxfpg(jp).X = xx';
            dxfpg(jp).Y = yy';
            dxfpg(jp).BoundingBox = [min(xx) min(yy); max(xx) max(yy)];
            if (outstyle == 2 && i3d)
              dxfpg(jp).Z = zz';
            endif
            dxfpg(jp).LAYER = lb;
            dxfpg(jp)._SOURCE_ = "DXF_POLYLN";
          else
            dxfpl(++jl).Geometry = "Line";
            dxfpl(jl).X = xx';
            dxfpl(jl).Y = yy';
            dxfpl(jl).BoundingBox = [min(xx) min(yy); max(xx) max(yy)];
            if (outstyle == 2 && i3d)
              dxfpl(jl).Z = zz';
            endif
            dxfpl(jl).LAYER = lb;
            dxfpl(jl)._SOURCE_ = "DXF_POLYLN";
          endif
        endif

      case "LWPOLYLINE"
        if (i3d)
          error ("Inconsistent DXF input - LWPOLYLINE = 2D but there are 3D entities");
        endif
        ## Nr. of vertices
        nw = dxfn(find (dxfn(idx(ii):idx(ii+1), 1) == 90) + idx(ii)-1, 2);
        xx = dxfn(find (dxfn(idx(ii):idx(ii+1), 1) == 10) + idx(ii)-1, 2);
        yy = dxfn(find (dxfn(idx(ii):idx(ii+1), 1) == 20) + idx(ii)-1, 2);
        lb = dxfi(find (dxfn(idx(ii):idx(ii+1), 1) ==  8) + idx(ii)-1, 2){1};
        ## Get polyline flag and check if it's a closed one (i.e., a polygon)
        pflags = uint8 (dxfn(find (dxfn(idx(ii):idx(ii+1), 1) == 70) + idx(ii) - 1, 2));
        if (outstyle == 0)
          if (bitget (pflags, 1))
            ## Closed polyline
            if (il + nw > size (LWP, 1))
              ## Extend LWP array (vertices)
              LWP = [LWP ; NaN(5000, 2)];
            endif
            if (jw + 1 > size (LWV, 1))
              ## Extend LWV array (faces)
              LWV = [LWV ; NaN(250, size(LWV, 2))];
            endif
            LWP(il+1:il+nw, 1) = xx;
            LWP(il+1:il+nw, 2) = yy;
            ++jw;
            LWV(jw, 1:nw+1) = [ (il+1 : il+nw) (il + 1) ];
            il += nw - 1;
          else
            ## Open polyline
            if (jr + nw + 1 > size (XY, 1))
              ## Extend XY array
              XY = [XY ; XY(5000, 2)];
            endif
            XY(jr+1:jr+nw, 1) = xx;
            XY(jr+1:jr+nw, 2) = yy;
            jr += nw;
          endif
          wlyrs(++iw) = lb;
        else
          if (bitget (pflags, 1))
            ## Polygon / closed polyline
            dxfpg(++jp).Geometry = "Polygon";
            dxfpg(jp).X = xx';
            dxfpg(jp).Y = yy';
            dxfpg(jp).BoundingBox = [min(xx) min(yy); max(xx) max(yy)];
            dxfpg(jp).LAYER = lb;
            dxfpg(jp)._SOURCE_ = "DXF_LWPOLY";
          else
            dxfpl(++jl).Geometry = "Line";
            dxfpl(jl).X = xx';
            dxfpl(jl).Y = yy';
            dxfpl(jl).BoundingBox = [min(xx) min(yy); max(xx) max(yy)];
            dxfpl(jl).LAYER = lb;
            dxfpl(jl)._SOURCE_ = "DXF_LWPOLY";
          endif
        endif

      case "CIRCLE"
        if (outstyle == 0)
          ## Get center point
          CIRCLES(++ic, 1) = dxfn(find (dxfn(idx(ii):idx(ii+1), 1) == 10) + idx(ii)-1, 2);
          CIRCLES(ic, 2)   = dxfn(find (dxfn(idx(ii):idx(ii+1), 1) == 20) + idx(ii)-1, 2);
          if (i3d)
            CIRCLES(ic, 3) = dxfn(find (dxfn(idx(ii):idx(ii+1), 1) == 30) + idx(ii)-1, 2);
            CIRCLES(ic, 4) = dxfn(find (dxfn(idx(ii):idx(ii+1), 1) == 40) + idx(ii)-1, 2);
          else
            CIRCLES(ic, 3) = dxfn(find (dxfn(idx(ii):idx(ii+1), 1) == 40) + idx(ii)-1, 2);
          endif
          clyrs(ic) = dxfi(find (dxfn(idx(ii):idx(ii+1), 1) == 8) + idx(ii)-1, 2){1};
        endif

      case "ARC"
        if (outstyle == 0)
          ## Get center point
          ARCS(++ia, 1) = dxfn(find (dxfn(idx(ii):idx(ii+1), 1) == 10) + idx(ii)-1, 2);
          ARCS(ia, 2)   = dxfn(find (dxfn(idx(ii):idx(ii+1), 1) == 20) + idx(ii)-1, 2);
          if (i3d)
            ARCS(ia, 3) = dxfn(find (dxfn(idx(ii):idx(ii+1), 1) == 30) + idx(ii)-1, 2);
            ARCS(ia, 4) = dxfn(find (dxfn(idx(ii):idx(ii+1), 1) == 40) + idx(ii)-1, 2);
            ARCS(ia, 5) = wrapTo180 (dxfn(find (dxfn(idx(ii):idx(ii+1), 1) == 50) + idx(ii)-1, 2));
            ARCS(ia, 6) = wrapTo180 (dxfn(find (dxfn(idx(ii):idx(ii+1), 1) == 51) + idx(ii)-1, 2)) - ARCS(ia, 5);
            if (ARCS(ia, 6) < 0)
              ARCS(ia, 6) = wrapTo360 (ARCS(ia, 6));
            endif
          else
            ARCS(ia, 3) = dxfn(find (dxfn(idx(ii):idx(ii+1), 1) == 40) + idx(ii)-1, 2);
            ARCS(ia, 4) = wrapTo180 (dxfn(find (dxfn(idx(ii):idx(ii+1), 1) == 50) + idx(ii)-1, 2));
            ARCS(ia, 5) = wrapTo180 (dxfn(find (dxfn(idx(ii):idx(ii+1), 1) == 51) + idx(ii)-1, 2)) - ARCS(ia, 4);
            if (ARCS(ia, 5) < 0)
              ARCS(ia, 5) = wrapTo360 (ARCS(ia, 5));
            endif
          endif
          alyrs{ia} = dxfi(find (dxfn(idx(ii):idx(ii+1), 1) == 8) + idx(ii)-1, 2){1};
        endif

      case "3DFACE"
        if (outstyle == 0)
          VRT3(++iv, 1) = dxfn(find (dxfn(idx(ii):idx(ii+1), 1) == 10) + idx(ii)-1, 2);
          VRT3(iv, 2)   = dxfn(find (dxfn(idx(ii):idx(ii+1), 1) == 20) + idx(ii)-1, 2);
          VRT3(iv, 3)   = dxfn(find (dxfn(idx(ii):idx(ii+1), 1) == 30) + idx(ii)-1, 2);
          VRT3(++iv, 1) = dxfn(find (dxfn(idx(ii):idx(ii+1), 1) == 11) + idx(ii)-1, 2);
          VRT3(iv, 2)   = dxfn(find (dxfn(idx(ii):idx(ii+1), 1) == 21) + idx(ii)-1, 2);
          VRT3(iv, 3)   = dxfn(find (dxfn(idx(ii):idx(ii+1), 1) == 31) + idx(ii)-1, 2);
          VRT3(++iv, 1) = dxfn(find (dxfn(idx(ii):idx(ii+1), 1) == 12) + idx(ii)-1, 2);
          VRT3(iv, 2)   = dxfn(find (dxfn(idx(ii):idx(ii+1), 1) == 22) + idx(ii)-1, 2);
          VRT3(iv, 3)   = dxfn(find (dxfn(idx(ii):idx(ii+1), 1) == 32) + idx(ii)-1, 2);
          VRT3(++iv, 1) = dxfn(find (dxfn(idx(ii):idx(ii+1), 1) == 13) + idx(ii)-1, 2);
          VRT3(iv, 2)   = dxfn(find (dxfn(idx(ii):idx(ii+1), 1) == 23) + idx(ii)-1, 2);
          VRT3(iv, 3)   = dxfn(find (dxfn(idx(ii):idx(ii+1), 1) == 33) + idx(ii)-1, 2);
          ++j3;
          FAC3(j3, :) = [ ((j3-1)*4+1 : (j3-1)*4+4) (j3-1)*4+1 ];
          ++id;
          dlyrs{id, 1} = dxfi(find (dxfn(idx(ii):idx(ii+1), 1) == 8) + idx(ii)-1, 2){1};
        endif

      otherwise
        ## Ignored entities

    endswitch
  endfor

  ## Put all info in a struct to speed up redrawing
  if (outstyle == 0)
    dxfo.i3d = i3d;
    dxfo.is = is;
    dxfo.ir = ir;
    dxfo.ic = ic;
    dxfo.ia = ia;
    dxfo.j3 = j3;
    dxfo.jr = jr;
    dxfo.il = il;
    dxfo.ip = ip;
    dxfo.jf = jf;
    dxfo.jw = jw;
    dxfo.jl = jl;
    dxfo.XYZ = XYZ;
    dxfo.XYZp = XYZp;
    if (il > 0)
      dxfo.LWP = LWP(1:il+1, :);
      dxfo.LWV = LWV(1:jw, :);
      LWV(LWV == 0) = NaN;
    else
      dxfo.LWP = dxfo.LWV = [];
    endif
    dxfo.XY = XY(1:jr, :);
    dxfo.CIRCLES = CIRCLES;
    dxfo.ARCS = ARCS;
    dxfo.VRT3 = VRT3;
    dxfo.FAC3 = FAC3;
    dxfo.VRTS = VRTS;
    dxfo.FACP = FACP;
  else
    if (is > 0)
      dxfo.dxfpt = dxfpt;
    endif
    if (jl > 0)
      dxfo.dxfpl = dxfpl(1:jl);
    endif
    if (jp > 0)
      dxfo.dxfpg = dxfpg(1:jp);
    endif
  endif

endfunction
