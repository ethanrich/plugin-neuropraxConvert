## Copyright (C) 2009-2021 P.R. Nienhuis
## parts Copyright (C) 2007 Michael Goffioul
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
## @deftypefn {Function File} [@var{obj}, @var{rstatus}, @var{xls} ] = __COM_spsh2oct__ (@var{xls})
## @deftypefnx {Function File} [@var{obj}, @var{rstatus}, @var{xls} ] = __COM_spsh2oct__ (@var{xls}, @var{wsh})
## @deftypefnx {Function File} [@var{obj}, @var{rstatus}, @var{xls} ] = __COM_spsh2oct__ (@var{xls}, @var{wsh}, @var{range})
## @deftypefnx {Function File} [@var{obj}, @var{rstatus}, @var{xls} ] = __COM_spsh2oct__ (@var{xls}, @var{wsh}, @var{range}, @var{spsh_opts})
## Get cell contents in @var{range} in worksheet @var{wsh} in an Excel
## file pointed to in struct @var{xls} into the cell array @var{obj}. 
##
## __COM_spsh2oct__ should not be invoked directly but rather through xls2oct.
##
## Examples:
##
## @example
##   [Arr, status, xls] = __COM_spsh2oct__ (xls, 'Second_sheet', 'B3:AY41');
##   Arr = __COM_spsh2oct__ (xls, 'Second_sheet');
## @end example
##
## @seealso {xls2oct, oct2xls, xlsopen, xlsclose, xlsread, xlswrite}
##
## @end deftypefn

## Author: Philip Nienhuis <pr.nienhuis at hccnet.nl>
## Based on mat2xls by Michael Goffioul (2007) <michael.goffioul@gmail.com>
## Created: 2009-09-23

function [rawarr, xls, rstatus ] = __COM_spsh2oct__ (xls, wsh, crange, spsh_opts)

  rstatus = 0; rawarr = {};
  
  ## Basic checks
  if (nargin < 2)
    error ("__COM_spsh2oct__ needs a minimum of 2 arguments."); 
  endif
  if (size (wsh, 2) > 31) 
    warning ("xls2oct: worksheet name too long - truncated\n") 
    wsh = wsh(1:31);
  endif
  app = xls.app;
  wb = xls.workbook;
  ## Check to see if ActiveX is still alive
  try
    wb_cnt = wb.Worksheets.count;
  catch
    error ("xls2oct: ActiveX invocation in file ptr struct seems non-functional");
  end_try_catch

  ## Check & get handle to requested worksheet. Take ""Sheets as the total
  ## user-visible count may include chartsheets and macrosheets
  wb_cnt = wb.Sheets.count;
  old_sh = 0;  
  if (isnumeric (wsh))
    if (wsh < 1 || wsh > wb_cnt)
      errstr = sprintf ("xls2oct: sheet number: %d out of range 1-%d", wsh, wb_cnt);
      error (errstr)
      rstatus = 1;
      return
    else
      old_sh = wsh;
    endif
  else
    ## Find worksheet number corresponding to name in wsh
    wb_cnt = wb.Worksheets.count;
    for ii =1:wb_cnt
      sh_name = wb.Worksheets(ii).name;
      if (strcmp (sh_name, wsh))
        old_sh = ii;
      endif
    endfor
    if (! old_sh)
      errstr = sprintf ("xls2oct: worksheet name \"%s\" not present", wsh);
      error (errstr)
    else
      wsh = old_sh;
    endif
  endif
  ## Finally get pointer to requested worksheet
  sh = wb.Sheets (wsh);    

  nrows = 0;
  if ((nargin == 2) || (isempty (crange)))
    allcells = sh.UsedRange;
    ## Get actually used range indices
    [trow, brow, lcol, rcol] = getusedrange (xls, old_sh);
    if (trow == 0 && brow == 0)
      ## Empty sheet
      rawarr = {};
      printf ("Worksheet '%s' contains no data\n", sh.Name);
      return;
    else
      nrows = brow - trow + 1; ncols = rcol - lcol + 1;
      topleft = calccelladdress (trow, lcol);
      lowerright = calccelladdress (brow, rcol);
      crange = [topleft ":" lowerright];
    endif
  else
    ## Extract top_left_cell from range
    [topleft, nrows, ncols, trow, lcol] = parse_sp_range (crange);
    brow = trow + nrows - 1;
    rcol = lcol + ncols - 1;
  endif;
  
  if (nrows >= 1) 
    ## Get object from Excel sheet, starting at cell top_left_cell
    rr = sh.Range (crange);
    if (spsh_opts.formulas_as_text)
      rawarr = rr.Formula;
    else
      rawarr = rr.Value;
    endif
    delete (rr);

    ## Take care of actual singe cell range
    if (isnumeric (rawarr) || ischar (rawarr))
      rawarr = {rawarr};
    endif

    if (spsh_opts.convert_utf) ...
        && (compare_versions (ver ("windows").Version, "1.5.0", "<="))
      ## The COM interface in of-windows until version 1.5.0 returns strings
      ## that are encoded in the system locale.  All character values not
      ## contained in the locale encoding are mapped to codepoint 32 (space
      ## character).  Try to recover the remainder.
      if (isempty (which ("native2unicode")))
        ## Not available before Octave 4.4
        ## Use fallback function. (Assumes the locale is ISO 8859-1.)
        conv_fcn = @unicode2utf8;
      else
        if (isempty (which ("__locale_charset__")))
          ## Not available before Octave 6
          ## Assume ISO 8859-1 (Latin-1)
          enc = "iso8859-1";
        else
          enc = __locale_charset__ ();
        endif
        conv_fcn = @(str) native2unicode (uint8 (str), enc);
      endif

      idx = cellfun (@ischar, rawarr);
      rawarr(idx) = cellfun (conv_fcn, rawarr(idx), "uniformoutput", false);
    endif
    
    ## If we get here, all seems to have gone OK
    rstatus = 1;
    ## Keep track of data rectangle limits
    xls.limits = [lcol, rcol; trow, brow];
  else
    warning ("xls2oct: no data read from spreadsheet file");
    rstatus = 0;
  endif
  
endfunction
