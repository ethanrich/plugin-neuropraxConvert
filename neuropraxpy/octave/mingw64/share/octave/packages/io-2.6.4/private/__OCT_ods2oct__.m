## Copyright (C) 2013-2021 Philip Nienhuis
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

## -*- texinfo -*- 
## @deftypefn {Function File} [@var{raw}, @var{ods}, @var{rstatus} = __OCT_ods2oct__ (@var{ods}, @var{wsh}, @var{range}, @var{opts})
## Internal function for reading data from an ods worksheet
##
## @seealso{}
## @end deftypefn

## Author: Philip Nienhuis <prnienhuis at users.sf.net>
## Created: 2013-09-08

function [ rawarr, ods, rstatus] = __OCT_ods2oct__ (ods, wsh, cellrange="", spsh_opts)

  rstatus = 0;

  ## Check if requested worksheet exists in the file & if so, get sheet
  if (isnumeric (wsh))
    if (wsh > numel (ods.sheets.sh_names) || wsh < 1)
      error ("xls2/odsoct: sheet number (%d) out of range (1 - %d)", wsh, numel (ods.sheets.sh_names));
    endif
  elseif (ischar (wsh))
    idx = find (strcmp (wsh, ods.sheets.sh_names));
    if (isempty (idx))
      error ("xls/ods2oct: sheet '%s' not found in file %s", wsh, ods.filename);
    endif
    wsh = idx;
  endif
  
  ## Get requested sheet from info in ods struct pointer. Open file
  fid = fopen (sprintf ("%s/content.xml", ods.workbook), "r");;
  ## Go to start of requested sheet
  fseek (fid, ods.sheets.shtidx(wsh), "bof");
  ## Compute size of requested chunk
  nchars = ods.sheets.shtidx(wsh+1) - ods.sheets.shtidx(wsh);
  ## Get the sheet
  sheet = fread (fid, nchars, "char=>char").';
  fclose (fid);

  ## Add xml to struct pointer to avoid __OCT_getusedrange__ to read it again
  ods.xml = sheet;

  ## Check ranges
  [ firstrow, lastrow, lcol, rcol ] = getusedrange (ods, wsh);

  ## Clear xml from file ptr struct
  ods.xml = [];
  ods = rmfield (ods, "xml");

  if (isempty (cellrange))
    if (firstrow == 0 && lastrow == 0)
      ## Empty sheet
      rawarr = {};
      ## printf ("Worksheet '%s' contains no data\n", ods.sheets.sh_names{wsh});
      lims = [];
      rstatus = 1;
      return;
    else
      nrows = lastrow - firstrow + 1;
      ncols = rcol - lcol + 1;
    endif
  else
    [topleft, nrows, ncols, firstrow, lcol] = parse_sp_range (cellrange);
    ## Check if requested range exists
    if (firstrow > lastrow || lcol > rcol)
      ## Out of occupied range
      warning ("xls/ods2oct: requested range outside occupied range\n");
      rawarr = {};
      ods.limits = [];
      return
    endif
    lastrow = min (lastrow, firstrow + nrows - 1);
    rcol = min (rcol, lcol + ncols - 1);
  endif

  ## FIXME Preallocation + data reading can be more efficient
  ## Preallocate output array; provisionally assign max nr. of rows & columns
  rawarr = cell (lastrow, rcol);

  ## Get data
  re = 1;                       # Start table-row search at first char of sheet
  irow = 0;                     # Counts "real" spreadsheet rows
  trow = " ";
  ## Row index ii below does not necessarily match table-rows!
  while (irow < lastrow && (! isempty (trow)))
    ## Get next table-row
    [trow, ~, re] = getxmlnode (sheet, "table:table-row", re);

    if (! isempty (trow))
      ## Check if table-row has any data
      datrow = index (trow, " office:");
      ## Check repeat status and update row counter
      reprow = str2double (getxmlattv (trow, "table:number-rows-repeated"));
      if (isfinite (reprow))
        reprow = min (reprow, lastrow - irow) - 1;
      endif
      irow++;

      ## Only process table-row contents if it has any data. Skip upper
      ## empty table-rows (that's why we need an OR), only start counting
      ## with the first table-row containing data
      if (datrow || irow)

        ce = 0;                 # Char pointer on table-row
        tcell = " ";
        icol = 0;               # Count spreadsheet column
        while (icol < rcol && (! isempty (tcell)))
          ## Get next table-cell. First see if it is covered (merged)
          [tcell1, ~, ce1] = getxmlnode (trow, "table:covered-table-cell", ce+1);
          [tcell2, ~, ce2] = getxmlnode (trow, "table:table-cell", ce+1);

          if (ce1 > 0 && ce2 > 0)
            ## Both  table-cell and a table-covered-cell are present
            if (ce1 < ce2)
              ## table-covered cell before table-cell. Set pointer at its end
              ce = ce1;
              tcell = tcell1;
              ## Signal code below that content parsing must be skipped
              ce2 = 0;
            else
              ## table-cell before table-covered cell. Pointer to end of table-cell
              ce = ce2;
              tcell = tcell2;
            endif
          else
            if (ce1 > 0)
              ## Only table-covered-cell found
              ce = ce1;
              tcell = tcell1;
            else
              ## Only table-cell found
              ce = ce2;
              tcell = tcell2;
            endif
          endif
          ## First check its repeat status and update column counter
          repcol = str2double (getxmlattv (tcell, "table:number-columns-repeated"));
          if (isfinite (repcol))
            repcol = min (repcol, rcol - icol);
          endif
          icol++;

          if (! isempty (tcell))
            ## Try to get value type
            ctype = "";
            if (ce2)
              ctype = getxmlattv (tcell, "office:value-type");
              if (isempty (ctype) && spsh_opts.formulas_as_text)
                ## Work around OTK bug (doesn't write office:value-type for formulas)
                if (! isempty (strfind (tcell, "formula")))
                  ctype = "cformula";
                endif
              endif
            endif
            if (! isempty (ctype))
              if (spsh_opts.formulas_as_text)
                form = getxmlattv (tcell, "table:formula");
                if (! isempty (form))
                  ctype = "cformula";
                endif
              endif
              ## Get value
              ctvalue = getxmlnode (tcell, "text:p")(9:end-9);
              ## Put proper translation into rawarr
              switch ctype
                case "cformula"
                  ## Pimp ranges in formulas
                  form = regexprep (form, '\[\.(\w+)\]', '$1');
                  form = regexprep (form, '\[\.(\w+):', '$1:');
                  form = regexprep (form, ':\.(\w+)\]', ':$1');
                  rawarr{irow, icol} = form;
                  ## Remove of=
                  rawarr{irow, icol} = form(4:end);
                case {"float", "percentage", "currency"}
                  ## Simply get value from main cell tag. In case of error
                  ## values (#VALUE, #DIV/0, etc.) the cell type is string.
                  rawarr{irow, icol} = str2double (getxmlattv (tcell, "office:value"));
                case "string"
                  rawarr{irow, icol} = strjoin (cell2mat (regexp (tcell, ...
                                       '<text:p>?(.*?)</text:p>', "tokens")), "\n");;
                case "date"
                  cvalue = getxmlattv (tcell, "office:date-value");
                  try
                    cvalue = strsplit (cvalue, "T");
                    ## Date part
                    cv = regexp (cvalue{1}, '[0-9]*', "match");
                    yr = str2double (cv(1));
                    mo = str2double (cv(2));
                    dy = str2double (cv(3));
                    rawarr{irow, icol} = datenum(yr, mo, dy);
                    ## Time part, if any (that's what the try-catch is for)
                    cv = regexp (cvalue{2}, '[0-9]*', "match");
                    hh = str2double (cv(1));
                    mm = str2double (cv(2));
                    ss = str2double (cv(3));
                    rawarr{irow, icol} += datenum (0, 0, 0, hh, mm, ss);
                  catch
                  end_try_catch
                case "boolean"
                  rawarr{irow, icol} = strcmpi (ctvalue, "true");
                case "time"
                  ## Time values usually have hours first, then minutes, optionally seconds
                  hh = mi = ss = 0;
                  ctvalue = regexp (getxmlattv (tcell, "office:time-value"), '[0-9]*', "match");
                  ## try-catch to catch missing seconds
                  try
                    hh = str2double (ctvalue(1));
                    mi = str2double (ctvalue(2));
                    ss = str2double (ctvalue(3));
                  catch
                  end_try_catch
                  rawarr{irow, icol} = datenum (0, 0, 0, hh, mi, ss);
                otherwise
                  ## Do nothing
              endswitch
            endif

            ## Copy cell contents for repeated columns & bump column counter
            if (isfinite (repcol) && icol < rcol)
              rawarr(irow, icol+1:icol+repcol-1) = rawarr(irow, icol);
              icol += repcol - 1;
              repcol = "";
            endif
          endif
        endwhile

        ## Copy row contents to repeated rows & bump row counter
        if (isfinite (reprow) && irow < lastrow)
          for kk=irow+1:min (nrows, irow+reprow-1)
            rawarr(kk, :) = rawarr(irow, :);
          endfor
          irow += reprow;
          reprow = "";
        endif
      endif
    endif

  endwhile

  ## If required strip leftmost empty columns/topmost empty rows
  if (lcol > 1)
    rawarr(:, 1:ncols) = rawarr(:, lcol:rcol);
    rawarr(:, ncols+1:end) = [];
  endif
  if (firstrow > 1)
    rawarr(1:nrows, :) = rawarr(firstrow:lastrow, :);
    rawarr(nrows+1:end, :) = [];
  endif
  ## Keep track of data rectangle limits
  ods.limits = [lcol, rcol; firstrow, lastrow];
  rstatus = 1;

endfunction
