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

## __OXS_xlsopen__ - internal function for opening an xls file using Java / OpenXLS

## Author: Philip Nienhuis <prnienhuis at users.sf.net>
## Created: 2012-10-07

function [ xls, xlssupport, lastintf ] = __OXS_spsh_open__ (xls, xwrite, filename, xlssupport, ftype)

  if (ftype != 1 && ftype != 2)
    error ("xlsopen: the OXS interface only supports .xls (Excel'97-2003) files")
  endif
  ## Trick to detect Java file handle existence
  xlsin = 1.5;
  try
    if (xwrite > 2)
      if (ftype == 1)
        ## Create BIFF 8 file (.xls)
        wb = javaObject ("com.extentech.ExtenXLS.WorkBookHandle", false);
      else
        ## Create OOXML file (.xlsx)
        wb = javaObject ("com.extentech.ExtenXLS.WorkBookHandle", true);
      endif
      ## This new workbook has 3 empty sheets - get rid of the last two.
      ## Renaming, if needed, of Sheet1 is handled in __OXS_oct2spsh__.m
      for ii=2:wb.getNumWorkSheets
        ## Remarkable = sheet index = 0-based!
        wb.getWorkSheet (1).remove;
      endfor
      ## Workbook now has only one sheet ("Sheet1"). Rename it
      wb.getWorkSheet(0).setSheetName (")_]_}_ Dummy sheet made by Octave_{_[_(");
    else
      xlsin = javaObject ("java.io.FileInputStream", filename);
      wb = javaObject ("com.extentech.ExtenXLS.WorkBookHandle", xlsin);
      xlsin.close ();
    endif
    xls.xtype = "OXS";
    xls.app = "void - OpenXLS";
    xls.workbook = wb;
    xls.filename = filename;
    xlssupport += 8;
    lastintf = "OXS";
  catch
    if (! strcmp (class (xlsin), "double"))
      xlsin.close ();
    endif
    printf ("Unsupported file format for OpenXLS - %s\n");
	  lastintf = "";
  end_try_catch

endfunction
