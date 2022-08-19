## Copyright (C) 2014-2022 Philip Nienhuis
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
## @deftypefn {Function File} @var{H} = mapshow (@var{data})
## @deftypefnx {Function File} @var{H} = mapshow (@var{data}, @var{clr})
## @deftypefnx {Function File} @var{H} = mapshow (@var{data}, @var{clr}, ...)
## @deftypefnx {Function File} @var{H} = mapshow (@var{data}, ...)
## @deftypefnx {Function File} @var{H} = mapshow (@var{X}, @var{Y})
## @deftypefnx {Function File} @var{H} = mapshow (@var{X}, @var{Y}, @var{clr})
## Draw a map based on raster or shapefile data.
##
## @var{data} can be:
##
## @itemize
## @item The filename of a GIS raster file (any file supported by the GDAL
## library) or of an ArcGIS shapefile.  mapshow will invoke rasterread.m
## and rasterdraw.m.  If no file extension is specified (just base name)
## mapshow assumes it is a shapefile.
##
## @item A raster band struct created by rasterread.m; in that case the
## corresponding raster info struct (also made by rasterread.m) is required
## as second input argument.
##
## @item A struct created by shaperead.m.  @var{data} can be a mapstruct or
## an Octave-style shape struct.
##
## @item  The base name or full file name of an ArcGis shape file.  mapshow
## will invoke shaperead.m and shapedraw.m
## @end itemize
##
## If the first two arguments to mapshow.m contain numeric vectors, mapshow
## will simply draw the vectors as XY lines. The vectors can contain NaNs (in
## identical positions) to separate parts.
##
## For raster maps currently no further input arguments are recognized.
## For shapefile data, optional argument @var{clr} can be a predefined color
## ("k", "c", etc.), and RGB triplet, or a 2 X 1 column vector of predefined
## colors or RGB triplets (each row containing a predefined color or triplet).
## The upper row will be used for points and lines, the lower row for solid
## shape features.  For XY data, only the first row is used.  One-character
## color codes can be preceded by one-character linestyle indicators
## (":", "-", "--", "-.") to modify the linestyle for polylines, or marker
## styles ("o", "*", ".", "+", "@", ">", "<", "s", "d", "h", "v", "^") for
## points.
##
## Any other arguments are considered graphics properties for (multi-)points,
## polylines and polygons and will be conveyed as-is to the actual plotting
## routines.
##
## Additionally, if the first argument is a shape struct, mapshow accepts a
## property-value pair "symbolspec" (minimum abbreviation "symb") with a value
## comprising a cell array containing instructions on how to display the
## shape contents.  Multiple sympolspec property/value pairs can be specified.
##
## Return argument @var{h} is a handle to the plot figure.
##
##
## Examples:
##
## @example
##   H = mapshow ("/full/path/to/map")
##   (draws a raster map and returns the figure handle in H)
## @end example
##
## @example
##   H = mapshow ("shape.shp", ":g")
##   H = mapshow ("shape.shp", "color", "g", "linestyle", ":")
##   (draws a polygon shapefile "shape.shp" with green
##    dotted lines and return figure handle in H)
## @end example
##
## @example
##   mapshow (X, Y, "k")
##   (plot vectors X and Y in black color)
## @end example
##
## @example
##   mapshow (X, Y, "-.r", "linewidth", 5)
##   (plot vectors X and Y as a dashdotted thick red line)
## @end example
##
## @example
##   mapshow (data, "symbolspec", symsp1, "symb", symsp2)
##   (draw contents of shapestruct (or mapstruct) data
##    according to the symbolspecs symsp1 and symsp2)
## @end example
##
## @seealso{geoshow, shapedraw, shapeinfo, shaperead, shapewrite, makesymbolspec, rasterread, rasterdraw, rasterinfo}
## @end deftypefn

## Author: Philip Nienhuis <prnienhuis@users.sf.net>
## Created: 2014-11-17 after a suggestion by Carnë Draug
## Updates:
## 2014-2015  many many fixes
## 2015-02-04 Relax check for mapstructs; don't test BoundingBox (Point shapes)
## 2015-02-11 Fix minor syntax error in do_symspecs rule check

function h = mapshow (varargin)

  ## Check "hold" state; creates a new figure if none was present
  if (ishold())
    old_holdstate = "on";
  else
    old_holdstate = "off";
  endif
  hold on;

  if ischar (varargin{1})
    [fp, fn, ext] = fileparts (varargin{1});
    if (isempty (ext))
      ## Find out what type of file
      fl = dir ([fp filesep fn ".*"]);
      if (isempty (fl))
        error ("mapshow: file '%s.*' not found", varargin{1});
      endif
      id = find (! cellfun ("isempty", strfind (lower ({fl.name}), ".shp")));
      varargin{1} = [fp filesep fl(id).name];
       ## Directly plot shapefile. Strip away symbolspecs
      isym = find (strncmpi ("symbolspec", varargin(2:end), 4));
      if (! isempty (isym))
        warning ("mapshow: ignoring symbolspecs when drawing .shp directly");
      endif
      varargin(isym:isym+1) = [];
      h = shapedraw (varargin{:});
   elseif (strncmpi (lower (ext), ".shp", 4))
      ## Directly plot shapefile. Strip away symbolspecs
      isym = find (strncmpi ("symbolspec", varargin(2:end), 4));
      if (! isempty (isym))
        warning ("mapshow: ignoring symbolspecs when drawing .shp directly");
      endif
      varargin(isym:isym+1) = [];
      h = shapedraw (varargin{:});
    else
      ## Assume any raster file
      h = rasterdraw (varargin{1});
    endif

  elseif (nargin > 1 && israster (varargin{1}) && isstruct (varargin{2}))
    ## Assume raster structs
    h = rasterdraw (varargin{:});

  elseif (isshape (varargin{1}))
    ## Assume a shape struct or a shape file name. Get optional symbolspec
    isym = find (strncmpi("symbolspec", varargin(2:end), 4));
    if (! isempty (isym))
      ## FIXME move this stanze into a separate subfunction
      ## Found symbolspec. Check if it can be invoked
      if (ischar (varargin{1}))
        ## Symbolspec not applicable to shape file argument
        error ("mapshow: symbolspec not supported when plotting shape files directly\n");
      endif
      ## First get & check geometry
      symspecs = {varargin{isym+2}};
      h = do_symspecs (varargin{1}, symspecs);
    else
      ## No symbolspec to process; plot shape(file) directly
    endif

  elseif (nargin >= 2 && isvector (varargin{1}) && isvector (varargin{2}))
    ## Assume args #1 & #2 are lines. Find optional color argument.
    if (nargin >= 3)
      if (ischar (varargin{3}))
        ## Assume arg #3 is a valid color name or character like 'b'
        h = plot (varargin{1}, varargin{2}, varargin{3});
      elseif (isnumeric (varargin{3} && size (varargin{3}, 2) == 3))
        ## Assume arg#3 is a valid color triplet
        h = plot (varargin{1}, varargin{2}, "color", varargin{3});
      else
        error ("mapshow: color argment expected for arg. #3\n");
      endif
      axis equal;
    else
      ## Plot args #1 & #2 without further ado
      h = plot (varargin{1}, varargin{2}, "color", [0.6 0.6 0.6]);
    endif

  else
    error ("mapshow: only plotting of shapes or vector data is implemented\n");
  endif

  ## Reset hold state
  hold (old_holdstate);

  axis equal;

  if (! nargout)
    h = 0;
  endif

endfunction


##--------------------------------------------------------------------------
## Copyright (C) 2014,2015 Philip Nienhuis <prnienhuis@users.sf.net>

function retval = isshape (s)

  retval = false;
  ## Check if s is a recognized shape file struct; just a brief check
  if (isstruct (s))
    ## Yep. Find out what type
    fldn = fieldnames (s);
    if (all (ismember ({"vals", "shpbox"}, fldn)))
      ## Assume it is an Octave-style struct read by shaperead
      retval = 2;
    elseif (all (ismember ({"Geometry", "X"},  fldn)))
      ## Assume it is a Matlab-style mapstruct
      retval = 1;
    endif
  endif

endfunction


##--------------------------------------------------------------------------
## Copyright (C) 2015 Philip Nienhuis <prnienhuis@users.sf.net>

function retval = israster (s)

  retval = 0;
  ## Check if s is a recognized raster struct; just a brief check
  if (isstruct (s))
    ## Yep. Find out what type
    fldn = fieldnames (s);
    if (ismember ("data", fldn) && ismatrix (s.data))
      ## Assume it is an Octave-style struct read by shaperead
      retval = 1;
    endif
  endif

endfunction


##--------------------------------------------------------------------------
## Copyright (C) 2015 Philip Nienhuis <prnienhuis@users.sf.net>
##
## Process symbolspecs one by one

function h = do_symspecs (shp, symspecs)

  for jj=1:numel (symspecs);
    symspec = symspecs{jj};
    geom =  lower (symspec {1});
    if (! ischar (geom))
      error ("mapshow: char argument expected for Geometry field in symbolspec\n");
    elseif (! ismember (lower (geom), {"point", "multipoint", "line", ...
                                       "polyline", "polygon", "patch"}))
      error ("mapshow: unknown Geometry: %s in symbolspec\n", geom);
    endif
    for ii=2:numel (symspec)
      rule = symspec{ii};
      if (! ischar (rule{1}))
        warning ("mapshow: char string expected for attribute of rule %d in symbolspec\n", ii-1);
      endif
      ## Get property or attribute
      if (strcmpi (rule{1}, "default"))
        ## Rule applies to all shape features with geom. Plot shape features
        if (isshape (shp) == 1)
          ## mapstruct shapes are allowed to be heterogeneous
          gdx = find (strcmpi (geom, {shp.Geometry}));
          h = shapedraw (shp(gdx), rule(3:end){:});
        elseif (isshape (shp) == 2)
          h = shapedraw (shp, rule(3:end){:});
        else
          error ("mapshow: improper shape struct type\n");
        end

      elseif (isshape (shp) == 1)
        ## ML mapstruct type shape struct. Apply to proper geometry features
        gdx = find (strcmpi (geom, {shp.Geometry}));
        ## Rule applies to one specific attribute. Check if it exists
        if (ismember (rule{1}, fieldnames (shp)))
          ## Try to apply rule. We need try-catch to catch non-matching classes
          if (islogical (rule{2}))
            ## Find attributes that are true. FIXME catches zero attributes too
            try
              idx = find ([shp(gdx).(rule{1})]);
            catch
              warning ("mapshow: rule %d not applicable to atribute %s\n", ...
                        ii-1, rule{1});
            end_try_catch
          elseif (isnumeric (rule{2}))
            ## Check which shape features have attribute values in the range
            minr = min (rule{2});
            maxr = max (rule{2});
            try
              idx = find ([shp(gdx).(rule{1})] >= minr & ...
                          [shp(gdx).(rule{1})] <= maxr);
            catch
              warning ("mapshow: rule %d not applicable to atribute %s\n", ...
                        ii-1, rule{1});
            end_try_catch
          elseif (ischar (rule{2}))
            ## Match strings
            try
              idx = find (strcmp (rule{2}, {shp(gdx).(rule{1})}));
            catch
              warning ("mapshow: rule %d not applicable to atribute %s\n", ...
                        ii-1, rule{1});
            end_try_catch
          endif
          ## Plot shape features
          h = shapedraw (shp(gdx(idx)), rule(3:end){:});
        else
          ## Attribute not found
          warning ("mapshow: attribute '%s' in rule #%d not found\n", rule(ii){1});
        endif

      elseif (isshape (shp) == 2)
        ## Oct-style shp struct. Prepare indexing into coords
        shp.idx = [ shp.idx; (size(shp.vals, 1) + 2) ];
        ## Some fields are not explicitly in the shape
        switch rule{1}
          ## Coordinates
          case "X"
            shp_field = shp.vals(:, 1);
          case "Y"
            shp_field = shp.vals(:, 2);
          case "Z"
            shp_field = shp.vals(:, 3);
          case "M"
            ## Measure
            shp_field = shp.vals(:, 4);
          case "npt"
            ## Nr. or points/vertices
            shp_field = shp.npt;
          case "npr"
            ## Nr. of parts
            try
              shp_field = cellfun (@numel, shp.npr);
            catch
              warning ("mapshow: rule %d attribute 'npr' not found\n", ii-1);
              shp_field = NaN;
            end_try_catch
          #case "bbox"
          #  shp_field = shp.bbox;
          otherwise
            ## "Regular" attributes
            if (ismember (rule{1}, fieldnames(shp)))
              shp_field = shp.(rule{1});
            else
              warning ("mapshow: rule %d attribute '%s' not found\n", ...
                       ii-1, rule{1});
            endif
        endswitch
        ## Try to apply rule. We need try-catch to catch non-matching classes
        if (islogical (rule{2}))
          ## Find attributes that are true. FIXME catches zero attributes too
          try
            idx = find (shp_field);
          catch
            warning ("mapshow: rule %d not applicable to atribute %s\n", ...
                      ii-1, rule{1});
          end_try_catch
        elseif (isnumeric (shp_field))
          ## Check which shape features have attribute values in the range
          minr = min (rule{2});
          maxr = max (rule{2});
          if (ismember (rule{1}, {"X", "Y", "Z", "M"}))
            ##  Multiple attribute values per shape feature (polylines, ...)
            idx = [];
            try
              for jj=1:numel (shp.idx)
                ## Include all polylines/-gons/multipatches with at least
                ## one value in the range
                idx = [idx; (any ( ...
                            shp_field(shp.idx(jj:shp.idx(jj+1)-2)) >= minr & ...
                            shp_field(shp.idx(jj:shp.idx(jj+1)-2)) <= maxr)) ];
              endfor
            catch
              warning ("mapshow: rule %d not applicable to atribute %s\n", ...
                     ii-1, rule{1});
            end_try_catch
          else
            ## Single attribute values per shape feature
            try
              idx = find (shp_field >= minr & ...
                          shp_field <= maxr);
            catch
              warning ("mapshow: rule %d not applicable to atribute %s\n", ...
                        ii-1, rule{1});
            end_try_catch
          endif
        elseif (iscellstr (shp_field))
          ## Match strings
          try
            idx = find (strcmp (rule{2}, shp_field));
          catch
            warning ("mapshow: rule %d not applicable to atribute %s\n", ...
                      ii-1, rule{1});
          end_try_catch
        endif
        ## Plot shape features; but first set up struct
        vals = zeros(0, 6);
        jdx = [];
        for jj=1:numel (idx)
          jdx = [ jdx ; (size (vals, 1) + 1) ];
          vals = [ vals; ...
                   shp.vals(shp.idx(idx(jj)):shp.idx(idx(jj)+1)-2, :); ...
                   NaN(1, 6) ];
        endfor
        vals(end, :) = [];
        sct.shpbox    = shp.shpbox;
        sct.vals      = vals;
        sct.bbox      = shp.bbox(idx, :);
        sct.npt       = shp.npt(idx);
        sct.npr       = shp.npr(idx);
        sct.idx       = jdx;
        sct.(rule{1}) = shp.(rule{1})(idx);
        ## Draw results
        h = shapedraw (sct, rule(3:end){:});

      else
        ## Unrecognized shape type
        error ("mapshow: improper shape struct type\n");

      endif
    endfor
  endfor

endfunction
