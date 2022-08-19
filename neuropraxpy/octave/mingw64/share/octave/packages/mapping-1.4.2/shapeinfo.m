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
## @deftypefn {Function File} [ @var{infs} ] = shapeinfo (@var{fname})
## Returns a struct with info on shapefile @var{fname}.
##
## Input:
## @table @code
## @item @var{fname}
## (character string). Does not need to have a .shp suffix.
## @end table
##
## Output: a struct with fields:
##
## @table @code
## @item Filename
## Contains the filename of the shapefile.
##
## @item ShapeType
## The type of shapefile.
##
## @item ShapeTypeName
## The name of the shape type.
##
## @item BoundingBox
## The minimum and maximum X and Y coordinates of all items in the shapefile in
## a 2 X 2 array, upper rox min and min Y, lower row max X and max Y.
##
## @item NumFeatures
## The number of features (items, records) in the shapefile.
##
## @item Attributes
## A structure with fields Name and Type (containng the names and types of all
## attributes in the shapefile). Type can be Numeric, Character or Data.
## @end table
##
## @seealso{geoshow, mapshow, shapedraw, shaperead, shapewrite}
## @end deftypefn

## Author: Philip Nienhuis <prnienhuis@users.sf.net
## Created: 2014-11-15
## Updates:
## 2015-01-18 Use .shx file (if present) to get nr. of records
## 2016-01-05 Add shape type name to output struct

function [infs] = shapeinfo (fname)

  persistent shptypnames = { ...
     1, "Point"; ...
    11, "PointZ"; ...
    21, "PointM"; ...
     8, "MultiPoint"; ...
    18, "MultiPointZ"; ...
    28, "MultiPointM"; ...
     3, "PolyLine"; ...
    13, "PolyLineZ"; ...
    23, "PolyLineM"; ...
     5, "PolyGon"; ...
    15, "PolyGonZ"; ...
    25, "PolyGonM"; ...
    31, "MultiPatch"};

  ## ====================== 1. Read .shp file proper ======================

  ## Check file name
  [pth, fnm, ext] = fileparts (fname);
  if (isempty (ext))
    bname = fname;
    fname = [fname ".shp"];
  else
    ## Later on bname.shx and bname.dbf will be read
    bname = [pth filesep fnm];
  endif
  ## Put filename in info struct
  infs.Filename = fname;

  ## Start reading header
  fidp = fopen (fname, "r");
  if (fidp < 0)
    error ("shapeinfo: can't open file %s\n", fname);
  endif
  fseek (fidp, 0, "bof");

  ## Read & check file code
  fcode = fread (fidp, 1, "int32", 20, "ieee-be");
  if (fcode != 9994)
    error ("%s is not a valid shapefile\n", fname);
  endif
  flngt = fread (fidp, 1, "int32", 0, "ieee-be") * 2;
  fvsn  = fread (fidp, 1, "int32", 0, "ieee-le");
  shpt  = fread (fidp, 1, "int32");                         ## Shape file type
  ## Put shapetype in info struct
  infs.ShapeType = shpt;
  infs.ShapeTypeName = ...
    shptypnames {find (ismember ([shptypnames(:, 1){:}], shpt)), 2};

  shpbox.X(1) = fread (fidp, 1, "double");
  shpbox.Y(1) = fread (fidp, 1, "double");
  shpbox.X(2) = fread (fidp, 1, "double");
  shpbox.Y(2) = fread (fidp, 1, "double");
  shpbox.Z(1) = fread (fidp, 1, "double");
  shpbox.Z(2) = fread (fidp, 1, "double");
  shpbox.M(1) = fread (fidp, 1, "double");
  shpbox.M(2) = fread (fidp, 1, "double");
  ## Put in info struct
  infs.BoundingBox = [shpbox.X(1), shpbox.Y(1); shpbox.X(2), shpbox.Y(2)];

  ## Count records

  fidx = fopen ([bname ".shx"], "r");
  if (fidx < 0)
    ## Only way to get nr. of records is to count (or use .dbf file)
    printf ("shapeinfo: index file %s not found.\nCounting records...\n", ...
             [bname ".shx"]);
    reclr = 0;
    do
      ## Read record index number
      recn = fread (fidp, 1, "int32", 0, "ieee-be");
      ## Record length
      rlen = (fread (fidp, 1, "int32", 0, "ieee-be") * 2);
      ## Skip rest of record
      fread (fidp, rlen, "char=>char");

    until (ftell (fidp) > flngt - 3);                       ## i.e., within last
                                                            ## file byte
    printf ("                   \n");                       ## Wipe "Counting.."
  else
    ## shx file found; no counting required
    fseek (fidx, 24, "bof");
    fxlng = fread (fidx, 1, "int32", 72, "ieee-be");
    recn = (fxlng - 50) / 4;
    fclose (fidx);
  endif

  fclose (fidp);
  finfo =  dir (fname);

  ## Return info
  infs.NumFeatures = recn;
  infs.FileSize = finfo.bytes;
  infs.LastModified = datestr (finfo.datenum, 0);

  ## ====================== 3. .dbf ======================

  ## Check if dbfread is available
  if (isempty (which ("dbfread")))
    printf ("shaperead: dbfread function not found. No attributes will be added.\n");
    printf ("             (io package installed and loaded?)\n");

  else
    ## Try to read the .dbf file
    try
      [~, B] = dbfread ([bname ".dbf"], 0);
      infs.Attributes.Name = {B.data.fldnam};
      types = {B.data.fldtyp};
      types = strrep (types, "N", "Numeric");
      types = strrep (types, "C", "Character");
      types = strrep (types, "D", "Date");
      types = strrep (types, "F", "Floating");
      ## FIXME dbase also has type "Logical"
      infs.Attributes.Type = types;
    catch
      printf ("shaperead: file %s couldn't be opened;\n", [ bname ".dbf" ]);
      printf ("           no attributes appended\n");
    end_try_catch
  endif


endfunction
