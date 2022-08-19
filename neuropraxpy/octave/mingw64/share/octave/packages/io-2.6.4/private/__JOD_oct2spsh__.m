## Copyright (C) 2009-2021 Philip Nienhuis
##
## This program is free software; you can redistribute it and/or modify it under
## the terms of the GNU General Public License as published by the Free Software
## Foundation; either version 3 of the License, or (at your option) any later
## version.
##
## This program is distributed in the hope that it will be useful, but WITHOUT
## ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
## FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
## details.
##
## You should have received a copy of the GNU General Public License along with
## this program; if not, see <http://www.gnu.org/licenses/>.

## __JOD_oct2spsh__ - write data from octave to an ODS spreadsheet using the
## jOpenDocument interface.
##
## Author: Philip Nienhuis <pr.nienhuis at users.sf.net>
## Created: 2009-12-13

function [ ods, rstatus ] = __JOD_oct2spsh__ (c_arr, ods, wsh, crange)

  rstatus = 0; 
  sh = []; 
  changed = 0;

  ## Get worksheet. Use first one if none given
  if (isempty (wsh))
    wsh = 1;
  endif
  sh_cnt = ods.workbook.getSheetCount ();
  if (isnumeric (wsh))
    if (wsh > 1024)
      error ("oct2xls: sheet number out of range of ODS specification (>1024)");
    elseif (wsh > sh_cnt)
      error ("oct2xls: sheet number (%d) larger than number of sheets in file (%d)\n",...
              wsh, sh_cnt);
    else
      wsh = wsh - 1;
      sh = ods.workbook.getSheet (wsh);
      ## Workaround for JOD bug that introduces "A" & "B" col headers
      if (ods.changed >= 2)
        sh.getCellAt (0, 0).clearValue ();
        sh.getCellAt (1, 0).clearValue ();
      endif  
      if (isempty (sh))
        ## Sheet number wsh didn't exist yet
        wsh = sprintf ("Sheet%d", wsh+1);
      elseif (ods.changed > 2)
        sh.setName ("Sheet1");
        changed = 1;
      endif
    endif
  endif
  ## wsh is now either a 0-based sheet no. or a string. In latter case:
  if (isempty (sh) && ischar (wsh))
    sh = ods.workbook.getSheet (wsh);
    if (isempty (sh))
      ## Still doesn't exist. Create sheet
      if (ods.odfvsn >= 3)
        if (ods.changed > 2)
          ## 1st "new" -unnamed- sheet has already been made when creating the spreadsheet
          sh = ods.workbook.getSheet (0);
          sh.setName (wsh);
          changed = 1;
          ## Workaround for JOD bug that introduces "A" & "B" col headers
          if (ods.changed >= 2)
            sh.getCellAt (0, 0).clearValue ();
            sh.getCellAt (1, 0).clearValue ();
          endif  
        else
          ## For existing spreadsheets
          ## printf ("Adding sheet '%s'\n", wsh);
          sh = ods.workbook.addSheet (sh_cnt, wsh);
          changed = 1;
        endif
        ## jOpenDocument bug: JOD seems to add "A" to A1 and "B" to B1
        try
          if (! isempty (sh.getCellAt (0, 0).getValue))
            sh.getCellAt (0, 0).clearValue();
            sh.getCellAt (1, 0).clearValue();
          endif
        catch
        end_try_catch
      else
        error (["oct2xls: jOpenDocument v. 1.2b2 does not support adding sheets" ...
                " - upgrade to v. 1.4\n"]);
      endif
    endif
  endif

  [nr, nc] = size (c_arr);
  if (isempty (crange))
    trow = 0;
    lcol = 0;
    nrows = nr;
    ncols = nc;
  elseif (isempty (strfind (deblank (crange), ":"))) 
    [~, ~, ~, trow, lcol] = parse_sp_range (crange);
    nrows = nr;
    ncols = nc;
    ## Row/col = 0 based in jOpenDocument
    trow = trow - 1; 
    lcol = lcol - 1;
  else
    [~, nrows, ncols, trow, lcol] = parse_sp_range (crange);
    ## Row/col = 0 based in jOpenDocument
    trow = trow - 1; 
    lcol = lcol - 1;
  endif

  if (trow > 65535 || lcol > 1023)
    error ("oct2xls: topleft cell beyond spreadsheet limits (AMJ65536).");
  endif
  ## Check spreadsheet capacity beyond requested topleft cell
  nrows = min (nrows, 65536 - trow);      ## Remember, lcol & trow are zero-based
  ncols = min (ncols, 1024 - lcol);
  ## Check array size and requested range
  nrows = min (nrows, nr);
  ncols = min (ncols, nc);
  if (nrows < nr || ncols < nc)
    warning ("oct2xls: array truncated to fit in range\n");
  endif

  if (isnumeric (c_arr))
    c_arr = num2cell (c_arr);
  endif

  ## Ensure sheet capacity is large enough to contain new data
  try    ## try-catch needed to work around bug in jOpenDocument v 1.2b3 and earlier
    sh.ensureColumnCount (lcol + ncols);  ## Remember, lcol & trow are zero-based
  catch  ## catch is needed for new empty sheets (first ensureColCnt() hits null ptr)
    sh.ensureColumnCount (lcol + ncols);
    ## Kludge needed because upper row is defective (NPE jOpenDocument bug). ?Fixed in 1.2b4?
    if (trow == 0)
      ## Shift rows one down to avoid defective upper row
      ++trow;
      printf ("Info: empy upper row above data added to avoid JOD bug.\n");
    endif
  end_try_catch
  sh.ensureRowCount (trow + nrows);

  ## Write data to worksheet. JOD's left cell index = column not row
  for ii = 1 : nrows
    for jj = 1 : ncols
      val = c_arr {ii, jj};
      if ((isnumeric (val) && ! isnan (val)) || ischar (val) || islogical (val))
        ## jOpenDocument < 1.3 doesn't really support writing booleans (doesn't set OffValAttr)
        if ((ods.odfvsn <= 3) && islogical (val))
          val = double (val);
        endif
        try
          sh.getCellAt (jj + lcol - 1, ii + trow - 1).clearValue();
          jcell = sh.getCellAt (jj + lcol - 1, ii + trow - 1).setValue (val);
          changed = 1;
        catch
          ## No panic, probably a merged cell
          ##  printf (sprintf ("Cell skipped at (%d, %d)\n", ii+lcol-1, jj+trow-1));
        end_try_catch
      endif
    endfor
  endfor

  if (changed)
    ods.changed = max (min (ods.changed, 2), changed);  # Preserve 2 (new file), 1 (existing)
    rstatus = 1;
  endif

endfunction
