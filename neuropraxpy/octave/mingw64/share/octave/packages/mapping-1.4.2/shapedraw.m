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
## @deftypefn  {Function File} [@var{h}] = shapedraw (@var{shp})
## @deftypefnx {Function File} [@var{h}] = shapedraw (@var{shp}, @var{clr})
## @deftypefnx {Function File} [@var{h}] = shapedraw (@var{shp}, @var{clr}, ...)
## @deftypefnx {Function File} [@var{h}] = shapedraw (@var{shp}, ...)
## Plot contents of a shapefile, a map-/geostruct or a struct made by
## shaperead.m.
##
## @var{shp} can be a shapefile (will be read and plotted), a struct made by
## shaperead, or a mapstruct or geostruct, possibly made by some other
## function.  shapeplot.m will try to determine the type.  Points, MultiPoints,
## Polylines, Polygons and MultiPatch shape features can be plotted.
##
## The optional argument @var{clr} can be a predefined color name ('b', 'green',
## etc.) or an RGB triplet.  The default is [0.6, 0.6, 0.6] which produces a
## grey plot.  Polygons and MultiPatches can also be plotted as solid patches;
## then @var{clr} needs to have a second row indicating the fill color.  Octave
## does not support transparent fills yet.  Single-character color codes can be
## combined with linestyle indicators ":", "-", "--", "-.", ".-" and/or marker
## style indicators
## "*", ".", "+", "@@", "v", "^", ">", "<", "d", "h", "o", "p", "s"
## to modify the linestyle for polylines.
##
## Other graphics properties for drawing can be supplied either instead of,
## or after the color argument and will be conveyed as-is to the actual drawing
## routines.  Depending on shapetype, the following proqperties are accepted:
##
## @itemize
## @item All shape types:
## Visible, LineStyle, LineWidth, Marker, MarkerEdgeColor, MarkerFaceColor,
## MarkerSize
##
## @item Point, MultiPoints, Line, Polyline:
## Color
##
## @item Polygon, MultiPatch:
## FaceColor, EdgeColor
## @end itemize
##
## Polygons with holes can be properly plotted provided the holes are separate
## shape feature parts comprising counterclockwise polylines; the first partial
## feature must be the clockwise outer polygon.  The Octave-Forge geometry
## package is required to assess whether multipart polygons have holes and to
## properly draw them.  shapedraw.m will search for the geometry package the
## first time it is instructed to plot filled polygons.  To initiate a new
## search later on (e.g., after the geometry package has been loaded), simply
## invoke shapedraw without any arguments.
##
## Optional output argument @var{h} is the figure handle of the plot.
##
## @seealso{geoshow, mapshow, shapeinfo, shaperead}
## @end deftypefn

## Author: Philip Nienhuis <prnienhuis@users.sf.net>
## Created: 2014-11-15

function [h] = shapedraw (shpf, varargin)

  ## Keep track of OF geometry package presence
  persistent ofgeom = [];

  ## What this function does in what order:
  ## 1. Input checks & analysis.
  ##    Get a struct & assess its type; or read data from .shp file set.
  ## 2. Morph XY[Z} in a suitable form for faster plotting (avoid for loops).
  ##    On the way, explore multipart polygons and if found, get separators.
  ## 3. Process input args; first of all marker/line & fill colors & style.
  ##    A bit involved as there are many interfering options.
  ## 4. Find out if plot is on top of existing figure or must be a new figure.
  ## 5. Depending on geometry type, draw the shape features.
  ##    For Polygons, explore and process "holes".
  ##    FIXME Holes must be implemented for Multipatch as well - pending

  ## 1. Input checks & analyses

  if (nargin < 1)    if (! isempty (ofgeom))
      ## Reset ofgeom
      ofgeom = [];      return;    endif
    print_usage ()
  endif

  if (isempty (shpf))
    ## Nothing to plot
    h = [];
    return;

  elseif (isstruct (shpf))
    ## Yep. Find out what type
    fldn = fieldnames (shpf);
    if (ismember ("vals", fldn) && ismember ("shpbox", fldn))
      ## Assume it is an Octave-style struct read by shaperead
      type = 0;
    elseif (all (ismember ({"Geometry", "X", "Y"}, fldn)))
      ## Assume it is a Matlab-style mapstruct
      type = 1;
    elseif (all (ismember ({"Geometry", "Lat", "Lon"}, fldn)))
      ## Assume it is a Matlab-style geostruct
      type = 2;
    else
      ## Not a supported struct type
      error ("shapedraw: unsupported struct type.\n")
    endif

  elseif (ischar (shpf))
    ## Filename? let's see:
    [pth, fnm, ext] = fileparts (shpf);
    if (isempty (ext) || ! strcmpi (ext, ".shp"))
      ## Just add a .shp suffix
      shpf = [shpf ".shp"];
    endif
    fid = fopen (shpf);
    if (fid < 0)
      error ("File %s not found", shpf);
    else
      fclose (fid);
    endif
    ## Read shapefile in ML style into mapstruct
    shpf = shaperead (shpf, 1);
    type = 1;
  else

    error ("struct name of file name expected");
  endif

  if (isempty (varargin))
    ## Supply default color
    varargin = {[0.6, 0.6, 0.6]};
  endif

  ## 2. Morph XY[Z} data in a suitable form for fastest plotting

  ## Prepare XY plot. Get vertices & prepare some geometry data
  mp = [];
  if (type == 0)
    ## Octave style with intermediate NaN rows. Easy except MultiPatch
    geom = shpf.vals(1, 6);
    X = shpf.vals(:, 1);
    Y = shpf.vals(:, 2);
    Z = shpf.vals(:, 3);
    ## Find multipart shape features to be able to plot polygons with holes
    if (ismember (shpf.vals(1, 6), [5 15 25 31]))
      ## Yep we have polygons
      jdx = [ 0 find(isnan (shpf.vals(:, 1))') ] + 1;
      idx = shpf.idx';
      if (numel (jdx) > numel (idx))
        ## Multipart features present. Find them
        mp = find (diff (find (ismember (jdx, idx))) - 1);
        ## The last feature is a bit special...
        if (jdx(end) > idx(end))
          mp = [ mp numel(idx) ];
        endif
      endif
      npr = shpf.npr;
    endif

  elseif (type == 1 || type == 2)
    ## Matlab struct type
    switch lower (shpf(1).Geometry)
      case "point"
        geom = 1;
      case "multipoint"
        geom = 8;
      case {"polyline", "line"}
        geom = 3;
      case "polygon"
        geom = 5;
      case "multipatch"
        geom = 31;
      otherwise
    endswitch
    tmp = cell (1, 2*numel (shpf));
    if (type == 1)
    ## mapstruct. Needs some preparation: insert a NaN after each subshape
      [tmp(1:2:2*numel(shpf))] = deal ({shpf.X});
      [tmp(2:2:2*numel(shpf)-1)] = NaN;
      X = [tmp{:}];
      [tmp(1:2:2*numel(shpf))] = deal ({shpf.Y});
      [tmp(2:2:2*numel(shpf)-1)] = NaN;
      Y = [tmp{:}];
    else
      ## geostruct. Needs some preparation: insert a NaN after each subshape
      [tmp(1:2:2*numel(shpf))] = deal ({shpf.Lon});
      [tmp(2:2:2*numel(shpf)-1)] = NaN;
      X = [tmp{:}];
      [tmp(1:2:2*numel(shpf))] = deal ({shpf.Lat});
      [tmp(2:2:2*numel(shpf)-1)] = NaN;
      Y = [tmp{:}];
    endif
    ## Infer max. nr. of vertices for patches
    mxverts = max (cellfun ("numel", tmp)) + 1;
    ## For "extended" (not strictly ML-compatible) mapstructs:
    if (isfield (shpf, "Z"))
      ## Give it a try. Could be one Z per shape, rather than one per vertex
      ## if Z values came in from xBase (dbf) rather than .shp
      [tmp(1:2:2*numel(shpf))] = deal ({shpf.Z});
      [tmp(2:2:2*numel(shpf)-1)] = NaN;
      Z = [tmp{:}];
      ## Check nr. of Z values
      if (numel (Z) == numel (X))
        ## Z values apparently originate from .shp
        if (isfield (shpf, "Parts"))
          ## Multipatch. Get Parts (contains multipatch subtypes)
          geom = 31;
          npr = {shpf.Parts};
        else
          ## Bump shape type to Z-type equivalent. Could've been 1/3/5/8 or 23...
          geom = mod (geom, 10) + 10;
        endif
      else
        Z = [];
      endif
    else
      Z = [];
    endif
    ## Find multipart shape features to be able to plot polygons with holes
    if (mod (geom, 10) == 5 || geom == 31)
      ## Polygons
      jdx = [ 0 find(isnan (X)) ] + 1;
      ## A little trick....
      idx = [ 0 (cumsum (cellfun (@(x) numel(x), {shpf(1:end-1).X})) + ...
              cumsum (ones (1, numel (shpf) - 1))) ] + 1;
      if (numel (jdx) > numel (idx))
        ## Multipart features present. Find them
        mp = find (diff (find (ismember (jdx, idx))) - 1);
        ## The last feature is a bit special...
        if (jdx(end) > idx(end))
          mp = [ mp numel(idx) ];
        endif
      endif
    endif
  endif

  ## Check for "verbose" arg
  verbose = find (strncmpi (varargin, "ver", 3));
  varargin (verbose) = [];
  verbose = ! isempty (verbose);

  ## If requested, reduce coordinates (subtract means). May help to get better
  ## plots for large coordinates as OpenGL (w. single accuracy) fouls those up
  center = find (strncmpi (varargin, "cen", 3));
  varargin (center) = [];
  if (! isempty (center))
    X -= mean (X(isfinite (X)));
    Y -= mean (Y(isfinite (Y)));
    if (ismember (geom, [13, 15, 18, 31]))
      Z -= mean (Z(isfinite (Z)));
    endif
  endif

  ## 3. Process input args; mainly marker/line & fill colors

  ## Predefine some properties to be able to check later
  pt_properties = {"Marker", "Color", "LineStyle", "MarkerEdgeColor", ...
                   "MarkerFaceColor", "MarkerSize", "Visible"};
  pl_properties = {"Color", "LineStyle", "LineWidth", "Visible"};
  pg_properties = {"FaceColor", "FaceAlpha", "LineStyle", "LineWidth", ...
                   "EdgeColor", "EdgeAlpha", "Visible"};
  color_codes = { ...
  "b", "k", "c", "g", "m", "y", "w", "r", "blue", "black", "cyan", "green", ...
  "magenta", "yellow", "white", "red", "blue"};
  clrptn = [ '(^[kbcgmprwy](--|\.-|-\.|[:\-osdhv^<>*\.\+@])' '|' ...
             '^([:\-osdhv^<>*\.\+@]|--|\.-|-\.)[bcgkmprwy])' ];

  ## Check color arg
  ## FIXME support for colormaps would be great...
  if (isempty (varargin))
    ## Restore default color
    if (ismember (geom, [5, 15, 25, 31]))
      ## polygons and multipatches
      varargin = {"facecolor" [0.6 0.7 0.9] "edgecolor" [0.5, 0.5, 0.5]};
    else
      varargin = { "color" [0.6, 0.6, 0.6] };
    endif

  elseif (ischar (varargin{1}))
    ## Check if arg#1 is a color code
    if (ismember (varargin{1}(1, :), color_codes) ||
        ! isempty (cell2mat (regexp (varargin{1}(1, :), clrptn, "match"))))
      ## Color OK
      clrtyp = 1;
      if (size (varargin{1}, 1) == 1 && ...
          (size (varargin{1}, 2) == 2 || size (varargin{1}, 2) == 3))
        ## Line- or markerstyle color. Draw polygons as polylines ([3/13/23]
        if (ismember (geom, [5, 15, 25]))
          geom -= 2;
        endif
        varargin = {"color" varargin{1}(1, :) varargin{2:end}};
      elseif (ismember (geom, [5, 15, 25, 31]))
        colr = varargin{1};
        varargin(1) = [];
        varargin = {"edgecolor" colr(1, :) varargin{:}};
        if (size (colr, 1) > 1)
          varargin = {"facecolor" colr(2, :) varargin{:}};
        endif
      else
        varargin = {"color" varargin{1}(1, :) varargin{2:end}};
      endif
    ## Check if it's a graphics property
    elseif (ismember (lower (varargin{1}(1, :)), lower (unique ([pt_properties, ...
                                      pl_properties, pg_properties]))))
      ## Yes. Do some checks
      if (numel (varargin) > 1)
        props = lower ({reshape(varargin, 2, []){1, :}});
      endif
      gr_props_ok = ismember (props, ...
                    unique (lower ([pt_properties pl_properties pg_properties])));
      if (! all (gr_props_ok))
        warning ("shapedraw: unknown graphics properties\n")
      endif
      ## Restore default color if required
      if (ismember (geom, [5, 15, 25, 31]))
        if (! ismember ("facecolor", props))
          ## Introduce polygon edge/face colors
          varargin = { varargin{:} "facecolor" [0.5 0.7 0.9]};
        endif
        if (! ismember ("edgecolor", props))
          ## Introduce polygon edge/face colors
          varargin = { varargin{:} "edgecolor" [0.6, 0.6, 0.6]};
        endif
      elseif (! any (ismember ({"color", "markeredgecolor"}, props)))
        varargin = { "color", [0.6, 0.6, 0.6], varargin{:} };
      endif
    else
      error ("shapedraw: incomprehensible arg#1: %s\n", varargin{1});
    endif

  elseif (isnumeric (varargin{1}))
    ## Assume it's a color RGB triplet, or array of triplets
    if (size (varargin{1}, 2) != 3)
      ## Too few or too many
      error ("shapeplot: incomprehensible argument #2\n");
    else
      if (ismember (geom, [5, 15, 25, 31]))
        if (size (varargin{1}, 1) < 2)
          varargin{1}(2, :) = [0.5 0.7 0.9];
        endif
        varargin = {"edgecolor", varargin{1}(1, :) "facecolor" varargin{1}(2, :)};
      else
        varargin = {"color", varargin{:}};
      endif
    endif
  endif

  ## 4. Find out if plot is on top of existing figure or must be a new figure

  hh = ishold ();
  ## ishold automatically creates an empty figure if none found
  hold ("on");
  h = gcf ();

  ## 5. Depending on geometry type, draw the shape features

  ## For each shape type check drawing options
  if (numel (varargin) > 1)
    try
      varargin = reshape (varargin, 2, []);
    catch
      varargin
      error ("shapedraw: ^^^^ looks like invalid drawing properties were entered");
    end_try_catch
  endif

  switch geom
    case {1, 21, 8, 28}                                     ## (Multi-)Points[M]
      varargin = chk_props (varargin, pt_properties, color_codes, clrptn, "(Multi)Point");
      ## Check for some marker style or marker color code (latter always arg #1)
      if (! ismember ("marker", lower (varargin(1:2:end))) && (ischar (varargin{2}) && ...
          isempty (cell2mat (regexp (varargin{2}(1, :), clrptn, "match")))))
        varargin = { varargin{:}, "marker", "." };
      elseif (ischar (varargin{2}) && ...
              ! isempty (cell2mat (regexp (varargin{2}(1, :), clrptn, "match"))))
        if (strcmpi (varargin{1}, "color"))
          varargin(1) = [];
        endif
      endif
      varargin = { varargin{:}, "linestyle", "none" };
      plot (X, Y, varargin{:});

    case {11, 18}                                           ## (Multi-)PointsZ
      varargin = chk_props (varargin, pt_properties, color_codes, clrptn, "(Multi)PointZ");
      ## Check for some marker style or marker color code (latter always arg #1)
      if (! ismember ("marker", lower (varargin(1, :))) && ...
          ! ismember (varargin(1), color_codes))
        varargin = {"marker", ".", "linestyle", "none" varargin{:} };
      endif
      plot3 (X, Y, Z, varargin{:});

    case {3, 13, 23}                                        ## Polylines
      varargin = chk_props (varargin, pl_properties, color_codes, clrptn, "(Poly)Lines");
      ## Make sure we have an Nx2 matrix
      X = [X(:)];
      Y = [Y(:)];
      if (geom == 13 && ! isempty (Z))
        Z = [Z(:)];
        plot3 (X, Y, Z, varargin{:});
      else
        Z = [];
        plot (X, Y, varargin{:});
      endif

    case {5, 15, 25}                                        ## Polygons
      varargin = chk_props (varargin, pg_properties, color_codes, clrptn, "Polygons");
      ## Make sure we have an Nx2 matrix
      X = [X(:)];
      Y = [Y(:)];
      if (! isempty (Z))
        Z = [Z(:)];
      endif
      idx = [ idx (numel(X)+2) ];
      ## Check for holes in multipart poygon. Outer polygon must be clockwise
      has_holes = 0;
      ## Check if we have the OF geometry pacakage loaded
      if (isempty (ofgeom))
        ofgeom = ! isempty (which ("polygonArea"));
        if (! ofgeom)
          warning ("shapedraw: function 'polygonArea' not found.\n");
          printf  ("           (OF geometry package installed and loaded?)\n");
          printf  ("           => Holes in polygons will be filled\n");
        endif
      endif
      ipt = [ 0; (find (isnan (X))); (numel (X) + 1) ];
      if (ofgeom && ! isempty (mp))
        hdx = cell (mp, 1);
        ## Search multipart polygons for holes, backwards to save mp order
        for ii=numel(mp):-1:1
          ## Depending on struct type, get shape feature
          XT = X(idx(mp(ii)):idx(mp(ii)+1)-2);
          YT = Y(idx(mp(ii)):idx(mp(ii)+1)-2);
          jpt = [ 0; (find (isnan (XT))); (numel (XT) + 1) ];
          ## Check for hole
          h_idx = [];
          for jj=2:numel (jpt) - 1
            ## A clockwise polygon has area < 1, counterclockwise > 1
            hole = (polygonArea (XT(jpt(jj)+1:jpt(jj+1)-1), ...
                                 YT(jpt(jj)+1:jpt(jj+1)-1)) > 1);
            has_holes = has_holes || hole;
            if (hole)
              h_idx = [ h_idx jj ];
            endif
          endfor
          if (isempty (h_idx))
            mp(ii) = [];
          else
            hdx(mp(ii)) = h_idx;
          endif
        endfor
      endif

      ## Draw polygon parts one by one
      if (! ofgeom || isempty (mp))
        ## If no holes can be left open, draw each feature part separately
        idx = [ jdx (numel(X)+2) ];
      endif
      ## Prepare 'faces' argument for patch
      faces = NaN (numel(idx)-1, mxverts);
      for ii=1:numel (idx) - 1
        XT = X(idx(ii):idx(ii+1)-2);
        YT = Y(idx(ii):idx(ii+1)-2);
        if (! isempty (Z))
          ZT = Z(idx(ii):idx(ii+1)-2);
        endif
        if (has_holes && ofgeom && ismember (ii, mp))
          ## To be able to not fill holes in polygons we need a trick. That
          ## comprises connecting the holes to the outline through "branch
          ## cuts" that do not run across other holes or even the outline.
          ## To obtain the latter we need to find optimal locations for the
          ## vertices on both ends of the branch cut.
          [XT, YT, ZT] = optimize_branch_cuts (XT, YT, hdx{ii});
          X(idx(ii):idx(ii+1)-2) = XT;
          Y(idx(ii):idx(ii+1)-2) = YT;
          if (! isempty (Z))
            Z(idx(ii):idx(ii+1)-2) = ZT;
          endif
          faces (ii, 1:numel(XT)) = [1:numel(XT)] + idx(ii) - 1;
        else
          faces (ii, 1:numel(XT)) = [idx(ii):idx(ii+1)-2];
        endif
      endfor
      if (geom == 5)
        p_h = patch ("vertices", [X Y],   "faces", faces, ...
                     "facecolor", "none", "edgecolor", "none");
      else
        p_h = patch ("vertices", [X Y Z], "faces", faces, ...
                     "facecolor", "none", "edgecolor", "none");
      endif
      set (p_h, varargin{:});

    case {31}                                               ## MultiPatch
      ## Multipatch. Process individual subfeatures one by one
      ## First check drawing options
      varargin = chk_props (varargin, pg_properties, color_codes, clrptn, ...
                            "MultiPatch");
      ## Add a NaN row index so below loops will work up to max loop counter
      idx = [ idx numel(X)+2 ];
      if (verbose)
        printf ("\n");
      endif
      ## Make sure we have column vectors
      X = [X(:)];
      Y = [Y(:)];
      Z = [Z(:)];
      ## Init patch 'faces' ptrs. First find out nr. of triangle strips/fans
      prts = [shpf.Parts];
      it = find (prts(2, :) <= 1);
      ## Preallocate 'faces' argument for subfeature patches.
      faces = NaN (size (prts, 2), max (diff (prts(1, :))-1));
      clear prts;                                           ## can be large
      ipf = 0;                                              ## ptr into faces
      for jj=1:numel (npr)
        ## For each feature
        sep = [ (npr{jj}(1, :)) (diff (idx)(jj)) ];
        ibase = idx(jj) - 1;
        lastyp = [];
        for ii=1:size (npr{jj}, 2)
          ## For each subfeature
          if (verbose)
            printf ("Shape part %d, subpart %d\r", jj, ii);
          endif
          switch npr{jj}(2, ii)
            case 0                                            ## Triangle strip
              faces(++ipf, 1:3) = [sep(ii)+1:sep(ii)+3] + ibase;
              ## Each following point forms next triangle with previous two.
              for kk=sep(ii)+4:sep(ii+1)-1
                faces(++ipf, 1:3) = [kk-2:kk] + ibase;
              endfor
              lastyp = 0;
            case 1                                            ## Triangle fan
              faces(++ipf, 1:3) = [sep(ii)+1:sep(ii)+3] + ibase;
              ## Each following point forms next triangle with first and last
              ## points
              for kk=sep(ii)+4:sep(ii+1)-1
                faces(++ipf, 1:3) = [1 kk-1:kk] + ibase;
              endfor
              lastyp = 1;
            case 2                                            ## Outer ring
              ## FIXME Plotting holes hasn't been implemented yet for MultiPatch
              #        (although it seems to work with files found in the wild)
              faces(++ipf, 1:(sep(ii+1)-sep(ii)-1)) = ...
               [sep(ii)+1:sep(ii+1)-1] + ibase;
              lastyp = 2;
            case 3                                            ## Inner ring
              ## FIXME Plotting holes hasn't been implemented yet for MultiPatch
              ##       (although it seems to work with files found in the wild)
              ## FIXME untested code
              faces(++ipf, 1:(sep(ii+1)-sep(ii)-1)) = ...
               [sep(ii)+1:sep(ii+1)-1] + ibase;
              lastyp = 3;
            case 4                                            ## First ring
              ## FIXME untested code
              faces(++ipf, 1:(sep(ii+1)-sep(ii)-1)) = ...
               [sep(ii)+1:sep(ii+1)-1] + ibase;
            case 5                                            ## Ring
              ## FIXME untested code
              faces(++ipf, 1:(sep(ii+1)-sep(ii)-1)) = ...
               [sep(ii)+1:sep(ii+1)-1] + ibase;
              lastyp = 4;
            otherwise
          endswitch
        endfor
        vals = [];
      endfor
      ## Just to be sure, weed out Nan rows out of faces
      faces(isnan (faces(:, 1)), :) = [];
      if (! all (isnan (faces(:))))
        p_h = patch ("vertices", [X Y Z], "faces", faces, ...
                     "facecolor", "none", "edgecolor", "none");
        set (p_h, varargin{:});
      endif
      if (verbose)
        printf ("\n");
      endif

    otherwise
      ## Other shape feature type?
  endswitch

  axis equal;
  box on;

  if (! hh)
    hold ("off");
  endif

endfunction


##-----------------------------------------------------------------------------
## Copyright (C) 2015 Philip Nienhuis
##
## Optimize branch cuts for inner polygons (holes)

function [XX, YY, ZZ, kdx, mdx] = optimize_branch_cuts (XX, YY, varargin);

  ## Check args #3 and #4
  ZZ = [];
  hdx = {};
  if (! isempty (varargin))
    if (nargin == 3)
      ## Assume it's a hdx file indicating which subshapes are holes
      hdx = varargin{1};
    elseif (nargin == 4)
      ## Assume they're Z coordinates
      ZZ = varargin{1};
      hdx = varargin{2};
    endif
  endif

  ## Also keep track of Z. Z isn't (yet) in the branch cut optimization (but
  ## that could be done easily)
  if (isempty (ZZ))
    ## At least provide pointers where Z coordinates have gone in output arrays
    ZZ = [1:numel(XX)]';
  endif
  XY = [ XX YY ZZ];

  ## Find NAN separators
  ipt = [0; find(isnan (XX)); numel(XX)+1];
  if (numel (ipt) < 3)
    ## No NaN separators => no subfeatures. Return
    return
  endif
  for ii=1:numel (ipt) - 1
    XY(ipt(ii)+1:ipt(ii+1)-1, 4) = [ ipt(ii)+1:ipt(ii+1)-1 ]';
  endfor
  if (isempty (hdx))
    ## Assume all except first subfeatures are holes
    hdx = [ 2:numel(ipt)-1 ];
  endif

  ## Silence broadcasting warning
  warning ("off",  "Octave:broadcast", "local");

  ## 1. Locate locate optimal branch cut vertices in outer and inner polygons
  ## FIXME Below we only relate holes to the outer polygon. That bears risk
  ##       for inner holes shielded from the outer boundary by other holes.
  ##       It's better to find the hole closest to the outer boundary, start
  ##       there, and then successively process each hole in turn and find the
  ##       smallest distance to either the outer polygon or already processed
  ##       holes. Such a strategy is neither robust nor easily devised, however.
  for ii=2:numel (ipt) - 1
    b1 = distancePoints (XY(ipt(1)+1:ipt(2)-1, :), XY(ipt(ii)+1:ipt(ii+1)-1, :));
    [~, col(ii-1)] = min (min (b1));
    [~, row] = min (b1(:, col(ii-1)));
    ## Copy vertices of outer polygon down to make room for marker
    XY(row+2:end+2, :) = XY(row:end, :);
    ## Add marker & pointer to inner polygon
    XY(row+1, 1) = Inf;
    XY(row+1, 2:3) = [ii ii];
    ipt(2:end) += 2;
  endfor

  ## 2. ---- Insert inner polygons into outer ----
  ## Update ipt
  ipt = [find(isnan (XY(:, 1))); size(XY, 1)+1];
  jpt = [find(isinf (XY(:, 1))) ; ipt(1)];
  XYXY = XY(1:jpt(1)-1, :);
  for ii=1:numel(jpt) - 1
    ## First rotate inner polygon vertices. Closed polygon => no cirshift
    tmp = XY(ipt(ii)+1:ipt(ii+1)-1, :);
    tmp = [ tmp(col(ii):end-1, :) ; tmp(1:col(ii), :) ];
    XYXY = [ XYXY ; tmp ];
    XYXY = [ XYXY ; XY(jpt(ii)+1:jpt(ii+1)-1, :) ];
  endfor

  XX = XYXY(:, 1);
  YY = XYXY(:, 2);
  if (nargout == 3)
    ZZ = XYXY(:, 3);
  endif

endfunction


##-----------------------------------------------------------------------------
## Copyright (C) 2015 Philip Nienhuis
##
## Check graphics properties for various geometries

function args = chk_props (args, properties, color_codes, clrptn, geometry)

  gr_props = ! ismember (lower (args(1, :)), [lower(properties) color_codes]);
  if (any (gr_props) && isempty (cell2mat (regexp (args(1, :), ...
                                                   clrptn, "match"))))
    printf ("shapedraw: illegal drawing options for %s ignored\n", geometry);
    printf ("(%s)\n", strjoin (args(1, :)(gr_props)));
  else
    gr_props = [];
  endif
  args(:, gr_props) = [];

endfunction
