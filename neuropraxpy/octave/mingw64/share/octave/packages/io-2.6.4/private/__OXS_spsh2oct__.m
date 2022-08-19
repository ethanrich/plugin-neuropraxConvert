## Copyright (C) 2011-2021 Philip Nienhuis
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
## @deftypefn {Function File} [@var{obj}, @var{rstatus}, @var{xls} ] = __OXS_spsh2oct__ (@var{xls})
## @deftypefnx {Function File} [@var{obj}, @var{rstatus}, @var{xls} ] = __OXS_spsh2oct__ (@var{xls}, @var{wsh})
## @deftypefnx {Function File} [@var{obj}, @var{rstatus}, @var{xls} ] = __OXS_spsh2oct__ (@var{xls}, @var{wsh}, @var{range})
## Get cell contents in @var{range} in worksheet @var{wsh} in an Excel
## file pointed to in struct @var{xls} into the cell array @var{obj}.
## @var{range} can be a range or just the top left cell of the range.
##
## __OXS_spsh2oct__ should not be invoked directly but rather through xls2oct.
##

## Author: Philip Nienhuis <prnienhuis at users.sf.net>
## Created: 2011-03-26

function [ rawarr, xls, rstatus ] = __OXS_spsh2oct__ (xls, wsh, cellrange, spsh_opts)

  persistent ctype;
  if (isempty (ctype))
    ctype = zeros (6, 1);
    ## Get enumerated cell types. Beware as they start at 0 not 1
    ctype( 1) = (__java_get__ ("com.extentech.ExtenXLS.CellHandle", "TYPE_STRING"));  ## 0
    ctype( 2) = (__java_get__ ("com.extentech.ExtenXLS.CellHandle", "TYPE_FP"));      ## 1
    ctype( 3) = (__java_get__ ("com.extentech.ExtenXLS.CellHandle", "TYPE_INT"));     ## 2
    ctype( 4) = (__java_get__ ("com.extentech.ExtenXLS.CellHandle", "TYPE_FORMULA")); ## 3
    ctype( 5) = (__java_get__ ("com.extentech.ExtenXLS.CellHandle", "TYPE_BOOLEAN")); ## 4
    ctype( 6) = (__java_get__ ("com.extentech.ExtenXLS.CellHandle", "TYPE_DOUBLE"));  ## 5
  endif
  
  rstatus = 0; 
  wb = xls.workbook;

  ## Check if requested worksheet exists in the file & if so, get pointer
  nr_of_sheets = wb.getNumWorkSheets ();
  if (isnumeric (wsh))
    if (wsh > nr_of_sheets)
      error (sprintf ...
          ("xls2oct: worksheet ## %d bigger than nr. of sheets (%d) in file %s",...
          wsh, nr_of_sheets, xls.filename)); 
    endif
    sh = wb.getWorkSheet (wsh - 1);               ## OXS sheet count 0-based
  else
    try
      sh = wb.getWorkSheet (wsh);
    catch
      error (sprintf ("xls2oct: worksheet %s not found in file %s", wsh, xls.filename));
    end_try_catch
  end

  if (isempty (cellrange))
    ## Get numeric sheet pointer (0-based)
    wsh = sh.getTabIndex ();
    ## Get data rectangle row & column numbers (1-based)
    [firstrow, lastrow, lcol, rcol] = getusedrange (xls, wsh+1);
    if (firstrow == 0 && lastrow == 0)
      ## Empty sheet
      rawarr = {};
      printf ("Worksheet '%s' contains no data\n", shnames {wsh});
      rstatus = 1;
      return;
    else
      nrows = lastrow - firstrow + 1;
      ncols = rcol - lcol + 1;
    endif
  else
    ## Translate range to row & column numbers (1-based)
    [dummy, nrows, ncols, firstrow, lcol] = parse_sp_range (cellrange);
    ## Check for too large requested range against actually present range
    lastrow = min (firstrow + nrows - 1, sh.getLastRow () + 1);
    nrows = min (nrows, sh.getLastRow () - firstrow + 1);
    ncols = min (ncols, sh.getLastCol () - lcol + 1);
    rcol = lcol + ncols - 1;
  endif

  ## Read contents into rawarr
  rawarr = cell (nrows, ncols);                   ## create placeholder
  for jj = lcol:rcol
    for ii = firstrow:lastrow
      try
        scell = sh.getCell (ii-1, jj-1);
        sctype = scell.getCellType ();
        switch sctype
          case {ctype(2), ctype(3), ctype(6)}     ## Float / double
            rawarr{ii+1-firstrow, jj+1-lcol} = scell.getDoubleVal ();
          case ctype(4)                           ## Formula cell  
            if (spsh_opts.formulas_as_text)
              tmp = char (sh.getFormula (scell.getCellAddress));
              rawarr{ii+1-firstrow, jj+1-lcol} = tmp(index (tmp, ":=") + 1 : end);
            else
              ## FIXME - may still be a string; usually OpenXLS gets it right
              rawarr{ii+1-firstrow, jj+1-lcol} = scell.getVal ();
            endif
          case ctype(5)
            rawarr{ii+1-firstrow, jj+1-lcol} = scell.getVal () == 1;
          case ctype(1)
            rawarr{ii+1-firstrow, jj+1-lcol} = scell.getVal ();
          otherwise
            # rawarr{ii+1-firstrow, jj+1-lcol} = scell.getVal ();
        endswitch
      catch
        ## Empty or non-existing cell
      end_try_catch
    endfor
  endfor

  rstatus = 1;
  xls.limits = [lcol, rcol; firstrow, lastrow];
  
endfunction
