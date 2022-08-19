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
## @deftypefn {Function File} {@var{ods}, @var{status} =} __OCT_oct2ods__ (@var{obj}, @var{ods}, @var{wsh}, @var{crange}, @var{spsh_opts})
## Internal function for writing to ODS sheet
##
## @seealso{}
## @end deftypefn

## Author: Philip Nienhuis <prnienhuis at users.sf.net>
## Created: 2014-01-18

function [ ods, status ] = __OCT_oct2ods__ (obj, ods, wsh, crange, spsh_opts=0, obj_dims)

  ## Find out if we write to existing or new sheet
  new_sh = 0;
  if (isnumeric (wsh))
    if (wsh < 1)
      error ("oct2xls/ods: sheet number (%d) should be > 0", wsh);
    elseif (ods.changed == 3)
      ## New sheet name in new file. Ignore sheet# other than to name sheet
      ods.sheets.sh_names(1) = sprintf ("Sheet%d" , wsh);
      wsh = 1;
    elseif (wsh > numel (ods.sheets.sh_names))
      ## New sheet
      ods.sheets.sh_names(wsh) = sprintf ("Sheet%d", wsh);
      new_sh = 1;
      wsh = numel (ods.sheets.sh_names) + 1;
    endif
  elseif (ischar (wsh))
    idx = find (strcmp (wsh, ods.sheets.sh_names));
    if (isempty (idx))
      if  (ods.changed == 3)
        ## New sheet name in new file
        ods.sheets.sh_names(1) = wsh;
        idx = 1;
      else
        ## New sheet
        ods.sheets.sh_names(end+1) = wsh;
        new_sh = 1;
        idx = numel (ods.sheets.sh_names);
      endif
    endif
    wsh = idx;
  endif

  ## Check if we made a new file from template
  if (ods.changed == 3)
    ods.changed = 2;
  endif

  if (new_sh)
    wsh = numel (ods.sheets.sh_names);
    idx_s = ods.sheets.shtidx(wsh) ;               ## First position after last sheet
    idx_e = idx_s - 1;
    rawarr = {};
    lims = [];
  elseif (ods.changed < 2)
    idx_s = ods.sheets.shtidx(wsh);
    idx_e = ods.sheets.shtidx(wsh+1) - 1;
    ## Get all data in sheet and row/column limits
    [rawarr, ods]  = __OCT_ods2oct__ (ods, wsh, "", struct ("formulas_as_text", 1));
    lims = ods.limits;
  elseif (ods.changed >= 2)
    idx_s = ods.sheets.shtidx(wsh);
    idx_e = ods.sheets.shtidx(wsh+1) - 1;
    rawarr = {};
    lims = [];
  endif

  ## Merge old and new data. Provisionally allow empty new data to wipe old data
  [rawarr, lims, onr, onc] = __OCT_merge_data__ (rawarr, lims, obj, obj_dims);

  ## D. Get default table/row/column styles
  ##    Open file content.xml
  ##    ... but first get original file size
  cxfs = dir ([ods.workbook filesep "content.xml"]);
  cxfs = cxfs.bytes;
  fids = fopen (sprintf ("%s/content.xml", ods.workbook), "r");
  ## Get first part, til first sheet
  contnt = fread (fids, ods.sheets.shtidx(1)-1, "char=>char").';
  fclose (fids);
  ## Get default styles stuff
  contnt = getxmlnode (contnt, "office:automatic-styles");
  is = 1;
  stylenode = " ";                                ## Any non-empty value
  ## Usual default style names
  styles = struct ("tbl", "ta1", "row", "ro1", "col", "co1");
  ## Get actual default styles
  while (! isempty (stylenode))
    [stylenode, ~, is] = getxmlnode (contnt, "style:style", is, 1);
    stylefam = getxmlattv (stylenode, "style:family");
    if     (strcmpi (stylefam, "table-column"))
      style.col = stylefam;
    elseif (strcmpi (stylefam, "table"))
      styles.tbl = stylefam;
    elseif (strcmpi (stylefam, "table-row"))
      styles.row = stylefam;
    endif
  endwhile

  ## E. Create a temporary file to hold the new sheet xml
  ## Open sheet file (new or old)
  tmpfil = tempname;
  fid = fopen (tmpfil, "w+");
  if (fid < 0)
    error ("oct2xls/ods: unable to write to file %s", tmpfil);
  endif

  ## Write data to sheet (actually table:table section in content.xml)
  status  = __OCT__oct2ods_sh__ (fid, rawarr, wsh, lims, onc, onr, ...
            ods.sheets.sh_names{wsh}, styles);

  ## F. Merge new/updated sheet into content.xml
  ## Read first chunk of content.xml until sht_idx<xx>
  fidc = fopen (sprintf ("%s/content.xml", ods.workbook), "r+");
  ## Go to start of requested sheet
  fseek (fidc, 0, "bof");

  ## Read and concatenate just adapted/created sheet/table:table
  content_xml = fread (fidc, idx_s - 1, "char=>char").';
  ## Rewind sheet and read it behind content_xml
  fseek (fid, 0, "bof");
  sheet = fread (fid, Inf, "char=>char").';
  lsheet = length (sheet);
  ## Close & delete sheet file
  fclose (fid);
  delete (tmpfil);
  content_xml = [ content_xml  sheet] ;

  ## Read rest of content.xml, optionally delete overwritten sheet/table:table
  fseek (fidc, idx_e, "bof");
  content_xml = [ content_xml  fread(fidc, Inf, "char=>char").' ];
  ## Write updated content.xml back to disk.
  fseek (fidc, 0, "bof");
  fprintf (fidc, "%s", content_xml);
  cxbs = ftell (fidc);
  if (cxbs < cxfs)
    ## New content.xml shorter than original ==> overwrite trailing junk
    fprintf (fidc, "%s", repmat (" ", 1, cxfs - cxbs));
  endif
  fclose (fidc);

  ## F. Update sheet pointers in ods file pointer
  if (new_sh)
    ods.sheets.shtidx(wsh+1) = idx_s + lsheet;
    ods.changed = 2;
  else
    offset = lsheet - (idx_e - idx_s) - 1;
    ods.sheets.shtidx(wsh+1 : end) += offset;
  endif
  ods.changed = max (ods.changed, 1);

  ## FIXME: Perhaps we'd need to update the metadata in meta.xml

endfunction


## ===========================================================================
function [ status ] = __OCT__oct2ods_sh__ (fid, rawarr, wsh, lims, onc, onr, tname, styles)

  ## Write out the lot to requested sheet

  ## 1. Sheet open tag
  fprintf (fid, '<table:table table:name="%s" table:style-name="%s">', tname, styles.tbl);

  ## 2. Default column styles. If required add columns repeated tag
  if (lims(1, 2) > 1)
    tncr = sprintf (' table:number-columns-repeated="%d"', lims(1, 2));
  else
    tncr = "";
  endif
  fprintf (fid, '<table:table-column table-style-name="%s"%s table:default-cell-style-name="Default" />', ...
          styles.col, tncr);

  ## 3. Spreadsheet rows
  ii = 1;
  while (ii <= onr)
    ## 3.1 Check for empty rows
    if (ii == 1)
      tnrr = lims(2, 1) - 1;
    else
      tnrr = 0;
    endif
    ## Check for consecutive empty rows. FIXME check for finite values as well
    while (ii <= onr && all (cellfun ("isempty", rawarr(ii, :))))
      ++tnrr;
      ++ii;
    endwhile
    if (tnrr > 1)
      tnrrt = sprintf (' table:number-rows-repeated="%d"', tnrr);
    else
      tnrrt = "";
    endif
    if (tnrr)
      ## Write empty row, optionally with row repeat tag
      if (lims (1, 2) > 1)
        ## Add number of empty columns repeat tag
        tcell = sprintf ('<table:table-cell table:number-columns-repeated="%d" />', ...
                        lims(1, 2));
      else
        tcell = "";
      endif
      fprintf (fid, '<table:table-row%s>%s</table:table-row>', tnrrt, tcell);
    endif
    if (ii <= onr)
      ## Write table row opening tag
      fprintf (fid, '<table:table-row table:style-name="%s">', styles.row);

      ## 3.2 Value cells
      jj = 1;
      while (jj <= onc)
        ## 3.2.1 Check if empty. Include empty columns left of rawarr
        if (jj == 1)
          tncr = lims(1, 1) - 1;
        else
          tncr = 0;
        endif
        ## Check consecutive empty cells & adapt ncr attr, write empty cells
        while (jj <= onc && (isempty (rawarr{ii, jj}) || ...
                             (isnumeric (rawarr{ii, jj}) && ! isfinite (rawarr{ii, jj}))))
          ++tncr;
          ++jj;
        endwhile
        if (tncr > 1)
          fprintf (fid, '<table:table-cell table:number-columns-repeated="%d" />', tncr);
        elseif (tncr == 1)
          fprintf (fid, "<table:table-cell />");
        endif
        ## Process non-empty data cells
        if (jj <= onc)
          ## 3.2.2 Non-empty cell. Determine value type. Set formula attr = empty
          of = "";
          switch class (rawarr{ii, jj})
            case {"double", "single"}
              if (isfinite (rawarr{ii, jj}))
                ovt = ' office:value-type="float"';
                val = sprintf ("%.4f", rawarr{ii, jj});
                txt = sprintf ("<text:p>%s</text:p>", val);
                ## Convert to attribute
                val = sprintf (' office:value="%0.15g"', rawarr{ii, jj});
              else
                ovt = "";
                val = "";
                txt = "";
              endif
            case {"int64", "int32", "int16", "int8", "uint64", "uint32", "uint16", "uint8"}
              ovt = ' office:value-type="integer"';
              val = strtrim (sprintf ("%d15", rawarr{ii, jj}));
              txt = sprintf ("<text:p>%s</text:p>", val);
              ## Convert to attribute
              val = sprintf (' office:value="%s"', val);
            case "logical"
              ovt = ' office:value-type="boolean"';
              val = "false";
              if (rawarr{ii, jj})
                val = "true";
              endif
              txt = sprintf ("<text:p>%s</text:p>", upper (val));
              ## Convert to attribute
              val = sprintf (' office:boolean-value="%s"', val);
            case "char"
              if (rawarr{ii, jj}(1) == "=")
                ## We guess a formula. Prepare formula attribute
                ovt = "";
                txt = "";
                val = "";
                of = sprintf (' table:formula="of:%s"', rawarr{ii, jj});
                ## FIXME We'd need to parse cell types in formula = may be formulas as well
                ## We cannot know, or parse, the resulting cell type, omit type info & text
              else
                ## Plain text
                ovt = ' office:value-type="string"';
                val = strsplit (rawarr{ii, jj}, "\n");
                txt = "";
                for kk=1:numel (val)
                  txt = [txt sprintf('<text:p>%s</text:p>', val{kk})];
                endfor
                ## Convert to attribute
                val = "";
              endif
            otherwise
              ## Unknown, illegal or otherwise unrecognized value
              ovt = "";
              val = "";
              txt = "";
          endswitch
          # write out table-cell w office-value-type / office:value
          fprintf (fid, "<table:table-cell%s%s%s>%s</table:table-cell>",
                   of, ovt, val, txt);
        endif
        ++jj;
      endwhile
      ## Write table row closing tag
      fprintf (fid, "</table:table-row>");
    endif
    ++ii;
  endwhile

  ## 4. Closing tag
  fprintf (fid, "</table:table>");

  status = 1;

endfunction
