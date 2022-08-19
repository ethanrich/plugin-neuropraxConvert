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

## __COM_xlsopen.m__ - Internal function for opening an xls(x) file using COM/ActiveX

## Author: Philip Nienhuis <prnienhuis@users.sf.net>
## Created: 2012-10-07

function [ xls, xlssupport, lastintf ] = __COM_spsh_open__ (xls, xwrite, filename, xlssupport)

    app = actxserver ("Excel.Application");
    try      ## Because Excel itself can still crash on file formats etc.
      app.Application.DisplayAlerts = 0;
      filename = make_absolute_filename (filename);
      if (xwrite < 2)
        ## Open workbook
        wb = app.Workbooks.Open (filename);
      elseif (xwrite > 2)
        ## Create a new workbook
        wb = app.Workbooks.Add ();
        ## Uncommenting the below statement can be useful in multi-user environments.
        ## Be sure to uncomment correspondig stanza in xlsclose to avoid zombie Excels
        ## wb.SaveAs (make_absolute_filename (strsplit (filename, filesep){end}));
      endif
      xls.app = app;
      xls.xtype = "COM";
      xls.workbook = wb;
      xls.filename = filename;
      xlssupport += 1;
      lastintf = "COM";
    catch
      warning ( sprintf ("xlsopen: ActiveX error trying to open or create file %s\n",...
                         filename));
      app.Application.DisplayAlerts = 1;
      app.Quit ();
      delete (app);
	  lastintf = "";
    end_try_catch

endfunction
