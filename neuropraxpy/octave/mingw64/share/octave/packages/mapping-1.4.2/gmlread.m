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
## along with this program.  If not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*- 
## @deftypefn {} {@var{gml} =} gmlread (@var{fname}, @var{dots})
## Read a .gml (Geographic Markup Language) file.
##
## gmlread only reads coordinates, no attributes.
##
## Required input argument @var{fname} is the name of a .gml file.  If
## no other arguments are specified all features in the entire .gml file
## will be read.
##
## The following optional property/value pairs (all case-insensitive)
## can be specified to select only some feature types and/or features
## limited to a certain area:
##
## @itemize
## @item "FeatureType"
## (Just one "f" will do)  Only read a certain feature type; the value
## can be one of "Points", "LineStrings" or "Polygons" (only the first
## three characters matter).  Multiple feature types can be selected by
## specifying multiple FeatureType property/value pairs.
## @end item
##
## @item BoundingBox
## (just one "b" suffices)  Only read features that lie entirely within
## a coordinate rectangle specified as a 2x2 matrix containing [minX minY;
## maxX maxY].
## @end item
## @end itemize
##
## In addition verbose output can be obtained by specifying the following
## property/value pair:
##
## @itemize
## @item Debug
## (a "d" will do)  followed by a numeric value of 1 (or true) specifies
## verbose output; a numeric value of 0 (or false) suppresses verbose output.
## @end item
## @end itemize
##
## The output of gmlread comprises a struct containing up to three
## mapstructs (MultiPoint and/or Polyline and/or Polygon mapstructs),
## depending on optional featuretype selection.
##
## @seealso{shaperead}
## @end deftypefn

## Author: Philip Nienhuis <prnienhuis@users.sf.net>
## Created: 2017-03-06

function [gml] = gmlread (fname, varargin)

  ## FIXME Input validation
  fid = fopen (fname, "r");
  if (fid < 0)
    error ("gmlread: file %s not found.\n", fname);
  endif

  ## Process [property, value] options
  idx = pol = [];
  dbug = feat = ipt = iln = ipg = 0;
  for ii=1:2:numel (varargin)
    if (ischar (varargin{ii}) && numel (varargin{ii}) > 0 && mod (numel (varargin), 2) == 0)
      switch lower (varargin{ii})(1)
        case "f"
          ## Feature type. Keep track of whether this option was entered
          feat = 1;
          if (ischar (varargin{ii+1}))
            switch lower (varargin{ii+1})(1:3)
              case "poi"
                ipt = 1;
              case "lin"
                iln = 1;
              case "pol"
                ipg = 1;
              otherwise
                error ("gmlread: unknown FeatureType '%s'", varargin{ii+1});
            endswitch
          else
            error ("gmlread: illegal value for argument %d\n", ii+1);
          endif
        case "b"
          ## Bounding box
          bbox = varargin{ii+1};
          if (! isnumeric (idx) && size (bbox, 1) != 2 && size (bbox, 2) != 2)
            error ("gmlread: numeric 2x2 matrix expected for arg.# %d\n", ii+1);
          else
            pol = [bbox(1, 1), bbox(2, 1), bbox(2, 1), bbox(1, 1), bbox(1, 1); ...
                   bbox(1, 2), bbox(1, 2), bbox(2, 2), bbox(2, 2), bbox(1, 2)];
          endif
        case ("d")
          ## Debug
          dbug = varargin{ii+1} == 1;
        otherwise
          warning ("gmlread: unknown option '%s' - ignored\n", varargin{ii});
      endswitch
    else
      error ("gmlread: wrong [property, value] options list");
    endif
  endfor
  if (! feat)
    ipt = iln = ipg = 1;
  endif

  if (dbug)
    printf ("Reading %s ... ", fname);
  endif
  xml = fread (fid, 1000, "char=>char")';

  ## Skip header lines/-nodes
  hdls = cell2mat (regexp (xml, '(<\?.*?\?>)|(<!.*?>)', "tokenExtents"));
  spos = hdls(end);
  ## Start with outer content node
  fseek (fid, spos+1, "bof");
  xml = fread (fid, Inf, "char=>char")';
  fclose (fid);

  ## Parse xml int 5xN cell array
  ptrn = '<gml:((Point|LineString|Polygon)) .*?<gml:(coordinates|posList|pos).*?srsDimension="(\d)".*?>([\d\. ]*?)</gml:(coordinates|posList|pos)>';
  feats = reshape (cell2mat (regexp (xml, ptrn, "tokens")), 5, []);

  if (ipt)
    if (dbug)
      printf ("\nSearching Points ... ");
    endif
    ipt = find (strcmp (feats(1, :), "Point"));
    if (dbug)
      printf ("%d found.\n", numel (ipt));
    endif
  else
    ipt = [];
  endif

  if (iln)
    if (dbug)
      printf ("Searching LineStrings ... ");
    endif
    iln = find (strcmp (feats(1, :), "LineString"));
    if (dbug)
      printf ("%d found.\n", numel (iln));
    endif
  else
    iln = [];
  endif

  if (ipg)
    if (dbug)
      printf ("Searching Polygons ... ");
    endif
    ipg = find (strcmp (feats(1, :), "Polygon"));
    if (dbug)
      printf ("%d found.\n", numel (ipg));
    endif
  else
    ipg = [];
  endif

  if (dbug)
    printf ("Converting ....\n", numel (ipg));
  endif

  ## Points
  if (! isempty (ipt))
    gmlpt = repmat (struct ("Geometry", "Multipoint", "X", NaN (1, 10), "Y",
                            NaN (1, 10), "BoundingBox", NaN (2, 2)), numel (ipt), 1);
    jpt = 0;
    for ii=1:numel (ipt)
      if (dbug)
        printf ("%d of %d Points ....\r", ii, numel (ipt));
      endif
      [xy, cnt] = sscanf (feats{4, ipt(ii)}, "%f");
      dimsn = str2double (feats{3, ipt(ii)});
      xy = reshape (xy, dimsn, []);
      if (isempty (pol) || bbox <= 0 || all (inpolygon (xy(1, :), xy(2, :), pol(1, :), pol(2, :))))
        ++jpt;
        gmlpt(jpt).X = xy(1, :);
        gmlpt(jpt).Y = xy(2, :);
        gmlpt(jpt).BoundingBox = [min(xy(1, :)), min(xy(2, :)); max(xy(1, :)), max(xy(2, :))];
        if (dimsn >= 3)
          gmlpt(jpt).Z = xy(3, :);
          gmlpt(jpt).BoundingBox = [gmlpt(jpt).BoundingBox, [min(xy(3, :)); max(xy(3, :))]];
        endif
      endif
    endfor
    if (dbug)
      printf ("\n");
    endif
    gml.Points = gmlpt(1:jpt);
  endif

  ## LineStrings
  if (! isempty (iln))
    jpt = 0;
    gmlpl = repmat (struct ("Geometry", "Polyline", "X", NaN (1, 15), "Y",
                            NaN (1, 15), "BoundingBox", NaN (2, 2)), numel (iln), 1);
    for ii=1:numel (iln)
      if (dbug)
        printf ("%d of %d LineStrings ....\r", ii, numel (iln));
      endif
      [xy, cnt] = sscanf (feats{4, iln(ii)}, "%f");
      dimsn = str2double (feats{3, iln(ii)});
      xy = reshape (xy, dimsn, []);
      if (isempty (pol) || all (inpolygon (xy(1, :), xy(2, :), pol(1, :), pol(2, :))))
        ++jpt;
        gmlpl(jpt).X = xy(1, :);
        gmlpl(jpt).Y = xy(2, :);
        gmlpl(jpt).BoundingBox = [min(xy(1, :)), min(xy(2, :)); max(xy(1, :)), max(xy(2, :))];
        if (dimsn >= 3)
          gmlpl(jpt).Z = xy(3, :);
          gmlpl(jpt).BoundingBox = [gmlpl(jpt).BoundingBox, [min(xy(3, :)); max(xy(3, :))]];
        endif
      endif
    endfor
    if (dbug)
      printf ("\n");
    endif
    gml.Polylines = gmlpl(1:jpt);
  endif

  ## Polygons
  if (! isempty (ipg))
    jpt = 0;
    gmlpg = repmat (struct ("Geometry", "Polygon", "X", NaN (1, 20), "Y",
                            NaN (1, 20), "BoundingBox", NaN (2, 2)), numel (ipg), 1);
    for ii=1:numel (ipg)
      if (dbug)
        printf ("%d of %d Polygons ....\r", ii, numel (ipg));
      endif
      [xy, cnt] = sscanf (feats{4, ipg(ii)}, "%f");
      dimsn = str2double (feats{3, ipg(ii)});
      xy = reshape (xy, dimsn, []);
      if (isempty (pol) || all (inpolygon (xy(1, :), xy(2, :), pol(1, :), pol(2, :))))
        ++jpt;
        gmlpg(jpt).X = xy(1, :);
        gmlpg(jpt).Y = xy(2, :);
        gmlpg(jpt).BoundingBox = [min(xy(1, :)), min(xy(2, :)); max(xy(1, :)), max(xy(2, :))];
        if (dimsn >= 3)
          gmlpg(jpt).Z = xy(3, :);
          gmlpg(jpt).BoundingBox = [gmlpg(jpt).BoundingBox, [min(xy(3, :)); max(xy(3, :))]];
        endif
      endif
    endfor
    if (dbug)
      printf ("\n");
    endif
    gml.Polygons = gmlpg(1:jpt);
  endif

endfunction
