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
## @deftypefn {Function File} {[@var{bands}, @var{info}] =} rasterread (@var{fname})
## Read a GIS raster file
##
## @var{fname} can be about any type of GIS raster file recognized by the
## GDAL library.  For .adf files, either the name of the subdirectory
## containing the various component files, or the name of one of those
## component files can be specified.
##
## Output argument @var{bands} is a struct, or if multiple bands were read,
## a struct array, with data of each band: data, min, max, bbox, and
## (if present for the band) a GDAL colortable (see GDAL on-line
## reference).
##
## Output argument @var{binfo} contains various info of the raster file:
## overall bounding box, geotransformation, projection, size, nr. of columns
## and rows, datatype, nr. of bands.
##
## rasterread.m needs the GDAL library.
##
## @seealso{gdalread, gdalwrite}
## @end deftypefn

## Author: Philip Nienhuis <prnienhuis@users.sf.net>
## Created: 2015-10-15

function [bands, binfo] = rasterread (fname="")

  ## Checks
  if (! ischar (fname))
    print_usage ();
  elseif (isempty (fname))
    print_usage ();
  elseif (exist (fname) != 2)
    error ("rasterread: file '%s' not found\n", fname);
  endif

  bands = info = {};

  ## Try to read data
  [status, binfo, bands] = gdalread (fname);
  if (! status)
    binfo.bbox = [Inf Inf; -Inf -Inf];
    for ii=1:numel (bands)
      ## gdalread() rotates bands 90 degrees probably due to fortran_vec
      bands(ii).data = rot90 (bands(ii).data, 1);
      binfo.bbox(1, 1:2) = min (binfo.bbox(1, 1:2), bands(ii).bbox(1, 1:2));
      binfo.bbox(2, 1:2) = max (binfo.bbox(2, 1:2), bands(ii).bbox(2, 1:2));
      if (bands(ii).has_ndv)
        bands(ii).ndv = bands(ii).ndv_val;
      else
        bands(ii).ndv = [];
      endif
      if (! isempty (bands(ii).colortable) && 
          all (abs (bands(ii).colortable(:, 4)) > 1e-10))
        bands(ii).colortable(:, 1:3) = bands(ii).colortable(:, 1:3) ./ ...
                                       bands(ii).colortable(:, 4);
      endif
    endfor
    ## Remove fieldnames that are no longer needed
    dflds = setdiff (fieldnames (bands), {"data", "bbox", "min", "max", ...
                                          "ndv", "colortable"});
    bands = rmfield (bands, dflds);
    ## Add file info to binfo
    binfo.Filename = canonicalize_file_name (fname);
    binfo.FileSize = stat (fname).size;
    binfo.FileModDate = strftime ("%d-%b-%y %H:%M:%S", localtime (stat (fname).mtime));
  endif

endfunction
