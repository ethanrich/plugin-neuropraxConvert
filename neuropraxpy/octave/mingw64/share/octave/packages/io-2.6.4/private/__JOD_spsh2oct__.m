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

## __JOD_spsh2oct__ - get data out of an ODS spreadsheet into octave using jOpenDocument.
## Watch out, no error checks, and spreadsheet formula error results
## are conveyed as 0 (zero).
##
## Author: Philip Nienhuis <prnienhuis@users.sf.net>
## Created: 2009-12-13

function [ rawarr, ods, rstatus] = __JOD_spsh2oct__ (ods, wsh, crange, spsh_opts)

  persistent months;
  months = {"JAN", "FEB", "MAR", "APR", "MAY", "JUN", ...
            "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"};
  persistent octv = compare_versions (version, "4.1.0", ">=");

  rstatus = 0;
  ## Check jOpenDocument version
  sh = ods.workbook.getSheet (0);
  cl = sh.getCellAt (0, 0);
  if (ods.odfvsn >= 3)
    ## 1.2b3+ has public getValueType ()
    persistent ctype;
    if (isempty (ctype))
      BOOLEAN    = char (__java_get__ ("org.jopendocument.dom.ODValueType", "BOOLEAN"));
      CURRENCY   = char (__java_get__ ("org.jopendocument.dom.ODValueType", "CURRENCY"));
      DATE       = char (__java_get__ ("org.jopendocument.dom.ODValueType", "DATE"));
      FLOAT      = char (__java_get__ ("org.jopendocument.dom.ODValueType", "FLOAT"));
      PERCENTAGE = char (__java_get__ ("org.jopendocument.dom.ODValueType", "PERCENTAGE"));
      STRING     = char (__java_get__ ("org.jopendocument.dom.ODValueType", "STRING"));
      TIME       = char (__java_get__ ("org.jopendocument.dom.ODValueType", "TIME"));
    endif
  endif

  ## Sheet INDEX starts at 0
  if (isnumeric (wsh));
    --wsh; 
  endif
  ## Check if sheet exists. If wsh = numeric, nonexistent sheets throw errors.
  try
    sh = ods.workbook.getSheet (wsh);
  catch
    error ("xls/ods2oct: illegal sheet number (%d) requested for file %s\n", ...
           wsh+1, ods.filename);
  end_try_catch
  ## If wsh = string, nonexistent sheets yield empty results
  if (isempty (sh))
    error ("xls/ods2oct: no sheet called '%s' present in file %s\n", wsh, ...
           ods.filename);
  endif

  ## Either parse (given cell range) or prepare (unknown range) help variables 
  if (isempty (crange))
    if (ods.odfvsn < 3)
      error ("xls/ods2oct: no empty read range allowed in jOpenDocument version 1.2b2")
    else
      if (isnumeric (wsh)); wsh = wsh + 1; endif
      [ trow, brow, lcol, rcol ] = getusedrange (ods, wsh);
      nrows = brow - trow + 1;                ## Number of rows to be read
      ncols = rcol - lcol + 1;                ## Number of columns to be read
    endif
  else
    [dummy, nrows, ncols, trow, lcol] = parse_sp_range (crange);
    ## Check ODS column limits
    if (lcol > 1024 || trow > 65536) 
      error ("xls/ods2oct: invalid range; max 1024 columns & 65536 rows."); 
    endif
    ## Truncate range silently if needed
    rcol = min (lcol + ncols - 1, 1024);
    ncols = min (ncols, 1024 - lcol + 1);
    nrows = min (nrows, 65536 - trow + 1);
    brow = trow + nrows - 1;
  endif
  ## Create storage for data content
  rawarr = cell (nrows, ncols);

  if (ods.odfvsn >= 3) 
    ## Version 1.2b3+
    for ii=1:nrows
      for jj = 1:ncols
        try
          scell = sh.getCellAt (lcol+jj-2, trow+ii-2);
          if (spsh_opts.formulas_as_text)
            ## Check if it is a formula   =[.C5]+[.C7]
            frml = scell.getFormula ();
            if (! isempty (frml))
              ## For older jOpenDocument than 1.4.x
              frml = strrep (frml, "of:", "");
              rawarr{ii, jj} = regexprep (frml, '\[\.(\$?[A-Z]+\$?[0-9]+)\]', '$1');
              sctype = "FORMULA";
            else
              sctype = char (scell.getValueType ());
            endif
          else
            sctype = char (scell.getValueType ());
          endif
          switch sctype
            ## try both char value (Octave) and ODValuetype (jOpenDocument) for
            ## backward compatibility with older jOpenDocument versions
            case { FLOAT, " FLOAT", CURRENCY, "CURRENCY", PERCENTAGE, "PERCENTAGE" }
            ## Next IF reqd. as temporary workaround for bugs #48013 and #48591
            if (octv)
                rawarr{ii, jj} = scell.getValue ().doubleValue ();
              else
                rawarr{ii, jj} = scell.getValue ();
              endif
            case { BOOLEAN, "BOOLEAN" }
              rawarr {ii, jj} = scell.getValue () == 1;
            case { STRING, "STRING" }
              rawarr{ii, jj} = scell.getValue();
            case { DATE, "DATE" }
              tmp = strsplit (char (scell.getValue ()), " ");
              yy = str2num (tmp{6});
              mo = find (ismember (months, toupper (tmp{2})) == 1);
              dd = str2num (tmp{3});
              hh = str2num (tmp{4}(1:2));
              mi = str2num (tmp{4}(4:5));
              ss = str2num (tmp{4}(7:8));
              rawarr{ii, jj} = datenum (yy, mo, dd, hh, mi, ss);
            case { TIME, "TIME" }
              tmp = strsplit (char (scell.getValue ().getTime ()), " ");
              hh = str2num (tmp{4}(1:2)) /    24.0;
              mi = str2num (tmp{4}(4:5)) /  1440.0;
              ss = str2num (tmp{4}(7:8)) / 86600.0;
              rawarr {ii, jj} = hh + mi + ss;
            case "FORMULA"
              ## Do nothing, was catched above the switch stmt
            otherwise
              ## Workaround for sheets written by jOpenDocument (no value-type attrb):
              if (! isempty (scell.getValue) )
                ## FIXME Assume cell contains string if there's a text attr. 
                ## But it could be BOOLEAN too...
                rawarr{ii, jj} = scell.getValue();
                if (strfind (char (scell), "<text:"))
                  sctype = STRING;
                else
                  ## Numeric
                  ## Next IF reqd. as temporary workaround for bugs #48013 and #48591
                  if (octv)
                    rawarr{ii, jj} = scell.getValue ().doubleValue ();
                  else
                    rawarr{ii, jj} = scell.getValue ();
                  endif
                endif
              endif
              ## Nothing
          endswitch
        catch
          ## Probably a merged cell, just skip
        end_try_catch
      endfor
    endfor
  else  ## ods.odfvsn == 3
    ## 1.2b2
    for ii=1:nrows
      for jj = 1:ncols
        celladdress = calccelladdress (trow+ii-1, lcol+jj-1);
        try
          val = sh.getCellAt (celladdress).getValue ();
        catch
          ## No panic, probably a merged cell
          val = {};
        end_try_catch
        if (! isempty (val))
          if (ischar (val))
            ## Text string
            rawarr(ii, jj) = val;
          elseif (isnumeric (val))
            ## Boolean
            if (val)
              rawarr(ii, jj) = true;
            else;
              rawarr(ii, jj) = false;
            endif
          else
            try
              val = sh.getCellAt (celladdress).getValue ().doubleValue ();
              rawarr(ii, jj) = val;
            catch
              val = char (val);
              if (isempty (val))
                ## Probably empty Cell
              else
                ## Maybe date / time value. Dirty hack to get values:
                mo = find (strcmp (toupper (val(5:7)), months));
                dd = str2num (val(9:10));
                yy = str2num (val(25:end));
                hh = str2num (val(12:13));
                mm = str2num (val(15:16));
                ss = str2num (val(18:19));
                rawarr(ii, jj) = datenum (yy, mo, dd, hh, mm,ss);
              endif
            end_try_catch
          endif
        endif
      endfor
    endfor

  endif  

  ## Keep track of data rectangle limits
  ods.limits = [lcol, rcol; trow, brow];
  rstatus = 1;

endfunction
