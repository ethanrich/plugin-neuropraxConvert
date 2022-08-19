## Copyright (C) 2014-2021 Philip Nienhuis
## 
## This program is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or
## (at your option) any later version.
## 
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
## 
## You should have received a copy of the GNU General Public License
## along with this program.  If not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*- 
## @deftypefn {Function File} {@var{retval} =} __OCT_oct2gnm__ (@var{input1}, @var{input2})
## Internal OF io package function.
##
## @seealso{}
## @end deftypefn

## Author: Philip Nienhuis <prnienhuis at users . sf .net>
## Created: 2014-04-20

function [xls, status] = __OCT_oct2gnm__ (obj, xls, wsh, crange, spsh_opts=0, obj_dims)

  ## A. Find out if we write to existing or new sheet
  new_sh = 0;
  if (isnumeric (wsh))
    if (wsh < 1)
      error ("oct2ods/xls: sheet number (%d) should be > 0\n", wsh);
    elseif (wsh > numel (xls.sheets.sh_names))
      ## New sheet
      ## FIXME check for existing/duplicate names
      xls.sheets.sh_names(wsh) = sprintf ("Sheet%d", wsh);
      new_sh = 1; 
      wsh = numel (xls.sheets.sh_names) + 1;
    endif
  elseif (ischar (wsh))
    idx = find (strcmp (wsh, xls.sheets.sh_names));
    if (isempty (idx))
      ## New sheet
      xls.sheets.sh_names(end+1) = wsh;
      new_sh = 1;
      idx = numel (xls.sheets.sh_names);
    endif
    wsh = idx;
  endif

  ## Check if we made a new file from template, add a new sheet, or add data to a sheet
  if (strcmpi (xls.sheets.sh_names{1}, " ") && numel (xls.sheets.sh_names) == 2 && new_sh)
    ## Completely new file. Clean up and copy a few things
    xls.sheets.sh_names(1) = [];
    wsh = 1;
    idx_s = xls.sheets.shtidx(1);
    idx_e = xls.sheets.shtidx(2) - 1;
    xls.changed = 2;
    lims = [obj_dims.tr, obj_dims.br; obj_dims.lc, obj_dims.rc];
    rawarr = obj;
  elseif (new_sh)
    ## New sheet. Provisionally update sheet info in file pointer struct
    wsh = numel (xls.sheets.sh_names);
    idx_s = xls.sheets.shtidx(wsh) ;               ## First position after last sheet
    idx_e = idx_s - 1;
    xls.changed = 1;
    lims = [obj_dims.tr, obj_dims.br; obj_dims.lc, obj_dims.rc];
    rawarr = obj;
  else
    ## Just write new data into an existing sheet
    idx_s = xls.sheets.shtidx(wsh);
    idx_e = xls.sheets.shtidx(wsh+1) - 1;
    ## Get all current data in sheet and current row/column limits
    [rawarr, xls]  = __OCT_gnm2oct__ (xls, wsh, "", struct ("formulas_as_text", 1));
    lims = xls.limits;
    ## C. Merge old and new data. Provisionally allow empty new data to wipe old data
    [rawarr, lims] = __OCT_merge_data__ (rawarr, lims, obj, obj_dims);
  endif

  ## C. Create a temporary file to hold the new sheet xml
  ## Open sheet file (new or old)
  tmpfil = tempname;
  fid = fopen (tmpfil, "w+");
  if (fid < 0)
    error ("oct2ods/xls: unable to write to tmp file %s\n", tmpfil);
  endif
  
  ## Write data to sheet
  status  = __OCT__oct2gnm_sh__ (fid, rawarr, xls.sheets.sh_names{wsh}, lims);

  ## E. Merge new/updated sheet into gnumeric file
  ## Read first chunk  until sht_idx<xx>
  fidc = fopen (xls.workbook, "r+");

  ## Read and concatenate just adapted/created sheet/table:table
  gnm_xml = fread (fidc, idx_s - 1, "char=>char")';

  ## F. Optionally update SheetName Index node
  if (new_sh)
    if (wsh == 1)
      ## New file, existing sheet. Find then (only) gnm:SheetName node
      [shtnmnode, ss, ee] = getxmlnode (gnm_xml, "gnm:SheetName");
      ipos = index (shtnmnode, "> </gnm:SheetName>");
      shtnmnode = [ shtnmnode(1:ipos) xls.sheets.sh_names{1} shtnmnode(ipos+2:end) ];
      ## Replace SheetName node
      gnm_xml = [ gnm_xml(1:ss-1) shtnmnode gnm_xml(ee+1:end) ];
    else
      ## Existing file, append new SheetName node to end of SheetName nodes list
      [shtidxnode, ss, ee] = getxmlnode (gnm_xml, "gnm:SheetNameIndex");
      sh_node = sprintf('><gnm:SheetName gnm:Cols="1024" gnm:Rows="65536">%s</gnm:SheetName>',
                         xls.sheets.sh_names{wsh});
      ## Add close tag to ease up next strrep
      sh_node = [ sh_node "</gnm:SheetNameIndex>" ];
      shtidxnode = strrep (shtidxnode, "</gnm:SheetNameIndex>", sh_node);
      ## Replace SheetNameIndex node
      gnm_xml = [ gnm_xml(1:ss-1) shtidxnode gnm_xml(ee+1:end) ];
    endif
  endif

  ## Rewind tmp sheet and read it behind gnm_xml
  fseek (fid, 0, "bof");
  sheet = fread (fid, Inf, "char=>char")';
  lsheet = length (sheet);
  ## Close & delete sheet file
  fclose (fid);
  delete (tmpfil);
  gnm_xml = [ gnm_xml  sheet] ;

  ## Read rest of gnumeric file, optionally delete overwritten sheet/table:table
  fseek (fidc, idx_e, 'bof');
  gnm_xml = [ gnm_xml  fread(fidc, Inf, "char=>char")' ];
  ## Write updated gnumeric file back to disk.
  fclose (fidc);
  fidc = fopen (xls.workbook, "w+"); 
  fprintf (fidc, "%s", gnm_xml);
  fclose (fidc);

  ## G. Update sheet pointers in ods/xls file pointer
  if (new_sh)
    xls.sheets.shtidx(wsh+1) = idx_s + lsheet;
    xls.changed = 2;
  else
    offset = lsheet - (idx_e - idx_s) - 1;
    xls.sheets.shtidx(wsh+1 : end) += offset;
  endif
  xls.changed = max (xls.changed, 1);

endfunction


function [ status ] = __OCT__oct2gnm_sh__ (fid, raw, wsh, lims)

  ## Write out the lot to requested sheet

  ## 1. Sheet open tags
  tag = '<gnm:Sheet DisplayFormulas="0" HideZero="0" HideGrid="0"';
  tag = [ tag ' HideColHeader="0" HideRowHeader="0" DisplayOutlines="1"' ];
  tag = [ tag ' OutlineSymbolsBelow="1" OutlineSymbolsRight="1"' ];
  tag = [ tag ' Visibility="GNM_SHEET_VISIBILITY_VISIBLE" GridColor="0:0:0">' ];
  fprintf (fid, "%s", tag);

  fprintf (fid, "<gnm:Name>%s</gnm:Name>", wsh);

  fprintf (fid, "<gnm:MaxCol>%d</gnm:MaxCol><gnm:MaxRow>%d</gnm:MaxRow>", ...
           lims(1, 2) - 1, lims(2, 2) - 1);

  fprintf (fid, "<gnm:Cells>");

  ## 2. Spreadsheet cells
  for ii=1:size (raw, 1)
    # lims(##, ##):lims(##, ##)
    ## Row # in gnumeric = 0-based
    irow = lims(1, 1) - 2 + ii;
    for jj=1:size (raw, 2)
      # lims(##, ##):lims(##, ##)
      ## Column # in gnumeric = 0-based
      icol = lims(2, 1) - 2 + jj;
      if (isempty (raw{ii, jj}) || ...
          (isnumeric (raw{ii, jj}) && ! isfinite (raw{ii, jj})))
        ## Do nothing

      elseif (islogical (raw{ii, jj}))
        ## BOOLEAN. Convert to acceptable format for gnumeric
        val = "FALSE";
        if (raw{ii, jj})
          val = "TRUE";
        endif
        fprintf (fid, '<gnm:Cell Row="%d" Col="%d" ValueType="20">%s</gnm:Cell>', ...
                 irow, icol, val)

      elseif (isnumeric (raw{ii, jj}))
        ## Any numeric value; gnumeric only has FLOAT type
        fprintf (fid, '<gnm:Cell Row="%d" Col="%d" ValueType="40">%0.15g</gnm:Cell>', ...
                 irow, icol, raw{ii, jj});

      elseif (ischar (raw{ii, jj}))
        ## STRING
        fprintf (fid, '<gnm:Cell Row="%d" Col="%d" ValueType="60">%s</gnm:Cell>', ...
                 irow, icol, raw{ii, jj});

      else
        ## Do nothing, just skip

      endif
    endfor
  endfor

  ## 3. Closing tag
  fprintf (fid, "</gnm:Cells></gnm:Sheet>");

  status = 1;

endfunction
