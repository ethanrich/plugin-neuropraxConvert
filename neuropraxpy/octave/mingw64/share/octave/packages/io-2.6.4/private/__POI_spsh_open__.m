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

## __POI_xlsopen__ - Internal function for opening an xls(x) file using Java/Apache POI

## Author: Philip Nienhuis <prnienhuis@users.sf.net>
## Created: 2012-10-07

function [ xls, xlssupport, lastintf ] = __POI_spsh_open__ (xls, xwrite, filename, xlssupport, ftype, xlsinterfaces)

  ## Trick to detect Java file handle
  xlsin = 1.5;
  ## Get handle to workbook
  try
    if (xwrite > 2)
      if (ftype == 1)
        wb = javaObject ("org.apache.poi.hssf.usermodel.HSSFWorkbook");
      elseif (ftype == 2)
        wb = javaObject ("org.apache.poi.xssf.usermodel.XSSFWorkbook");
      endif
      xls.app = "new_POI";
    else
      xlsin = javaObject ("java.io.FileInputStream", filename);
      poiv = javaObject ("org.apache.poi.Version").getVersion();
      wb = javaMethod ("create", ...
                       "org.apache.poi.ss.usermodel.WorkbookFactory",...
                       xlsin);
      xls.app = xlsin;
    endif
    xls.xtype = "POI";
    xls.workbook = wb;
    xls.filename = filename;
    xlssupport += 2;
    lastintf = "POI";
  catch
    if (! strcmp (class (xlsin), "double"))
      xlsin.close ();
    endif
    if (ftype == 1 && (xlsinterfaces.JXL || xlsinterfaces.UNO))
      printf ...
      (["Couldn't open file %s using POI;\n" ...
        "trying Excel'95 format with JXL or UNO...\n"], filename);
    endif
	  lastintf = "";
  end_try_catch

endfunction
