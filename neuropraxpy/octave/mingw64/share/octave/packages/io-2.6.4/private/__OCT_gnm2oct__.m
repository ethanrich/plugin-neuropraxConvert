## Copyright (C) 2013-2021 Philip Nienhuis
## 
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or
## (at your option) any later version.
## 
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
## 
## You should have received a copy of the GNU General Public License
## along with Octave; see the file COPYING.  If not, see
## <http://www.gnu.org/licenses/>.

## -*- texinfo -*- 
## @deftypefn {Function File} [@var{raw}, @var{ods}, @var{rstatus} = __OCT_gnm2oct__ (@var{ods}, @var{wsh}, @var{range}, @var{opts})
## Internal function for reading data from a Gnumeric worksheet
##
## @seealso{}
## @end deftypefn

## Author: Philip Nienhuis <prnienhuis at users.sf.net>
## Created: 2013-10-01

function [ rawarr, xls, rstatus] = __OCT_gnm2oct__ (xls, wsh, cellrange='', spsh_opts)

  rstatus = 0;

  ## Check if requested worksheet exists in the file & if so, get sheet
  if (isnumeric (wsh))
    if (wsh > numel (xls.sheets.sh_names) || wsh < 1)
      error ("xls2oct: sheet number (%d) out of range (1 - %d)", wsh, numel (xls.sheets.sh_names));
    endif
  elseif (ischar (wsh))
    idx = find (strcmp (wsh, xls.sheets.sh_names));
    if (isempty (idx))
      error ("xls2oct: sheet '%s' not found in file %s", wsh, xls.filename);
    endif
    wsh = idx;
  endif

  ## Get requested sheet from info in file struct pointer. Open file
  fid = fopen (xls.workbook, "r");
  ## Go to start of requested sheet. This requires reading from start, not
  ## from after 1st xml id line
  fseek (fid, xls.sheets.shtidx(wsh), 'bof');
  ## Compute size of requested chunk
  nchars = xls.sheets.shtidx(wsh+1) - xls.sheets.shtidx(wsh);
  ## Get the sheet
  xml = fread (fid, nchars, "char=>char").';
  fclose (fid);

  ## Add xml to struct pointer to avoid __OCT_getusedrange__ to read it again
  xls.xml = xml;

  ## Check ranges
  [ firstrow, lastrow, leftcol, rightcol ] = getusedrange (xls, wsh);

  ## Remove xml field
  xls.xml = [];
  xls = rmfield (xls, "xml");

  if (isempty (cellrange))
    if (firstrow == 0 && lastrow == 0)
      ## Empty sheet
      rawarr = {};
      printf ("Worksheet '%s' contains no data\n", xls.sheets.sh_names{wsh});
      rstatus = 1;
      return;
    else
      nrows = lastrow - firstrow + 1;
      ncols = rightcol - leftcol + 1;
    endif
  else
    [~, nr, nc, tr, lc] = parse_sp_range (cellrange);
    ## Check if requested range exists
    if (tr > lastrow || lc > rightcol)
      ## Out of occupied range
      warning ("xls2oct: requested range outside occupied range\n");
      rawarr = {};
      xls.limits = [];
      return
    endif
    
    lastrow  = min (lastrow, firstrow + nr - 1);
    rightcol = min (rightcol, leftcol + nc - 1);
  endif

  ## Get cell nodes
  cells = getxmlnode (xml, "gnm:Cells");

  ## Pattern gets most required tokens in one fell swoop
  pattrn = '<gnm:Cell Row="(\d*?)" Col="(\d*?)"(?: (?:ValueType|ExprID)="(\d*?)")(?: ValueFormat="\w+")?>(.*?)</gnm:Cell>';
  allvals = cell2mat (regexp (cells, pattrn, "tokens"));

  if (! isempty (allvals))
    ## Reshape into 4 x ... cell array
    allvals = reshape (allvals, 4,  numel (allvals) / 4);
  else
    allvals= cell(4, 0);
  endif

  ## For those cells w/o ValueType | ExprId tags
  pattrn = '<gnm:Cell Row="(\d*?)" Col="(\d*?)">(.*?)</gnm:Cell>';
  smevals = cell2mat (regexp (cells, pattrn, "tokens"));
  ## Reshape these into 3 X ... cell array, expand to 4 X ...
  if (! isempty (smevals))
    smevals = reshape (smevals, 3,  numel (smevals) / 3);
    smevals(4, :) = smevals(3, :);
    smevals(3, :) = 0;
  else
    smevals= cell(4, 0);
  endif

  ## Try to concatenate both
  allvals = [ allvals smevals ];

  ## Convert 0-based rw/column indices to 1-based numeric
  allvals(1:2, :) = num2cell (str2double (allvals(1:2, :)) + 1);
  ## Convert cell type values to double
  allvals(3, :)   = num2cell (str2double (allvals(3, :)));
  ## Convert numeric cell values to double
  in = find ([allvals{3,:}] == 40);
  allvals(4, in)  =  num2cell (str2double(allvals(4, in))');
  ## Convert boolean values to logical
  il = find ([allvals{3,:}] == 20);
  allvals(4, il)  =  num2cell (cellfun (@(x) strcmpi (x, "true"), allvals(4, il)));

  ## Get limits of data rectangle
  trow = min (cell2mat (allvals(1, :)));
  brow = max (cell2mat (allvals(1, :)));
  rcol = max (cell2mat (allvals(2, :)));
  lcol = min (cell2mat (allvals(2, :)));
  xls.limits = [lcol rcol; trow brow];

  ## Create data array
  rawarr = cell (brow-trow+1, rcol-lcol+1);

  ## Compute linear indices into data array from 1-based row/col indices
  idx = sub2ind (size (rawarr), [allvals{1, :}] - trow + 1, [allvals{2,:}] - lcol + 1);
  ## And assign cell values to data array
  rawarr(idx) = allvals(4, :);

  ## FIXME maybe reading parts of the data can be done faster above by better regexps
  ##       or sorting on row & truncating followed by sorting on columns and truncating
  if (! isempty (cellrange))
    ## We'll do it the easy way: just read all data, then return only the requested part
    xls.limits = [max(lcol, lc), min(rcol, lc+nc-1); max(trow, tr), min(brow, tr+nr-1)];
    ## Correct spreadsheet locations for lower right shift or raw
    rc = trow - 1;
    cc = lcol - 1;
    rawarr = rawarr(xls.limits(2, 1)-rc : xls.limits(2, 2)-rc, xls.limits(1, 1)-cc : xls.limits(1, 2)-cc);
  endif
 
  if (! isempty (allvals))
    rstatus = 1;
  endif

endfunction
