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
## @deftypefn {Function File} [ @var{xlso}, @var{rstatus} ] = __POI_oct2spsh__ ( @var{arr}, @var{xlsi})
## @deftypefnx {Function File} [ @var{xlso}, @var{rstatus} ] = __POI_oct2spsh__ (@var{arr}, @var{xlsi}, @var{wsh})
## @deftypefnx {Function File} [ @var{xlso}, @var{rstatus} ] = __POI_oct2spsh__ (@var{arr}, @var{xlsi}, @var{wsh}, @var{range})
## @deftypefnx {Function File} [ @var{xlso}, @var{rstatus} ] = __POI_oct2spsh__ (@var{arr}, @var{xlsi}, @var{wsh}, @var{range}, @var{options})
##
## Add data in 1D/2D CELL array @var{arr} into a range with upper left
## cell equal to @var{topleft} in worksheet @var{wsh} in an Excel
## spreadsheet file pointed to in structure @var{range}.
## Return argument @var{xlso} equals supplied argument @var{xlsi} and is
## updated by __POI_oct2spsh__.
##
## __POI_oct2spsh__ should not be invoked directly but rather through oct2xls.
##
## Example:
##
## @example
##   [xlso, status] = __POI_oct2spsh__ ("arr", xlsi, "Third_sheet", "AA31");
## @end example
##
## @seealso {oct2xls, xls2oct, xlsopen, xlsclose, xlsread, xlswrite}
##
## @end deftypefn

## Author: Philip Nienhuis <prnienhuis at users.sf.net>
## Created: 2009-11-26

function [ xls, rstatus ] = __POI_oct2spsh__ (obj, xls, wsh, crange, spsh_opts)

  ## Preliminary sanity checks
  if (isempty (strcmpi (xls.filename(end-3:end), ".xls")))
    error ("oct2xls: POI interface can only write to Excel .xls or .xlsx files")
  endif

  persistent ctype poiv4 p4ctype;
  if (isempty (ctype))
    ## Get enumerated cell types. Beware as they start at 0 not 1
    try
      ## POI < 4
      ctype(1) = __java_get__ ("org.apache.poi.ss.usermodel.Cell", "CELL_TYPE_NUMERIC");## 0
      ctype(2) = __java_get__ ("org.apache.poi.ss.usermodel.Cell", "CELL_TYPE_BOOLEAN");## 4
      ctype(3) = __java_get__ ("org.apache.poi.ss.usermodel.Cell", "CELL_TYPE_STRING"); ## 1
      ctype(4) = __java_get__ ("org.apache.poi.ss.usermodel.Cell", "CELL_TYPE_FORMULA");## 2
      ctype(5) = __java_get__ ("org.apache.poi.ss.usermodel.Cell", "CELL_TYPE_BLANK");  ## 3
      poiv4 = false;
    catch
      ## POI >= 4
      p4ctype.enum =  __java_get__ ("org.apache.poi.ss.usermodel.CellType", "NUMERIC");
      ctype(1) = p4ctype.enum.ordinal;
      p4ctype.name = "numeric";
      p4ctype(2).enum = __java_get__ ("org.apache.poi.ss.usermodel.CellType", "BOOLEAN");
      ctype(2) = p4ctype(2).enum.ordinal;
      p4ctype(2).name = "boolean";
      p4ctype(3).enum =  __java_get__ ("org.apache.poi.ss.usermodel.CellType", "STRING");
      ctype(3) = p4ctype(3).enum.ordinal;
      p4ctype(3).name = "string";
      p4ctype(4).enum = __java_get__ ("org.apache.poi.ss.usermodel.CellType", "FORMULA");
      ctype(4) = p4ctype(4).enum.ordinal;
      p4ctype(4).name = "formula";
      p4ctype(5).enum = __java_get__ ("org.apache.poi.ss.usermodel.CellType", "BLANK");
      ctype(5) = p4ctype(5).enum.ordinal;
      p4ctype(5).name = "blank";
      poiv4 = true;
    end_try_catch
  endif
  ## scratch vars
  rstatus = 0;
  f_errs = 0;

  ## Check if requested worksheet exists in the file & if so, get pointer
  try
    nr_of_sheets = xls.workbook.getNumWorkSheets ();
  catch
    nr_of_sheets = xls.workbook.getNumberOfSheets ();
  end_try_catch
  if (isnumeric (wsh))
    if (wsh > nr_of_sheets)
      ## Watch out as a sheet called Sheet%d can exist with a lower index...
      strng = sprintf ("Sheet%d", wsh);
      ii = 1;
      while (! isempty (xls.workbook.getSheet (strng)) && (ii < 5))
        strng = ["_" strng];
        ++ii;
      endwhile
      if (ii >= 5)
        error (sprintf ("oct2xls:  > 5 sheets named [_]Sheet%d already present!", wsh));
      endif
      sh = xls.workbook.createSheet (strng);
      xls.changed = min (xls.changed, 2);       ## Keep 2 for new files
    else
      sh = xls.workbook.getSheetAt (wsh - 1);   ## POI sheet count 0-based
    endif
    printf ("(Writing to worksheet %s)\n",   sh.getSheetName ());  
  else
    sh = xls.workbook.getSheet (wsh);
    if (isempty (sh))
      ## Sheet not found, just create it
      sh = xls.workbook.createSheet (wsh);
      xls.changed = min (xls.changed, 2);       ## Keep 2 or 3 f. new files
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
  ## Remove leading "=" from formula strings
  fptr = (typearr == 4);
  obj(fptr) = cellfun (@(x) x(2:end), obj(fptr), "Uniformoutput", false);

  ## Create formula evaluator
  frm_eval = xls.workbook.getCreationHelper ().createFormulaEvaluator ();

  for ii=1:nrows
    ll = ii + trow - 2;                         ## Java POI's row count 0-based
    row = sh.getRow (ll);
    if (isempty (row))
      row = sh.createRow (ll); 
    endif
    for jj=1:ncols
      kk = jj + lcol - 2;                       ## POI's column count is 0-based
      if (typearr(ii, jj) == 5)                 ## Empty cells
        if (poiv4)
          cell = row.createCell (kk, p4ctype(5).enum);
        else
          cell = row.createCell (kk, ctype(5));
        endif
      elseif (typearr(ii, jj) == 4)             ## Formulas
        ## Try-catch needed as there's no guarantee for formula correctness
        try
          if (poiv4)
            cell = row.createCell (kk, p4ctype(4).enum);
          else
            cell = row.createCell (kk, ctype(4));
          endif
          cell.setCellFormula (obj{ii,jj});
        catch                  
          ++f_errs;
          ## Enter formula as text
          if (poiv4)
            cell.setCellType (p4ctype(3).enum);
          else
            cell.setCellType (ctype (3));
          endif
          cell.setCellValue (obj{ii, jj});
        end_try_catch
      else
        if (poiv4)
          cell = row.createCell (kk, p4ctype(typearr(ii,jj)).enum);
        else
          cell = row.createCell (kk, ctype(typearr(ii,jj)));
        endif
        if (isnumeric (obj{ii, jj}))
          cell.setCellValue (obj{ii, jj});
        else
          cell.setCellValue (obj{ii, jj});
        endif
      endif
    endfor
  endfor
  
  if (f_errs) 
    printf ("%d formula errors encountered - please check input array\n", f_errs);
  endif
  xls.changed = max (xls.changed, 1);           ## Preserve a "2"
  rstatus = 1;
  
endfunction
