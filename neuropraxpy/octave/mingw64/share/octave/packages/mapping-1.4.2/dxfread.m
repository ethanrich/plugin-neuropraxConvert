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
## @deftypefn {} {@var{dxf} =} dxfread (@var{fname})
## Read a DXF file (text file) into a Nx3 cell array.
##
## @var{fname} is the file name or full path name of a text format (not
## binary) DXF file, with or without "dxf" extension.
##
## Output variable @var{dxf} is a cell array with DXF codes in column 1,
## the corresponding DXF text info (or empty string) in column 2, and
## corresponding numeric values (or NaN) in column 3.  Use dxfparse for
## converting the output into a DXF drawing struct or separate mapstructs
## for each ENTITY type in the DXF file.
##
## @seealso{dxfparse, dxfdraw}
## @end deftypefn

## Author: Philip Nienhuis <prnienhuis@users.sf.net>
## Created: 2016-01-25

function [dxf] = dxfread (fname)

  if (! ischar (fname))
    print_usage ();
  endif

  [pth, fn, ext] = fileparts (fname);
  if (isempty (ext))
    ext = ".dxf";
    fname = [fname ext];
  elseif (! strcmpi (ext, ".dxf"))
    error ("dxfread: file is no .DXF file");
  endif

  fid = fopen (fname);
  if (fid < 0)
    error ("file %s not found", fname);
  else
    txt = fread (fid, Inf, "char=>char")'; 
    fclose (fid);
  endif

  ## Assess EOL character
  eol = regexp (txt(1: min (2000, length (txt))), "\r\n", "match", "once");
  if (isempty (eol))
    eol = "\n";
  endif

  ## DXF files comprise pairs of lines: 1st line = numeric code, 2nd = contents
  dxf = reshape (cell2mat ( ...
        regexp (txt, sprintf ('(\\d+)%s(.+?)%s', eol, eol), "tokens")), 2, [])';
  ## Convert col 1 into numeric
  dxf(:, 1) = num2cell (str2double (dxf(:, 1)));
  ## Convert numeric entries in col2 into numeric col3
  dxf(:, 3) = num2cell (str2double (dxf(:, 2)));
  dxf(! cellfun (@isnan, dxf(:, 3)), 2) = {""};

endfunction
