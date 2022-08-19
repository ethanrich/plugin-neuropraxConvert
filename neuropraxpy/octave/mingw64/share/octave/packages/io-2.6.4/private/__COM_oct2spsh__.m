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

## -*- texinfo -*-
## @deftypefn {Function File} [@var{xlso}, @var{status}] = __COM_oct2spsh__ (@var{obj}, @var{xlsi})
## @deftypefnx {Function File} [@var{xlso}, @var{status}] = __COM_oct2spsh__ (@var{obj}, @var{xlsi}, @var{wsh})
## @deftypefnx {Function File} [@var{xlso}, @var{status}] = __COM_oct2spsh__ (@var{obj}, @var{xlsi}, @var{wsh}, @var{top_left_cell})
## Save matrix @var{obj} into worksheet @var{wsh} in Excel file pointed
## to in struct @var{xlsi}. All elements of @var{obj} are converted into
## Excel cells, starting at cell @var{top_left_cell}. Return argument
## @var{xlso} is @var{xlsi} with updated fields.
##
## __COM_oct2spsh__ should not be invoked directly but rather through oct2xls.
##
## Excel invocations may be left running invisibly in case of COM errors.
##
## Example:
##
## @example
##   xls = __COM_oct2spsh__ (rand (10, 15), xls, 'Third_sheet', 'BF24');
## @end example
##
## @seealso {oct2xls, xls2oct, xlsopen, xlsclose, xlswrite, xlsread, xls2com2oct}
##
## @end deftypefn

## Author: Philip Nienhuis <prnienhuis@users.sf.net>
##        (originally based on mat2xls by Michael Goffioul)
## Rewritten: 2009-09-26

function [ xls, status ] = __COM_oct2spsh__ (obj, xls, wsh, crange, spsh_opts)

  ## Preliminary sanity checks
  ## FIXME - Excel can write to much more than .xls/.xlsx (but not to all
  ##         formats with multiple sheets):
  ##         .wk1 .wk3 .wk4 .csv .pxl .html .dbf .txt .prn .wks .wq1 .dif
  if (! strfind (lower (xls.filename(end-4:end)), ".xls"))
    error ("oct2xls: COM interface can only write to Excel .xls or .xlsx files\n")
  endif
  if (isnumeric (wsh))
    if (wsh < 1) error ("oct2xls: illegal worksheet number: %i\n", wsh); endif
  elseif (size (wsh, 2) > 31)
    error ("oct2xls: illegal worksheet name - too long\n")
  endif
  ## Check to see if ActiveX is still alive
  try
    wb_cnt = xls.workbook.Worksheets.count;
  catch
    error ("oct2xls: ActiveX invocation in file ptr struct seems non-functional\n");
  end_try_catch

  ## define some constants not yet in __COM__.cc
  xlWorksheet = -4167; ## xlChart= 3 or 4;
  ## scratch vars
  status = 0;

  ## Parse date ranges
  [nr, nc] = size (obj);
  [topleft, nrows, ncols, trow, lcol] = ...
                    spsh_chkrange (crange, nr, nc, xls.xtype, xls.filename);
  lowerright = calccelladdress (trow + nrows - 1, lcol + ncols - 1);
  crange = [topleft ":" lowerright];
  if (nrows < nr || ncols < nc)
    warning ("oct2xls: array truncated to fit in range\n");
    obj = obj(1:nrows, 1:ncols);
  endif

  ## Cleanup NaNs. Find where they are and mark as empty
  ctype = [1 2 3 4 5];              ## Numeric Boolean Text Formula Empty
  typearr = spsh_prstype (obj, nrows, ncols, ctype, spsh_opts);
  ## Make cells now indicated to be empty, empty
  fptr = ! (5 * (ones (size (typearr))) - typearr);
  obj(fptr) = cellfun (@(x) [], obj(fptr), "Uniformoutput",  false);

  if (spsh_opts.formulas_as_text)
    ## find formulas (designated by a string starting with "=" and ending in ")")
    fptr = cellfun (@(x) ischar (x) && strncmp (x, "=", 1) ...
                                    && strncmp (x(end:end), ")", 1), obj);
    ## ... and add leading "'" character
    obj(fptr) = cellfun (@(x) ["'" x], obj(fptr), "Uniformoutput", false);
  endif
  clear fptr;

  if (xls.changed < 3)
    ## Existing file OR a new file with data added in a previous oct2xls call.
    ## Some involved investigation is needed to preserve
    ## existing data that shouldn't be touched.
    ##
    ## See if desired *sheet* name exists.
    old_sh = 0;
    ws_cnt = xls.workbook.Sheets.count;
    if (isnumeric (wsh))
      if (wsh <= ws_cnt)
        ## Here we check for sheet *position* in the sheet stack
        ## rather than a name like "Sheet<Number>"
        old_sh = wsh;
      else
        ## wsh > nr of sheets; proposed new sheet name.
        ## This sheet name can already exist to the left in the sheet stack!
        shnm = sprintf ("Sheet%d", wsh);
        shnm1 = shnm;
      endif
    endif
    if (! old_sh)
      ## Check if the requested (or proposed) sheet already exists
      ## COM objects are not OO (yet?), so we need a WHILE loop
      ii = 1; jj = 1;
      while ((ii <= ws_cnt) && ! old_sh)
        ## Get existing sheet names one by one
        sh_name = xls.workbook.Sheets(ii).name;
        if (! isnumeric (wsh) && strcmp (sh_name, wsh))
          ## ...and check with requested sheet *name*...
          old_sh = ii;
        elseif (isnumeric (wsh) && strcmp (sh_name, shnm))
          ## ... or proposed new sheet name (corresp. to requested sheet *number*)
          shnm = [shnm "_"];
          ii = 0;        ## Also check if this new augmented sheet name exists...
          if (strcmp (shnm1, sh_name)), jj++; endif
          if (jj > 5)   ## ... but not unlimited times...
            error (sprintf ...
                ("oct2xls: > 5 sheets named [_]Sheet%d already present!\n", wsh));
          endif
        endif
        ++ii;
      endwhile
    endif

    if (old_sh)
      ## Requested sheet exists. Check if it is a *work*sheet
      if (! (xls.workbook.Sheets(old_sh).Type == xlWorksheet))
        ## Error as you can't write data to Chart sheet
        error (sprintf ("oct2xls: existing sheet '%s' is not type worksheet.\n", wsh));
      else
        ## Simply point to the relevant sheet
        sh = xls.workbook.Sheets (old_sh);
      endif
    else
      ## Add a new worksheet. Earlier it was checked whether this is safe
      try
        sh = xls.workbook.Worksheets.Add ();
      catch
        error (sprintf ("oct2xls: can't add new worksheet to file %s\n", xls.filename));
      end_try_catch
      if (! isnumeric (wsh))
        sh.Name = wsh;
      else
        sh.Name = shnm;
        printf ("Writing to worksheet %s\n", shnm);
      endif
      ## Prepare to move new sheet to right of the worksheet stack anyway
      ws_cnt = xls.workbook.Sheets.count;      ## New count needed
      ## Find where Excel has left it. We have to, depends on Excel version :-(

      ii = 1;
      while ((ii < ws_cnt+1) && ! strcmp (sh.Name, xls.workbook.Sheets(ii).Name) == 1)
        ++ii;
      endwhile
      ## Excel can't move it beyond the current last one, so we need a trick.
      ## First move it to just before the last one....
      xls.workbook.Sheets(ii).Move (before = xls.workbook.Sheets(ws_cnt));
      ## ....then move the last one before the new sheet.
      xls.workbook.Sheets (ws_cnt).Move (before = xls.workbook.Sheets(ws_cnt - 1));
    endif

  else
    ## The easy case: a new Excel file. Workbook was created in xlsopen.

    ## Delete empty non-used sheets, last one first
    xls.app.Application.DisplayAlerts = 0;
    ii = xls.workbook.Sheets.count;
    while (ii > 1)
      xls.workbook.Sheets(ii).Delete();
      --ii;
    endwhile
    xls.app.Application.DisplayAlerts = 1;

    ## Write to first worksheet:
    sh = xls.workbook.Worksheets (1);
    ## Rename the sheet
    if (isnumeric (wsh))
      sh.Name = sprintf ("Sheet%i", wsh);
    else
      sh.Name = wsh;
    endif
    xls.changed = 2;      ## 3 => 2
  endif

  if (spsh_opts.convert_utf) ...
      && (compare_versions (ver ("windows").Version, "1.5.0", "<="))
    ## The COM interface in of-windows until version 1.5.0 expected strings
    ## that were encoded in the system locale.  Not all Unicode characters can
    ## be encoded in a non-Unicode locale.  Try to convert as much as possible.
    if (isempty (which ("unicode2native")))
      ## Not available before Octave 4.4
      ## Use fallback function. (Assumes the locale is ISO 8859-1.)
      conv_fcn = @utf82unicode;
    else
      if (isempty (which ("__locale_charset__")))
        ## Not available before Octave 6
        ## Assume ISO 8859-1
        enc = "iso8859-1";
      else
        enc = __locale_charset__ ();
      endif
      conv_fcn = @(str) char (unicode2native (str, enc));
    endif
    obj = cellfun (conv_fcn, obj, "uniformoutput", false);
  endif

  ## MG's original part.
  ## Save object in Excel sheet, starting at cell top_left_cell
  if (! isempty(obj))
    r = sh.Range (crange);
    try
      r.Value = obj;
    catch
      error (sprintf ("oct2xls: can't add data to worksheet %s in file %s\n",...
                      sh.Name, xls.filename));
    end_try_catch
    delete (r);
  endif

  ## If we get here, all went OK
  status = 1;
  xls.changed = max (xls.changed, 1);      ## If it was 2, preserve it.

endfunction
