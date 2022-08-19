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

## __COM_spsh_close__ - internal function: close a spreadsheet file using COM

## Author: Philip Nienhuis <prnienhuis@users.sf.net>
## Created: 2012-10-12

function [ xls ] = __COM_spsh_close__ (xls)

    ## If file has been changed, write it out to disk.
    ##
    ## Note: COM / VB supports other Excel file formats as FileFormatNum
    ## or xlFileFormat (see below switch stmt):
    ## (see Excel Help, VB reference, Enumerations, xlFileType)

    ## xls.changed = 0: no changes: just close;
    ##               1: existing file with changes: save, close.
    ##               2: new file with data added: save, close
    ##               3: new file, no added added (empty): close & delete on disk

    xls.app.Application.DisplayAlerts = 0;
    try
      if (xls.changed > 0 && xls.changed < 3)
        if (isfield (xls, "nfilename"))
          fname = xls.nfilename;
        else
          fname = xls.filename;
        endif
        fname = make_absolute_filename (strsplit (fname, filesep){end});
        if (xls.changed == 2)
          ## Probably a newly created, or renamed, Excel file. Get proper format
          [~, ~, ext] = fileparts (fname);
          ## https://docs.microsoft.com/en-us/office/vba/api/excel.xlfileformat
          switch ext
            case ".txt"
              ## Current Platform Text
              xlFileFormat = -4158;
            case {".wks"}
              ## Lotus 1-2-3 format (general) / MS Works
              xlFileFormat = 4;
            case {".wk1"}
              ## Lotus 1-2-3 format (general)
              xlFileFormat = 5;
            case ".csv"
              ## CSV (general, not platform-specific)
              xlFileFormat = 6;
            case ".dbf"
              ## dBase 3 format (xDbf3). Note; xlDBf2 = 7, xlDBF4 = 11
              xlFileFormat = 8;
            case ".dif"
              ## Data Interchange format
              xlFileFormat = 9;
            case ".wk3"
              ## Lotus-1-2-3
              xlFileFormat = 15;
            case ".wq1"
              ## Quattro Pro format
              xlFileFormat = 34;
            case ".prn"
              ## Printer Text
              xlFileFormat = 36;
            case ".wk4"
              ## Lotus 1-2-3
              xlFileFormat = 38;
            case {".htm", ".html"}
              ## HTML format
              xlFileFormat = 44;
            case {".mht", ".mhtml"}
              ## Web Archive
              xlFileFormat = 45;
            case ".xml"
              ## XML spreadsheet 2003
              xlFileFormat = 46;
            case "xlsb"
              ## Excel Binary Workbook
              xlFileFormat = 50;
            case ".xlsx"
              ## Open XML Workbook
              xlFileFormat = 51;
            case ".xlsm"
              ## Open XML Workbook Macro Enabled
              xlFileFormat = 52;
            case ".xls"
              ## Excel 97-2003 Workbook
              xlFileFormat = 56;
            case ".pdf"
              ## Printer Text
              xlFileFormat = 57;
            case ".ods"
              ## Open Document Format
              xlFileFormat = 60;
            otherwise
              ## Fall back to OpenXML .xlsx
              xlFileFormat = 51;
          endswitch
          xls.workbook.SaveAs (fname, xlFileFormat);
        elseif (xls.changed == 1)
          ## Just updated existing Excel file
          xls.workbook.Save ();
        endif
        xls.changed = 0;
        xls.workbook.Close (fname);
      endif
      xls.app.Quit ();
      delete (xls.workbook);  ## This statement actually closes the workbook
      delete (xls.app);       ## This statement actually closes down Excel
    catch
      xls.app.Application.DisplayAlerts = 1;
    end_try_catch

endfunction
