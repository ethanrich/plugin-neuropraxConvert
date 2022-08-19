## Copyright (C) 2012-2021 Philip Nienhuis <prnienhuis@users.sf.net>
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

## __UNO_xlsopen__ - Internal function for opening a spreadsheet file using Java / OOo/LO UNO

## Author: Philip Nienhuis <prnienhuis@users.sf.net>
## Created: 2012-10-07

function [ xls, xlssupport, lastintf ] = __UNO_spsh_open__ (xls, xwrite, filename, xlssupport)

    ## First, the file name must be transformed into a URL
    if (! isempty (strfind (filename, "file:///")) || ...
        ! isempty (strfind (filename, "http://" ))  || ...
        ! isempty (strfind (filename, "ftp://"  ))   || ...
        ! isempty (strfind (filename, "www://"  )))
      ## Seems in proper shape for OOo (at first sight)
    else
      ## Transform into URL form. 
      ## FIXME on Windows, make_absolute_filename() doesn't work across
      ##       drive(-letters) so until it is (ever) fixed we'll fall back on
      ##       canonicalize_file_name() there.
      if (ispc)
        fname = canonicalize_file_name (filename);
        if (isempty (fname))
          ## File doesn't exist yet? try make_absolute_filename()
          fname = make_absolute_filename (filename);
        endif
      else
        fname = make_absolute_filename (filename);
      endif
      ## On Windows, change backslash file separator into forward slash
      if (strcmp (filesep, "\\"))
        tmp = strsplit (fname, filesep);
        flen = numel (tmp);
        tmp(2:2:2*flen) = tmp;
        tmp(1:2:2*flen) = '/';
        fname = [ tmp{:} ];
      endif
      filename = [ "file://" fname ];
    endif
    try
      xContext = javaMethod ("bootstrap", "com.sun.star.comp.helper.Bootstrap");
      xMCF = xContext.getServiceManager ();
      oDesktop = xMCF.createInstanceWithContext ("com.sun.star.frame.Desktop", ...
                                                 xContext);
      ## Workaround for <UNOruntime>.queryInterface():
      unotmp = javaObject ("com.sun.star.uno.Type", ...
                          "com.sun.star.frame.XComponentLoader");
      aLoader = oDesktop.queryInterface (unotmp);
      ## Some trickery as Octave Java cannot create initialized arrays
      lProps = javaArray ("com.sun.star.beans.PropertyValue", 2);
      ## Set file type property
      [ftype, filtnam] = __get_ftype__ (filename);
      if (isempty (filtnam))
        filtnam = "calc8";
      endif
      lProp = javaObject ...
        ("com.sun.star.beans.PropertyValue", "FilterName", 0, filtnam, []);
      lProps(1) = lProp;
      ## Set hidden property
      lProp = javaObject ("com.sun.star.beans.PropertyValue", "Hidden", 0, true, []);
      lProps(2) = lProp;
      flags = 0;
      if (xwrite > 2)
        xComp = aLoader.loadComponentFromURL ("private:factory/scalc", ...
                                              "_blank", flags, lProps);
      else
        xComp = aLoader.loadComponentFromURL (filename, "_blank", flags, lProps);
      endif
      ## Workaround for <UNOruntime>.queryInterface():
      unotmp = javaObject ("com.sun.star.uno.Type", ...
                          "com.sun.star.sheet.XSpreadsheetDocument");
      xSpdoc = xComp.queryInterface (unotmp);
      ## save in ods struct:
      xls.xtype = "UNO";
      xls.workbook = xSpdoc;    ## Needed to be able to close soffice in odsclose()
      xls.filename = filename;
      xls.app.xComp = xComp;    ## Needed to be able to close soffice in odsclose()
      xls.app.aLoader = aLoader;## Needed to be able to close soffice in odsclose()
      xls.odfvsn = "UNO";
      xlssupport += 16;
      lastintf = "UNO";
    catch
      ## Check if we have a 32 vs. 64 bit clash
      printf ("\nOops, Octave hit an error.\n");
      ## Newer Octave-4.1.0+ has ENABLE_64, older Octave has USE_64_BIT_IDX_T
	  [~, maxsize] = computer ();
      amd64y = maxsize > 2^31 - 1;
      if (amd64y || ! isempty (strfind (lower (computer ("arch")), "x86_64")))
        printf ("Maybe you have 32-bit Libre/OpenOffice installed?\n");
        printf ("64-bit Octave requires 64-bit L.O. / OOo.\n\n");
      elseif (! isempty (strfind (lower (computer ("arch")), "i686")))
        printf ("Maybe you have 64-bit Libre/OpenOffice installed?\n");
        printf ("32-bit Octave requires 32-bit L.O. / OOo.\n\n");
      endif
  	  lastintf = "";
      error ("xlsopen: couldn't open file %s using UNO\n", filename);
    end_try_catch

endfunction
