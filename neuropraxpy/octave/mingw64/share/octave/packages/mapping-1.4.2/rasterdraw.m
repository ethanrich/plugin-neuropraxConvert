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
## @deftypefn {} {@var{h} =} rasterdraw (@var{data})
## @deftypefnx {} {@var{h} =} rasterdraw (@var{data}, @var{rinfo})
## @deftypefnx {} {@var{h} =} rasterdraw (@dots{}, @var{property}, @var{value}, @dots{})
## Draw a GIS raster map.
##
## @var{data} can be a file name of a GIS raster data file, or a raster
## data struct made by rasterread; in the latter case input arg
## @var{rinfo}, a raster info struct also made by rasterread, is also
## required.
##
## Optionally, property/value pairs can be specified.  Only the first
## four characters of the property need to be entered.  The following
## property/value pairs are recognized:
##
## @itemize
## @item `bands':
## The value should be a scalar value or vector indicating which band(s)
## will be drawn in case of multi-band raster data.  The default is all
## bands if the data contains three bands of integer data type, or the
## first band in all other cases.  For non-integer raster data only one
## raster band can be specified.  The number of bands must be 1 or 3.
## 
## @item `colormap':
## The value should be a valid colormap to be used for indexed raster
## data.
##
## @item `missingvalue':
## A numerical value to substitute for missing values in the raster
## data.  Default is NaN (for floating point raster data).
## @end itemize
##
## The optional output argument @var{h} is a graphics handle to the map.
##
## If the raster data to be plotted comprises just one band and a GDAL
## colortable, that colortable is converted to a colormap and used for
## drawing the map.  The actual raster data are converted to uint8 if
## no missing data are present. 
##
## Behind the scenes imshow() is invoked for the actual drawing for
## integer or single-band data, or pcolor() for floating point data with
## missing values.
##
## Note that drawing raster data can be quite slow for big data sets.
## Drawing maps larger than ~4000x4000 pixels is therefore not advised.
##
## @seealso{mapshow, rasterread, rasterinfo}
## @end deftypefn

## Author: Philip Nienhuis <prnienhuis@users.sf.net>
## Created: 2015-12-29

function [hr] = rasterdraw (varargin)

  if (nargin < 1)
    print_usage ();
  endif

  hr = -1;
  clrmap = [];
  misval = NaN;

  if (ischar (varargin{1}))
    ## Assume a raster file name. Just convey to rasterread.m
    fname = varargin{1};
    [bands, rinfo] = rasterread (fname);
    nargin = nargin - 1;
    varargin(1) = [];
  elseif (isstruct (varargin{1}))
    ## Assume a raster struct made by rasterread.m. Checks:
    if (! isfield ("varargin(1)", "data") && ! ismatrix (varargin{1}(1).data))
      error ("rasterdraw: unknown info raster struct setup");
    else
      bands = varargin{1};
    endif
    ## Check arg #2 - expecting info struct
    if (nargin < 2 || ! (isstruct (varargin{2}) && 
        all (ismember ({"bbox", "projection", "height", "width", ...
                        "geotransformation", "nbands"}, ...
                        lower (fieldnames (varargin{2}))))))
      error ("rasterdraw: invalid or missing info struct (arg #2)");
    else
      rinfo = varargin{2};
      varargin(1:2) = [];
      nargin = nargin - 2;
    endif
  else
    ## Unknown "first" argument
    error ("rasterdraw: expecting filename or raster struct");
  endif
  ibands = [1 : numel(bands)];

  ## Optional propert/value arguments
  for ii=1:2:nargin
    if (nargin < ii+1)
      error ("rasterdraw: missing value for property %s", varargin{ii});
    endif
    switch (lower (varargin{ii}(1:4)))
      case "band"
        ## Select raster band(s) to draw
        ibands = varargin{ii+1};
        if (! isnumeric (ibands))
          error ("rasterdraw: expecting numeric value(s) for 'bands' value");
        elseif (any (ibands > numel (bands)))
          warning (["rasterdraw: data contains %d band(s), requested ", ...
                    "band(s) [%s ] ignored.\n"], numel (bands), ...
                    sprintf (" %d", ibands(find (ibands > numel (bands)))));
          ibands (find (ibands > numel (bands))) = [];
        endif
        if (! (numel (ibands) == 1 || numel (ibands) == 3))
          error ("rasterdraw: either one or three bands must be selected.\n");
        elseif (rinfo.BitDepth >= 32)
          ## Assume floating point data
          warning (["rasterdraw: floating point raster data. only band ", ...
                    "%d will be drawn\n"], ibands(1));
        endif
      case "colo"
        clrmap = varargin{ii+1};
        if (! iscolormap (clrmap))
          error ("rasterdraw: invalid colormap specified");
        endif
      case "miss"
        misval = varargin{ii+1};
        if (! isnumeric (misval))
          error ("rasterdraw: numerical value expected for missing value");
        endif
      otherwise
        warning ("rasterdraw: unknown or unimplemented property '%s' - skipped\n", ...
                  varargin{ii});
    endswitch
  endfor

  ## For each band process raster data, First band can be special
  ## FIXME Implement e.g., white ([1 1 1]) as default missing value for RGB
  ##       multi-band images
  empdat = 0;
  ## 1. Treat & signal missing values (only for one-band maps)
  if (! isempty (bands(ibands(1)).ndv))
    ndv = bands(ibands(1)).ndv;
    if (any (any (bands(1).data == bands(ibands(1)).ndv)))
      empdat = 1;
      bands(ibands(1)).data(find (bands(ibands(1)).data == ndv)) = misval;
    endif
  endif
  ## 2. If no missing data found & integer raster data type, cast to uint8
  if (! empdat || rinfo.BitDepth <= 8)
    pic = uint8 (bands(ibands(1)).data);
    ## Band data no more used, clear - raster data can occupy awfully much RAM
    bands(ibands(1)).data = [];
    if (! isempty (bands(ibands(1)).colortable))
      clrmap = bands(ibands(1)).colortable(:, 1:3);
    endif
  else
    pic = bands(ibands(1)).data;
  endif

  ## If no missing pixels, process next bands if present & requested
  if (numel (ibands) > 1 && ! empdat)
    ## Concat bands into picture
    pic(:, :, 1) = pic;
    for ii=2:numel (ibands)
      pic(:, :, ii) = uint8(bands(ibands(ii)).data);
      bands(ibands(1)).data = [];
    endfor
  endif
  ## Clear bands struct (also clears RAM for bands not requested)
  clear bands;

  ## Draw rasters using bbox values for axes limits
  if (empdat)
    bbox = rinfo.bbox;
    XX = [bbox(1, 1) : (diff (bbox(:, 1)) / (rinfo.Width)): bbox(2, 1)];
    YY = [bbox(1, 2) : (diff (bbox(:, 2)) / (rinfo.Height)): bbox(2, 2)];
    [nr, nc] = size (pic);
    hr = pcolor (XX, YY, [pic nan(nr, 1); nan(1, nc+1)]);
    ## Hide mesh:
    shading flat;
  else
    if (isempty (clrmap) || ! iscolormap (clrmap))
      hr = imshow (pic, "xdata", rinfo.bbox(:, 1), "ydata", rinfo.bbox(:, 2));
    else
      hr = imshow (pic, "xdata", rinfo.bbox(:, 1), "ydata", rinfo.bbox(:, 2), ...
                   "colormap", clrmap);
    endif
  endif
  set (gca, "YDir", "normal");
  axis equal;
  axis tight;

endfunction
