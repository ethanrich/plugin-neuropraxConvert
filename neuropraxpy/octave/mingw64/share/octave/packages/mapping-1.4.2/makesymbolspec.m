## Copyright (C) 2015-2022 Philip Nienhuis
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
## @deftypefn {Function File} {@var{symspec} =} makesymbolspec (@var{geometry}, @var{rule#1}...@var{rule#n})
## @deftypefnx {Function File} {@var{symspec} =} makesymbolspec (@var{geometry}, @{"Default", @var{property1}, @var{value1}, ...@})
## @deftypefnx {Function File} {@var{symspec} =} makesymbolspec (@var{geometry}, @{@var{attr}, @var{attval}, @var{Property1}, @var{Value1}, ...@})
## Create a symbol specification structure for use with mapshow.
##
## Each symbolspec refers to one geometry type. @var{geometry} can be one of
## "Point", "MultiPoint", "Line", "PolyLine", "Polygon", or "Patch".
## The following argument(s) are rules.  Each rule is a separate cell array.
## The first entry of a rule must be the string "Default" of an attribute/value
## pair.  The attribute @var{attr} should conform to the attributes of the map
## feature to be drawn with the symbolspec; often these are the attributes of
## shapefiles.  The value @var{attval} can be a:
##
## @itemize
## @item
## Numeric value or range of values (row vector).  Map features with
## attribute @var{attr} values equal to, or in the range @var{ATTVAL} (end
## points inclusive) will be drawn with the propety/value pairs in the rest
## of the rule.  These include X and Y coordinates.
##
## @item
## Logical value.  The map features with values for attribute @var{attr}
## equal to @var{attval} will be drawn with the propety/value pairs in the
## rest of the rule.
##
## @item 
## Character string.  Those map features with @var{attr} text strings
## corresponding to @var{attval} will be drawn with the propety/value pairs
## in the rest of the rule.
## @end itemize
##
## In case of oct-type structs (see shaperead.m) additional attributes are
## available:
##
## @table @code
## @item X
## @itemx Y
## @itemx Z
## @itemx M
## X, Y, Z or M-values of vertices of polylines / polygons / multipatches are
## used to indicate the matching shape features are to be drawn. A matching
## value of just one sigle vertex of poit in the specified range suffices to
## match a shape feature.
##
## @item npt
## npt encodes for the number of vertices for each multipoint, polygon,
## polyline or multipatch shape feature in the original shapefile.
##
## @item npr
## npr encodes for the number of parts of each shape feature.
## @end table
##
## The property/value pairs for each rule should conform to the geometry type.
## That is, for (Multi)Point features only marker properties may be specified,
## similarly for Lines/Polylines (line properties) and Polygons/Patches (patch
## and fill properties).
##
## The case of input geometries and properties does not matter; makesymbolspec
## will turn them into the "official" casing.
##
## @example
##   symsp1 = makesymbolspec ("Line", @{"TAG1", "road", ...
##                                      "color", "b"@})
##   (draw polylines tagged "road" as blue lines)
## @end example
##
## @example
##   symsp2 = makesymbolspec ...
##            ("Line", @{"TAG1", "road", "color", "b", ...
##                      "linestyle", "-", "linewidth", 3@} ...
##                     @{"TAG1", "rail", "color", ...
##                       [0.7 0.5 0.2], ...
##                      "linestyle", "--", "linewidth", 2@})
##   (like above, but with polylines tagged "rail" as dashed
##    light brown lines)
## @end example
##
## @example
##   symsp3 = makesymbolspec 
##            ("Polygon", @{"M", [ 0    10], "Facecolor", "c"@}, ...
##                        @{"M", [10.01 20], "Facecolor", "b"@}, ...
##                        @{"M", [20.01 30], "Facecolor", "m"@})
##   (Note: only possible with oct-style shapestructs; create a
##    symbolspec using M-values in three classes)
## @end example
##
## @seealso{mapshow, geoshow}
## @end deftypefn

## Author: Philip Nienhuis <prnienhuis@users.sf.net>
## Created: 2015-01-05
## Updates:
## 2015-01-10 Input checks; allow multiple properties per rule; add tests
## 2015-01-13 More error checks
## 2015-02-11 Improve graphics properties checks

function [symspec] = makesymbolspec (geom, varargin)

  ## Input validation
  if (nargin < 2 || ! ischar (geom) || ! iscell (varargin))
    print_usage;
  endif

  ## ML-compatible properties
  geometries    = { "Point", "MultiPoint", "Line", "Polyline", "Polygon", ...
                    "Patch"};
  pt_properties = {"Marker", "Color", "LineStyle", "MarkerEdgeColor", ...
                   "MarkerFaceColor", "MarkerSize", "Visible"};
  pl_properties = {"Color", "LineStyle", "LineWidth", "Visible"};
  pg_properties = {"FaceColor", "FaceAlpha", "LineStyle", "LineWidth", ...
                   "EdgeColor", "EdgeAlpha", "Visible"};

  ## Create cell structure
  idx = ismember (lower (geometries), lower (geom));
  if (any (idx))
    symspec = geometries (find (idx));
  else
    error ("makesymbolspec: unknown Geometry:  %s\n", geom);
  endif

  ## Check varargin
  for ii=1:numel (varargin)
    ## Select properties set for Geometry at hand
    switch lower (geom)
      case {"point", "multipoint"}
        templ_props = pt_properties;

      case {"line", "polyline"}
        templ_props = pl_properties;

      case {"polygon", "patch"}
        templ_props = pg_properties;

      otherwise
    endswitch

    ## Get attribute
    att = varargin{ii}{1};
    if (! ischar (att))
      error ("makesymbolspec: attribute name expected for rule $%d\n", ii);
    elseif (strcmpi (att, "default"))
      rule = {"Default", 0};
      props = varargin{ii}(2:end);
    else
      rule = {att, varargin{ii}{2}};
      props = varargin{ii}(3:end);
    endif
    ## Check properties
    try
      props = reshape (props, 2, []);
      ## Eliminate unrecognized property/value pairs
      illp = find (! ismember (lower (props(1,:)), lower (templ_props)));
      if (any (illp))
        warning ("makesymbolspec: properties '%s' for geometry '%s' ignored\n", ...
                 strjoin (props(1, illp), "' | '"), geom);
        props(:, illp) = [];
      endif
      ## Replace properties by official case, just to be sure
      props (1, :) = templ_props (find (ismember (lower (templ_props), ...
                                                    lower (props(1,:)))));
      ## Reshape varargin back. We trust the user-supplied values to be OK
      rule = {rule{:} props{:}};
      symspec(end+1) = {rule};
    catch
      if (rem (size (varargin{ii}(3:end), 1), 2) != 0)
        error ("makesymbolspec: a property or value missing in rule #%d\n", ii);
      else
        error ("makesymbolspec: uncomprehensible input in rule #%d\n", ii);
      endif
    end_try_catch
  endfor
    

endfunction

%!test
%% Illegal graphics properties & case of properties
%!warning<properties> ssp = makesymbolspec ("Line", {"LENGTH", [100 150], "color", "b", ...
%!      "nonsense", "?", "lineWidth", 3, "markersize", "BS", "Visible", 1});
%! ssp = makesymbolspec ("Line", {"LENGTH", [100 150], "color", "b", ...
%!      "lineWidth", 3, "Visible", 1});
%! assert (reshape (ssp{2}(3:end), 2, [])(1, :), {"Color", "LineWidth", ...
%!                                                "Visible"});
%! assert (ssp{1}, "Line");


