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
## @deftypefn {Function File} [ @var{xlso}, @var{rstatus} ] = __JXL_oct2spsh__ ( @var{arr}, @var{xlsi})
## @deftypefnx {Function File} [ @var{xlso}, @var{rstatus} ] = __JXL_oct2spsh__ (@var{arr}, @var{xlsi}, @var{wsh})
## @deftypefnx {Function File} [ @var{xlso}, @var{rstatus} ] = __JXL_oct2spsh__ (@var{arr}, @var{xlsi}, @var{wsh}, @var{range})
## @deftypefnx {Function File} [ @var{xlso}, @var{rstatus} ] = __JXL_oct2spsh__ (@var{arr}, @var{xlsi}, @var{wsh}, @var{range}, @var{options})
##
## Add data in 1D/2D CELL array @var{arr} into spreadsheet cell range @var{range}
## in worksheet @var{wsh} in an Excel spreadsheet file pointed to in structure
## @var{range}.
## Return argument @var{xlso} equals supplied argument @var{xlsi} and is
## updated by __JXL_oct2spsh__.
##
## __JXL_oct2spsh__ should not be invoked directly but rather through oct2xls.
##
## Example:
##
## @example
##   [xlso, status] = __JXL_oct2spsh__ ('arr', xlsi, 'Third_sheet', 'AA31');
## @end example
##
## @seealso {oct2xls, xls2oct, xlsopen, xlsclose, xlsread, xlswrite, xls2jxla2oct}
##
## @end deftypefn

## Author: Philip Nienhuis <prnienhuis at users.sf.net>
## Created: 2009-12-04

function [ xls, rstatus ] = __JXL_oct2spsh__ (obj, xls, wsh, crange, spsh_opts)

  ## Preliminary sanity checks
  if (strcmpi (xls.filename(end-4:end-1), ".xls"))  ## No OOXML in JXL
    error ("oct2xls: JXL interface can only process Excel .xls files")
  endif

  persistent ctype;
  if (isempty (ctype))
    ctype = [1, 2, 3, 4, 5];
    ## Number, Boolean, String, Formula, Empty
  endif
  ## scratch vars
  rstatus = 0;
  f_errs = 0;

  ## Prepare workbook pointer if needed
  if (xls.changed == 0)      ## Only for 1st call of octxls after xlsopen
    ## Create writable copy of workbook. If >2 a writable wb was made in xlsopen
    xlsout = javaObject ("java.io.File", xls.filename);
    wb = javaMethod ("createWorkbook", "jxl.Workbook", xlsout, xls.workbook);
    ## Catch JExcelAPI bug/"feature": when switching to write mode, the file on disk
    ## is affected and the memory file MUST be written to disk to save earlier data
    xls.changed = 1;
    xls.workbook = wb;
  else
    wb = xls.workbook;
  endif
  ## Check if requested worksheet exists in the file & if so, get pointer
  nr_of_sheets = xls.workbook.getNumberOfSheets ();  ## 1 based !!
  if (isnumeric (wsh))
    if (wsh > nr_of_sheets)
      ## Watch out as a sheet called Sheet%d can exist with a lower index...
      strng = sprintf ("Sheet%d", wsh);
      ii = 1;
      while (~isempty (wb.getSheet (strng)) && (ii < 5))
        strng = ["_" strng];
        ++ii;
      endwhile
      if (ii >= 5)
        error (sprintf( "oct2xls: > 5 sheets named [_]Sheet%d already present!", wsh));
      endif
      sh = wb.createSheet (strng, nr_of_sheets); ++nr_of_sheets;
      xls.changed = min (xls.changed, 2);    ## Keep a 2 in case of new file
    else
      sh = wb.getSheet (wsh - 1);        ## JXL sheet count 0-based
    endif
    shnames = char (wb.getSheetNames ());
    printf ("(Writing to worksheet %s)\n",   shnames {nr_of_sheets, 1});
  else
    sh = wb.getSheet (wsh);
    if (isempty(sh))
      ## Sheet not found, just create it
      sh = wb.createSheet (wsh, nr_of_sheets);
      ++nr_of_sheets;
      xls.changed = min (xls.changed, 2);    ## Keep a 2 for new file
    endif
  endif

  ## Parse date ranges
  [nr, nc] = size (obj);
  [topleft, nrows, ncols, trow, lcol] = ...
                    spsh_chkrange (crange, nr, nc, xls.xtype, xls.filename);
  if (nrows < nr || ncols < nc)
    warning ("oct2xls: array truncated to fit in range\n");
    obj = obj(1:nrows, 1:ncols);
  endif

  ## Prepare type array
  typearr = spsh_prstype (obj, nrows, ncols, ctype, spsh_opts);
  if (! spsh_opts.formulas_as_text)
    ## Remove leading '=' from formula strings
    fptr = ! (4 * (ones (size (typearr))) - typearr);
    obj(fptr) = cellfun (@(x) x(2:end), obj(fptr), "Uniformoutput", false);
  endif
  clear fptr

  ## Write date to worksheet
  for ii=1:nrows
    ll = ii + trow - 2;        ## Java JExcelAPI's row count = 0-based
    for jj=1:ncols
      kk = jj + lcol - 2;    ## JExcelAPI's column count is also 0-based
      switch typearr(ii, jj)
        case 1      ## Numerical
          tmp = javaObject ("jxl.write.Number", kk, ll, obj{ii, jj});
          sh.addCell (tmp);
        case 2      ## Boolean
          tmp = javaObject ("jxl.write.Boolean", kk, ll, obj{ii, jj});
          sh.addCell (tmp);
        case 3      ## String
          tmp = javaObject ("jxl.write.Label", kk, ll, obj{ii, jj});
          sh.addCell (tmp);
        case 4      ## Formula
          ## First make sure formula functions are all uppercase
          obj{ii, jj} = toupper (obj{ii, jj});
          ## There's no guarantee for formula correctness, so....
          try    ## Actually JExcelAPI flags formula errors as mere warnings :-(
            tmp = javaObject ("jxl.write.Formula", kk, ll, obj{ii, jj});
            ## ... while errors are actually detected in addCell(), so
            ##     that should be within the try-catch
            sh.addCell (tmp);
          catch
            ++f_errs;
            ## Formula error. Enter formula as text string instead
            tmp = javaObject ("jxl.write.Label", kk, ll, obj{ii, jj});
            sh.addCell (tmp);
          end_try_catch
        case 5    ## Empty or NaN
          tmp = javaObject ("jxl.write.Blank", kk, ll);
          sh.addCell (tmp);
        otherwise
          ## Just skip
      endswitch
    endfor
  endfor

  if (f_errs)
    printf ("%d formula errors encountered - please check input array\n", f_errs);
  endif
  xls.changed = max (xls.changed, 1);    ## Preserve 2 for new files
  rstatus = 1;

endfunction
