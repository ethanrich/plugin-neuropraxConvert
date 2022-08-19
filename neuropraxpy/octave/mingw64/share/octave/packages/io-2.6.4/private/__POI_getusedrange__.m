## Copyright (C) 2010-2021 Philip Nienhuis
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

## __POI_getusedrange__ - get range of occupied data cells from Excel using java/POI

## Author: Philip Nienhuis <prnienhuis at users.sf.net>
## Created: 2010-03-20

function [ trow, brow, lcol, rcol ] = __POI_getusedrange__ (xls, ii)

  persistent cblnk poiv4;
  try
    cblnk = __java_get__ ("org.apache.poi.ss.usermodel.Cell", "CELL_TYPE_BLANK");
    poiv4 = false;
  catch
    cblnk = __java_get__ ("org.apache.poi.ss.usermodel.CellType", "BLANK").ordinal ();
    poiv4 = true;
  end_try_catch

  sh = xls.workbook.getSheetAt (ii-1);          ## Java POI starts counting at 0 

  trow = sh.getFirstRowNum ();                  ## 0-based
  brow = sh.getLastRowNum ();                   ## 0-based
  ## Get column range
  lcol = 1048577;                               ## OOXML (xlsx) max. + 1
  rcol = 0;
  botrow = brow;
  for jj=trow:brow
    irow = sh.getRow (jj);
    if (! isempty (irow))
      scol = irow.getFirstCellNum;
      ## If getFirstCellNum < 0, row is empty
      if (scol >= 0)
        lcol = min (lcol, scol);
        ecol = irow.getLastCellNum - 1;
        rcol = max (rcol, ecol);
        ## Keep track of lowermost non-empty row as getLastRowNum() is unreliable
        cst = irow.getCell(scol).getCellType ();
        cet = irow.getCell(ecol).getCellType ();
        if (poiv4)
          cst = cst.ordinal ();
          cet = cet.ordinal ();
        endif
        if  (! (cst == cblnk && cet == cblnk))
          botrow = jj;
        endif
      endif
    endif
  endfor
  if (lcol > 1048576)
    ## Empty sheet
    trow = 0; brow = 0; lcol = 0; rcol = 0;
  else
    ## 1-based retvals
    brow = min (brow, botrow) + 1; 
    ++trow; 
    ++lcol; 
    ++rcol;
  endif

endfunction
