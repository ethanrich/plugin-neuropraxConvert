## Copyright (C) 2012-2021 Philip Nienhuis
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

## __JXL_xlsopen__ - Internal function for opening an xls file using Java / JExcelAPI

## Author: Philip Nienhuis <prnienhuis@users.sf.net>
## Created: 2012-10-07

function [ xls, xlssupport, lastintf ] = __JXL_spsh_open__ (xls, xwrite, filename, xlssupport, ftype, xlsinterfaces)

  if (ftype != 1)
    error ("xlsopen: JXL can only read .xls (BIFF5 - Excel95 or BIFF8 - Excel97-2003) files")
  endif
  try
    xlsin = javaObject ("java.io.File", filename);
    if (xwrite > 2)
      ## Get handle to new xls-file
      wb = javaMethod ("createWorkbook", "jxl.Workbook", xlsin);
    else
      ## Open existing file
      wb = javaMethod ("getWorkbook", "jxl.Workbook", xlsin);
    endif
    xls.xtype = "JXL";
    xls.app = xlsin;
    xls.workbook = wb;
    xls.filename = filename;
    xlssupport += 4;
    lastintf = "JXL";
  catch
    if (xlsinterfaces.POI)
      ## Fall back to UNO only when that is stable (= closing soffice)
      printf ("... No luck with JXL, unsupported file format.\n", filename);
    endif
    lastintf = "";
  end_try_catch

endfunction
