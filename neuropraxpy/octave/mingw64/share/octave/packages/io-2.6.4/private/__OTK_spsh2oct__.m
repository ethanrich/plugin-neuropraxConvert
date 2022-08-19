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

## __OTK_spsh2oct__: internal function for reading odf files using odfdom-0.8.6+

## Author: Philip Nienhuis <prnienhuis@users.sf.net>
## Created: 2010-08-24. First workable version Aug 27, 2010

function [ rawarr, ods, rstatus ] = __OTK_spsh2oct__ (ods, wsh, crange, spsh_opts)

  rstatus = 0;

  ## Get contents and table stuff from the workbook
  odfcont = ods.workbook;  ## Use a local copy just to be sure. octave 
                           ## makes physical copies only when needed (?)
  
  ## Parse sheets ("tables") from ODS file
  sheets = ods.app.getTableList();
  nr_of_sheets = sheets.size ();

  ## Check user input & find sheet pointer (1-based)
  if (! isnumeric (wsh))
    try
      sh = ods.app.getTableByName (wsh);
      sh_err = isempty (sh);
    catch
      sh_err = 1;
    end_try_catch
    if (sh_err)
      error (sprintf ("oct2ods/xls: sheet %s not found in file %s\n", wsh, ods.filename)); 
    endif
  elseif (wsh > nr_of_sheets || wsh < 1)
    ## We already have a numeric sheet pointer. If it's not in range:
    error (sprintf ("oct2ods/xls: worksheet no. %d out of range (1 - %d)", wsh, nr_of_sheets));
  else
    sh = sheets.get (wsh - 1);
  endif

  ## Either parse (given cell range) or prepare (unknown range) help variables 
  if (isempty (crange))
    if (! isnumeric (wsh))
      ## Get sheet index
      jj = nr_of_sheets;
      while (jj-- >= 0)
        if (strcmp (wsh, sheets.get(jj).getTableName()) == 1)
          wsh = jj +1;
          jj = -1;
        endif
      endwhile
    endif
    [ trow, brow, lcol, rcol ] = getusedrange (ods, wsh);
    nrows = brow - trow + 1;  ## Number of rows to be read
    ncols = rcol - lcol + 1;  ## Number of columns to be read
  else
    [dummy, nrows, ncols, trow, lcol] = parse_sp_range (crange);
    ## Check ODS row/column limits
    if (lcol > 1024 || trow > 65536) 
      error ("ods2oct/xls: invalid range; max 1024 columns & 65536 rows\n"); 
    endif
    ## Truncate range silently if needed
    rcol = min (lcol + ncols - 1, 1024);
    ncols = min (ncols, 1024 - lcol + 1);
    nrows = min (nrows, 65536 - trow + 1);
    brow = trow + nrows - 1;
  endif

  ## Create storage for data content
  rawarr = cell (nrows, ncols);

  ## Read from worksheet row by row. Row numbers are 0-based
  for ii=trow:nrows+trow-1
    row = sh.getRowByIndex (ii-1);
    for jj=lcol:ncols+lcol-1;
      ocell = row.getCellByIndex (jj-1);
      if (! isempty (ocell))
        ## A little workaround as OTK doesn't recognize formula cells 
        if (spsh_opts.formulas_as_text && ! isempty (ocell.getFormula ()))
          otype = "formula";
        else
          otype = ocell.getValueType ();
        endif
        if (! isempty (otype))
          otype = deblank (tolower (otype));
          ## At last, read the data
          switch otype
            case  {"float", "currency", "percentage"}
              rawarr(ii-trow+1, jj-lcol+1) = ocell.getDoubleValue ();
            case "date"
              ## Dive into TableTable API
              tvalue = ocell.getOdfElement ().getOfficeDateValueAttribute ();
              ## Dates are returned as octave datenums, i.e. 0-0-0000 based
              yr = str2num (tvalue(1:4));
              mo = str2num (tvalue(6:7));
              dy = str2num (tvalue(9:10));
              if (index (tvalue, "T"))
                hh = str2num (tvalue(12:13));
                mm = str2num (tvalue(15:16));
                ss = str2num (tvalue(18:19));
                rawarr(ii-trow+1, jj-lcol+1) = datenum (yr, mo, dy, hh, mm, ss);
              else
                rawarr(ii-trow+1, jj-lcol+1) = datenum (yr, mo, dy);
              endif
            case "time"
              ## Dive into TableTable API
              tvalue = ocell.getOdfElement ().getOfficeTimeValueAttribute ();
              if (index (tvalue, "PT"))
                hh = str2num (tvalue(3:4));
                mm = str2num (tvalue(6:7));
                ss = str2num (tvalue(9:10));
                rawarr(ii-trow+1, jj-lcol+1) = datenum (0, 0, 0, hh, mm, ss);
              endif
            case "boolean"
              rawarr(ii-trow+1, jj-lcol+1) = ocell.getBooleanValue ();
            case "string"
              rawarr(ii-trow+1, jj-lcol+1) = ocell.getStringValue ();
            case "formula"
              form = ocell.getFormula ();
              ## If form doesn't start with "=", pimp ranges in formulas
              if (form(1) != "=")
                form = regexprep (form(4:end), '\[\.(\w+)\]', '$1');
                form = regexprep (form, '\[\.(\w+):', '$1:');
                form = regexprep (form, ':\.(\w+)\]', ':$1');
              endif
              rawarr(ii-trow+1, jj-lcol+1) = form;
            otherwise
              ## Nothing.
          endswitch
        endif
      endif
    endfor
  endfor

  ## Keep track of data rectangle limits
  ods.limits = [lcol, rcol; trow, brow];
  rstatus = 1;

endfunction
