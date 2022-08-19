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
## @deftypefn {} [@var{rbo}, @var{rio}] = rasterclip (@var{rbi}, @var{rii}, @var{clpbox})
## Clip a georaster with a rectangle and return adapted bands and info structs.
##
## rasterclip is useful for extracting a part of a raster map to enable e.g.,
## faster drawing 
## @var{rbi} and @var{rii} are output structs from rasterread.m  @var{clpbox}
## is a 2x2 matrix containing [Xmin, Ymin; Xmax, Ymax] of the rectangle.
##
## Output structs @var{rbo} and @var{rio} contain adapted bbox, data, Width,
## Height and GeoTransformation fields.  All other fields are copied verbatim,
## except fields FileSize, FileName and FileModDate which are all left empty.
##
## @seealso{rasterread,rasterdraw}
## @end deftypefn

## Author: Philip Nienhuis <prnienhuis@users.sf.net>
## Created: 2017-11-01

function [rbo, rio] = rasterclip (rbi, rii, clpbox)

  ## FIXME maybe stricter and more extensive input validation
  if (nargin < 3 || ! isstruct (rbi) || ! isstruct (rii) || ! ismatrix (clpbox))
    usage ();
  endif

  ## Check required fieldnames and remove required (processed) ones from lists
  fldsr = fieldnames (rbi(1));
  reqr = {"bbox", "data"};
  if (! all (ismember (reqr, fldsr)))
    error ("rasterclip: arg#1: missing fields, improper band struct");
  endif
  fldsr (ismember (fldsr, reqr)) = [];
  
  fldsi = fieldnames (rii);
  reqi = {"GeoTransformation", "Width", "Height", "nbands", "BitDepth"};
  if (! all (ismember (reqi, fldsi)))
    error ("rasterclip: arg#2: missing fields, improper band struct");
  endif
  fldsi(ismember (fldsi, reqi)) = [];

%  ## Check clip rectangle
%  if (! (issquare (clpbox) && numel (clpbox) != 4) || ...
%      clpbox(1, 1) >= clpbox(2, 1) || clpbox(2, 1) >= clpbox(2, 2))
%    error: ("rasterclip: 2x2 array [Xmin Ymin; Xmax Ymax] expected");
%  endif

  rbox = rii.bbox;
  clpbox(1, 1) = max (clpbox(1, 1), rbox(1, 1));
  clpbox(2, 1) = min (clpbox(2, 1), rbox(2, 1));
  clpbox(1, 2) = max (clpbox(1, 2), rbox(1, 2));
  clpbox(2, 2) = min (clpbox(2, 2), rbox(2, 2));
  if (any (! isfinite (clpbox)))
    error ("One or more of clpbox coordinates outside raster");
  endif

  ## Check if clpbox endpoints lie within raster
  rbox = [rbox(1, 1) rbox(1, 2); ...
          rbox(2, 1) rbox(1, 2); ...
          rbox(2, 1) rbox(2, 2); ...
          rbox(1, 1) rbox(2, 2); ...
          rbox(1, 1) rbox(1, 2)];
  [inp, onp] = inpolygon (clpbox(:, 1), clpbox(:, 2), rbox(:, 1), rbox(:, 2));

  ## Clip clpbox endpoints to pixel borders
  xpx = [rbox(1, 1) : ((rbox(2, 1) - rbox(1, 1)) / rii.Width)  : rbox(2, 1)];
  ypx = [rbox(1, 2) : ((rbox(3, 2) - rbox(1, 2)) / rii.Height) : rbox(3, 2)];
  irl = find (clpbox(1, 1) <= xpx)(1);
  irr = find (clpbox(2, 1) >= xpx)(end);
  irb = find (clpbox(1, 2) <= ypx)(1);
  irt = find (clpbox(2, 2) >= ypx)(end);
  
  ## Copy band struct fields over
  for jj=1:rii.nbands
    for ii=1:numel (fldsr)
      rbo(jj).(fldsr{ii}) = rbi(jj).(fldsr{ii});
    endfor
    ## Adapt required fields
    rbo(jj).bbox(1, 1) = xpx(irl);
    rbo(jj).bbox(2, 1) = xpx(irr);
    rbo(jj).bbox(1, 2) = ypx(irb);
    rbo(jj).bbox(2, 2) = ypx(irt);
    rbo(jj).data = rbi(jj).data(irb:irt-1, irl:irr-1);
  endfor

  ## Copy info struct fields over
  for ii=1:numel (fldsi)
    rio.(fldsi{ii}) = rii.(fldsi{ii});
  endfor
  rio.BitDepth = rii.BitDepth;
  ## Adapt required fields
  ## Geotransformation: right-left or left-right 
  rio.GeoTransformation = rii.GeoTransformation;
  if (rio.GeoTransformation(2) > 0)
    rio.GeoTransformation(1) = xpx(irl);
  else
    rio.GeoTransformation(1) = xpx(irr);
  endif
  ## Top-down or bottom-up
  if (rio.GeoTransformation(6) < 0)
    rio.GeoTransformation(4) = ypx(irt);
  else
    rio.GeoTransformation(4) = ypx(irb);
  endif
  rio.Width       = irr - irl;
  rio.Height      = irt - irb;
  rio.nbands      = rii.nbands;
  rio.bbox        = rbo.bbox;
  rio.Filename    = "";
  rio.Filesize    = [];
  rio.FileModDate = "";

endfunction
