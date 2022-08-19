## Copyright (C) 2013-2020 Markus Bergholz
## Parts Copyright (C) 2014-2021 Philip Nienhuis
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

## -*- texinfo -*-
## xlsxwrite function pure written in octave - no dependencies are needed.
## tested with MS Excel 2010, Gnumeric, LibreOffice 4.x
##
## usage:
## __OCT_oct2xlsx__(filename, matrix, wsh, range, spsh_opts)
## @end deftypefn

## Author: Markus Bergholz <markuman at gmail.com>
## Amended by Philip Nienhuis <prnienhuis at users.sf.net>
## 2013/11/08 - Initial Release

function [xls, rstatus] = __OCT_oct2xlsx__ (arrdat, xls, wsh, crange="", spsh_opts, obj_dims)

  ## Analyze worksheet parameter & determine if new sheet is required
  new_sh = 0;

  if (xls.changed == 3)
    ## Pristine spreadsheet file
    new_sh = 1;
    ## Replace default sheet name
    if (ischar (wsh))
      wsh_string = xls.sheets.sh_names(1) = wsh;
    elseif (isnumeric (wsh))
      wsh_string = xls.sheets.sh_names(1) = sprintf ("Sheet%d", wsh);
    endif
    wsh_number = 1;

  elseif (ischar (wsh))
    if (length (wsh) > 31)
      error ("oct2xls: worksheet name longer than 31 characters is not supported by Excel\n");
    endif
    wsh_number = find (strcmp (wsh, xls.sheets.sh_names));
    if (isempty (wsh_number))
      ## Worksheet not in stack; create a new sheet
      new_sh = 1;
      xls.sheets.sh_names(end+1) = wsh;
      wsh_number = numel (xls.sheets.sh_names);
      ## Update shId & get proper new worksheet number that fits in shId category
      wid = find (xls.sheets.type == 1);
      xls.sheets.type = [ xls.sheets.type 1 ];
      xls.sheets.shId = [xls.sheets.shId (max (xls.sheets.shId(wid)) + 1) ]; ## -1?
    endif
    wsh_string = wsh;
    wsh = wsh_number;
    wsh_number = xls.sheets.shId(wsh);

  elseif (isnumeric (wsh))
    if (wsh > numel (xls.sheets.sh_names))
      ## New worksheet
      new_sh = 1;
      ## Default sheet name
      wsh_string = sprintf ("Sheet%d", wsh);
      ## Name may already be in use... append underscores
      while (! isempty (find (strcmp (wsh_string, xls.sheets.sh_names))) && ...
             length (wsh_string <= 31))
        wsh_string = strrep (wsh_string, "Sheet", "Sheet_");
      endwhile
      if (length (wsh_string) > 31)
        error ("oct2xls: cannot add worksheet with a unique name\n");
      endif
      ## Make wsh internally now the newest/next higher sheet number, not any no.
      wsh = numel (xls.sheets.sh_names) + 1;
      xls.sheets.sh_names(end+1) = wsh_string;
      ## Update shId & get proper new worksheet number that fits in shId category
      wid = find (xls.sheets.type == 1);
      xls.sheets.type = [ xls.sheets.type 1 ];
      xls.sheets.shId = [xls.sheets.shId (max (xls.sheets.shId(wid)) + 1) ];
    else
      if (xls.sheets.type(wsh) != 1)
        warning ("oct2xls: sheet %d is not a worksheet\n", wsh);
        return
      endif
    endif
    ## Make sure wsh_number refers to a worksheet, not any sheet
    wsh_number = xls.sheets.shId(wsh);
  endif

  if (new_sh)
    rawarr = {};
    lims = [];
  else
    ## Get all data in sheet and row/column limits. If wsh is numeric,
    ## __OCT_xlsx2oct__ will turn it into a valid worksheet no.
    [rawarr, xls]  = __OCT_xlsx2oct__ (xls, wsh, "", spsh_opts);
    lims = xls.limits;
  endif
  
  ## Merge old and new data. Provisionally allow empty new data to wipe old data
  [rawarr, lims, onr, onc] = __OCT_merge_data__ (rawarr, lims, arrdat, obj_dims);

  ## What needs to be done:
  ## - Find out worksheet number (easy, wsh_number). Relates 1:1 to rId
  ## - Write data to <temp>/xl/worksheets/sheet<wsh_number>.xml
  ##   * For each string, check (persistent var) if sharedStrings.xml exists
  ##     > If not, create it.
  ##   * For each string check if it is in <temp>/sharedStrings.xml
  ##     > if YES, put pointer in new worksheet
  ##     > if NO, add node in sharedStrings.xml and pointer in new worksheet
  ## - If needed (new file) update <temp>/workbook.xml w. sheet name & a sheetId
  ##   higher than any existing sheetId
  ## - Update workbook.xml.rels

  ## Write data to worksheet file. If status > 1, new sharedStrings file entries are required
  [xls, status]  = __OCT_oct2xlsx_sh__ (xls, wsh_number, rawarr, lims, onc, onr, spsh_opts);

  ## Update worksheet bookkeeping for new sheets only
  if (new_sh)
    ## Add worksheet entry in several xml files

    ## === Read xl/_rels/workbook.xml.rels ===
    rid = fopen ([xls.workbook filesep "xl" filesep "_rels" filesep "workbook.xml.rels"], "r+");
    rxml = fread (rid, Inf, "char=>char").';
    fclose (rid);
    ## Get rId's ((worksheet number in stack, needed in [Content_Types].xml)
    rId = str2double (cell2mat (regexp (rxml, 'Id="rId(\d+)"', "tokens")));

    ## === Read xl/workbook.xml ===
    wid = fopen ([xls.workbook filesep "xl" filesep "workbook.xml"], "r+");
    wxml = fread (wid, Inf, "char=>char").';
    fclose (wid);
    ## Get sheetId's
    [sheets, is, ie] = getxmlnode (wxml, "sheets");
    sheetids = str2double (cell2mat (regexp (sheets, ' sheetId="(\d+?)"', "tokens")));
    ## new rId must be nr of sheets + 1. rId's (>nwrId) are bumped +1 below
    nwrId = numel (sheetids) + 1;
    xls.sheets.rid(nwrId) = nwrId;
    if (xls.changed == 3)
      ## New file from template. No new sheet, just update Sheet1 name
      shnum = 1;
      sheets = strrep (sheets, 'name="Sheet1"', ['name="' wsh_string '"']);
    else
      ## Add a new sheet entry
      shnum = max (sheetids) + 1;
      wshtag = sprintf ('<sheet name="%s" sheetId="%d" r:id="rId%d" />', ...
                        wsh_string, shnum, nwrId);
      sheets = regexprep (sheets, '/>\s*</sheets>', ["/>" wshtag "</sheets>"]);
      xls.sheets.sheetid(end+1) = shnum;
    endif
    ## Re(/over-)write workbook.xml; start at sheets node
    wid = fopen ([xls.workbook filesep "xl" filesep "workbook.xml"], "w+");
    fprintf (wid, "%s", wxml(1:is-1));
    fprintf (wid, "%s", sheets);
    fprintf (wid, "%s", wxml(ie+1:end));
    fclose (wid);
    ## === End of xl/workbook.xml & wxml ===

    ## Write xl/_rels/workbook.xml.rels & [Content_Types].xml
    ## Only needed for new sheets in existing files
    if (xls.changed != 3)
      ## Find highest worksheet nr in nodes, add one and shift all the rest up
      is = iel = 0;
      for ii=1:numel (rId)
        ## Get next Relationship node. Worksheets usually come first
        [relshp, is, ie] = getxmlnode (rxml, "Relationship", is+1);
        if (rId(ii) >= nwrId)
          ## rId needs to be bumped
          relshp = regexprep (relshp, 'Id="rId(\d+)"', ...
                              ['Id="rId' sprintf("%d", rId(ii)+1) '"']);
          ## Insert new node back into rxml
          rxml = [rxml(1:is-1) relshp rxml(ie+1:end)];
        else
          ## Remember end pos of last worksheet node
          iel = ie;
        endif
        if (rId(ii) == nwrId)
          ## Insert new node with nwrId and higher *work*sheet no.
          entry = sprintf ('<Relationship Id="rId%d" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet" Target="worksheets/sheet%d.xml"/>', nwrId, wsh_number);
        endif
      endfor
      rxml = [rxml(1:iel) entry rxml(iel+1:end)];
      ## Rewrite xl/_rels/workbook.xml.rels
      rid = fopen ([xls.workbook filesep "xl" filesep "_rels" filesep "workbook.xml.rels"], "w");
      fprintf (rid, "%s", rxml);
      fclose (rid);
      ## === End of xl/_rels/worksbook.xml.rels & rxml ===

      ## === [Content_Types].xml. ===
      ## Merely insert a worksheet #n entry (#n = nwrId)
      tid = fopen ([xls.workbook filesep "[Content_Types].xml"], "r+");
      txml = fread (tid, Inf, "char=>char").';
      fclose (tid);
      ## Prepare new partname node. Its stack pos = nwrId
      partname = ['<Override PartName="/xl/worksheets/sheet%d.xml" ' ...
                  'ContentType="application/vnd.openxmlformats-' ...
                  'officedocument.spreadsheetml.worksheet+xml"/>' ];
      partname = sprintf (partname, wsh_number);
      ## Find last worksheet node & insert new node
      srchstr = 'worksheet+xml"/>';
      ipos = strfind (txml, srchstr)(end) + length (srchstr);
      tid = fopen ([xls.workbook filesep "[Content_Types].xml"], "w");
      fprintf (tid, "%s", txml(1:ipos-1));
      fprintf (tid, partname);
      fprintf (tid, txml(ipos:end));
      fclose (tid);
    endif
    ## === End of [Content_Types].xml & txml ===

    ## === <docProps/app.xml> ===
    aid = fopen ([xls.workbook filesep "docProps" filesep "app.xml"], "r+");
    axml = fread (aid, Inf, "char=>char").';
    fclose (aid);
    wshnode = sprintf ('<vt:lpstr>%s</vt:lpstr>', wsh_string);
    if (xls.changed == 3)
      [vt, is, ie] = getxmlnode (axml, "TitlesOfParts");
      ## Just replace Sheet1 entry by new name
      vt = strrep (vt, '>Sheet1<', ['>' wsh_string '<']);
    else
      ## 1. Update HeadingPairs node
      [vt1, is, ie] = getxmlnode (axml, "HeadingPairs");
      ## Bump number of entries
      nshts = str2double (getxmlnode (vt1, "vt:i4", [], 1)) + 1;
      vt1 = regexprep (vt1, '<vt:i4>(\d+)</vt:i4>', ["<vt:i4>" sprintf("%d", nshts) "</vt:i4>"]);
      ## 2. Update TitlesOfParts node
      [vt2, ~, ie] = getxmlnode (axml, "TitlesOfParts", ie);
      ## Bump number of entries
      nshts = str2double (getxmlattv (vt2, "size")) + 1;
      vt2 = regexprep (vt2, 'size="(\d+)"', ['size="' sprintf("%d", nshts) '"']);
      ## Add new worksheet entry
      vt2 = regexprep (vt2, "</vt:lpstr>\s*</vt:vector>", ["</vt:lpstr>" wshnode "</vt:vector>"]);
      vt = [vt1 vt2];
    endif
    ## Re(/over-)write apps.xml
    aid = fopen ([xls.workbook filesep "docProps" filesep "app.xml"], "w+");
    fprintf (aid, "%s", axml(1:is-1));
    fprintf (aid, "%s", vt);
    fprintf (aid, "%s", axml(ie+1:end));
    fclose (aid);
  ## === End of docProps/app.xml & axml ===

  else
    ## when writing data to existing worksheets, MS-Excel might complain about
    ## xl/calcChain.xml. As MS-Excel will regenerate it and only MS-Excel ever
    ## uses it, the easiest thing is to just delete the file from the archive.
    try
      unlink ([xls.workbook filesep "xl" filesep "calcChain.xml"]);
    catch
    end_try_catch
  
  endif

  ## If needed update sharedStrings entries xml descriptor files
  if (status > 1)
    ##  workbook_rels.xml
    rid = fopen ([xls.workbook filesep "xl" filesep "_rels" filesep "workbook.xml.rels"], "r+");
    rxml = fread (rid, Inf, "char=>char").';
    fclose (rid);
    if (isempty (strfind (rxml, "sharedStrings")))
      ## Add sharedStrings.xml entry. First find unique rId
      rId = str2double (cell2mat (regexp (rxml, 'Id="rId(\d+)"', "tokens")));
      nwrId = sort (rId)(end) + 1;
      entry = sprintf ('<Relationship Id="rId%d" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/sharedStrings" Target="sharedStrings.xml"/>', nwrId);
      rxml = regexprep (rxml, '/>\s*</Relationships>', ["/>" entry "</Relationships>"]);
      rid = fopen ([xls.workbook filesep "xl" filesep "_rels" filesep "workbook.xml.rels"], "w");
      fprintf (rid, "%s", rxml);
      fclose (rid);
    endif
  endif

  if (status > 1)
    ## Check [Content_Types].xml for SharedStrings entry
    tid = fopen ([xls.workbook filesep "[Content_Types].xml"], "r+");
    txml = fread (tid, Inf, "char=>char").';
    fclose (tid);
    if (isempty (strfind (txml, "sharedStrings")))
      ## Add sharedStrings.xml entry after styles.xml node. First find that one
      [~, ~, ipos] = regexp (txml, '(?:styles\+xml)(?:.+)(><Over)', 'once');
      ipos = ipos(1);
      txml = [txml(1:ipos) '<Override PartName="/xl/sharedStrings.xml" '  ...
                           'ContentType="application/vnd.openxmlformats-' ...
                           'officedocument.spreadsheetml.sharedStrings+xml" />' ...
                           txml(ipos+1:end)];
      tid = fopen ([xls.workbook filesep "[Content_Types].xml"], "w");
      fprintf (tid, "%s", txml);
      fclose (tid);
    endif
  endif

  ## === /docProps/core.xml (user/modifier info & date/time) ===
  cid = fopen ([xls.workbook filesep "docProps" filesep "core.xml"], "r+");
  cxml = fread (cid, Inf, "char=>char").';
  fclose (cid);
  cxml = regexprep (cxml, 'dBy>(\w+)</cp:lastM', 'dBy>GNU Octave</cp:lastM');
  modtime = int32 (datevec (now));
  modtime = sprintf ("%4d-%2d-%2dT%2d:%2d:%2dZ", modtime(1), modtime(2), modtime(3), ...
                                                 modtime(4), modtime(5), modtime(6));
  modtime = strrep (modtime, " ", "0");
  [modf, ia, ib] = getxmlnode (cxml, "dcterms:created", [], 1);
  cxml = [cxml(1:ia-1) strrep(cxml(ia:ib), modf, modtime) cxml(ib+1:end)];
  [modf, ia, ib] = getxmlnode (cxml, "dcterms:modified", [], 1);
  ## Possible LO bug (see Octave bug #45915) - "dcterms:modified" node may lack
  if (isempty (modf))
    ia = ib = index (cxml, "<cp:revision>");
    cxml = [ cxml(1:ia-1) '<dcterms:modified xsi:type="dcterms:W3CDTF">2015-09-10T19:53:40Z</dcterms:modified><' cxml(ib+1:end) ];
    [modf, ia, ib] = getxmlnode (cxml, "dcterms:modified", [], 1);
  endif
  cxml = [cxml(1:ia-1) strrep(cxml(ia:ib), modf, modtime) cxml(ib+1:end)];
  cid = fopen ([xls.workbook filesep "docProps" filesep "core.xml"], "w+");
  fprintf (cid, "%s", cxml);
  fclose (cid);
  ## === End of docProps/core.xml & cxml ===

  ## Update status
  xls.changed = max (xls.changed-1, 1);
  rstatus = 1;

endfunction


function [ xls, rstatus ] = __OCT_oct2xlsx_sh__ (xls, wsh_number, arrdat, lims, onc, onr, spsh_opts)

  ## Open sheet file (new or old), will be overwritten
  fid = fopen ([xls.workbook filesep "xl" filesep "worksheets" filesep ...
                sprintf("sheet%d.xml", wsh_number)], "r+");
  if (fid < 0)
    ## Apparently a new sheet. Fill in default xml contents
    xml = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>';
    xml = [ xml "\n" ];
    xml = [ xml '<worksheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main"' ];
    xml = [ xml ' xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"'];
    xml = [ xml ' xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"' ];
    xml = [ xml ' mc:Ignorable="x14ac" xmlns:x14ac="http://schemas.microsoft.com/office/spreadsheetml/2009/9/ac">' ];
    xml = [ xml '<dimension ref="A1"/><sheetViews><sheetView workbookViewId="0"/></sheetViews>' ];
    xml = [ xml '<sheetFormatPr baseColWidth="10" defaultRowHeight="15" x14ac:dyDescent="0.25"/>' ];
    xml = [ xml '<sheetData/>'];
    xml = [ xml '<pageMargins left="0.7" right="0.7" top="0.8" bottom="0.8" header="0.3" footer="0.3"/>'];
    xml = [ xml '</worksheet>' ];
  else
    ## Read complete contents
    xml = fread (fid, Inf, "char=>char").';
    fclose (fid);
  endif

  ## Update "dimension" (=range) node
  [dimnode, is1, ie1] = getxmlnode (xml, "dimension");
  ## Compute new limits
  rng = sprintf ("%s:%s", calccelladdress (lims(2, 1), lims(1, 1)), ...
                          calccelladdress (lims(2, 2), lims(1, 2)));

  ## Open sheet file (new or old) in reset mode, write first part of worksheet
  fid = fopen ([xls.workbook filesep "xl" filesep "worksheets" filesep ...
                sprintf("sheet%d.xml", wsh_number)], "w+");
  fprintf (fid, "%s", xml(1:is1-1));
  ## Write updated dimension node
  fprintf (fid, '<dimension ref="%s"/>', rng);

  ## Get Sheetdata node
  [shtdata, is2, ie2] = getxmlnode (xml, "sheetData");
  ## Write second block of xml until start of sheetData
  fprintf (fid, "%s", [xml(ie1+1:is2-1) "<sheetData>"]);

  ## Explore data types in arrdat
  typearr = spsh_prstype (arrdat, onr, onc, [1:5], spsh_opts);

  if (all (typearr(:) == 1))        ## Numeric
    for r=1:rows (arrdat)
      fprintf (fid, '<row r="%d" spans="%d:%d" x14ac:dyDescent="0.25">', ...
               r+lims(2, 1)-1, ...
               lims(1, 1), lims(1, 2));
      for c = 1:columns (arrdat)
        if (0 == isnan (arrdat{r, c}))
          fprintf (fid, sprintf ('<c r="%s%d" t="n"><v>%0.15g</v></c>', ... 
                   num2col (c+lims(1, 1)-1), r+lims(2, 1)-1, arrdat{r, c}));
        endif
      endfor
      fprintf (fid, '</row>');
    endfor

  else
    ## Heterogeneous array. Write cell nodes depending on content
    i_tatt = [];
    strings = {};
    str_cnt = uniq_str_cnt = 0;
    ## Check if there are any strings
    if (any (typearr(:) == 3))
      ## Yep. Read sharedStrings.xml
      try
        sid = fopen (sprintf ("%s/xl/sharedStrings.xml", xls.workbook), "r+");
        if (sid > 0)
          ## File exists => there are already some strings in the sheet
          shstr = fread (sid, "char=>char").';
          fclose (sid);
          ## Extract string values. May be much more than present in current sheet.
          ## A two-step procedure is required to preserve empty strings ("<t/>")
          strings = cell2mat (regexp (shstr, '<si[^>]*>(.*?)</si>', "tokens"));
          strings = regexprep (strings, '(^<t>|^<t/>|</t>$)', "");
          ## Take care of strings with <t attributes
          i_tatt = find (! cellfun (@isempty, regexp (strings, '^<t xml:.*>', "tokens")));
          ## Watch out for a rare corner case: just one empty string... (avoid [])
          if (isempty (strings))
            strings = {""};
          endif
          sst = getxmlnode (shstr, "sst", 1);
          uniq_str_cnt = str2double (getxmlattv (sst, "uniqueCount"));
          clear sst;
          ## Make shstr a numeric value
          shstr = 1;
        else
          ## File didn't exist yet
          shstr = 0;
        endif
      catch
        ## No sharedStrings.xml; implies no "fixed" strings (computed strings can still be there)
        strings = {};
        str_cnt = uniq_str_cnt = 0;
      end_try_catch
    endif
    ## Process data row by row
    for ii=1:rows (arrdat)
      ## Row node opening tag
      fprintf (fid, '<row r="%d" spans="%d:%d">', ii+lims(2, 1)-1, lims(1, 1), lims(1, 2));
      for jj=1:columns (arrdat)
        ## Ignore empty values
        if (! isempty (arrdat{ii, jj}))
          ## Init required attributes. Note leading space
          addr = sprintf (' r="%s"', calccelladdress (ii+lims(2, 1)-1, jj+lims(1, 1)-1));
          ## Init optional atttributes
          stag = ttag = form = "";     ## t: e = error, b = boolean, s/str = string
                                       ##    n = numeric
          switch typearr(ii, jj)
            case 1                    ## Numeric
              ## t tag ("type") is omitted for numeric data ???
              ttag = ' t="n"';
              val = ["<v>" (sprintf ("%0.15g", arrdat{ii, jj})) "</v>"];
            case 2                    ## Boolean
              ttag = ' t="b"';
              if (arrdat{ii, jj})
                val = ["<v>1</v>"];
              else
                val = ["<v>0</v>"];
              endif
            case 3                    ## String
                ttag = ' t="s"';
                ## FIXME s value provisionally set to 0
                sptr = find (strcmp (arrdat{ii, jj}, strings));
                if (isempty (sptr))
                  ## Add new string
                  strings = [strings arrdat{ii, jj}];
                  ++uniq_str_cnt;
                  ## New pointer into sharedStrings (0-based)
                  sptr = uniq_str_cnt;
                endif
                ## Val must be pointer (0-based) into sharedStrings.xml
                val = sprintf ("<v>%d</v>", sptr - 1);
                ++str_cnt;
            case 4                    ## Formula
              form = sprintf ("<f>%s</f>", arrdat{ii, jj}(2:end));
              #val = "<v>?</v>";
              val = " ";
            otherwise                 ## (includes "case 5"
              ## Empty value. Clear address
              addr = '';
          endswitch
          ## Append node to file, include tags
          if (! isempty (addr))
            fprintf (fid, '<c%s%s%s>', addr, stag, ttag);
            if (! isempty (val))
              fprintf (fid, "%s%s", form, val);
            endif
            fprintf (fid, "</c>");
          endif
        endif
      endfor
      fprintf (fid, '</row>');
    endfor
  endif

  ## Closing tag
  fprintf (fid, "</sheetData>");
  ## Append rest of original xml to file and close it
  fprintf (fid, "%s", xml(ie2+1:end));
  fclose (fid);

  rstatus = 1;

  ## Rewrite sharedStrings.xml, if required
  if (any (typearr(:) == 3) && ! isempty (strings))
    ## Apparently something to write
    if (uniq_str_cnt == 1 && isempty (strings{1}))
      ## Avoid writing sharedStrings file for just one empty string entry
      return
    endif
    ## (Re-)write xl/sharedStrings.xml
    sid = fopen (sprintf ("%s/xl/sharedStrings.xml", xls.workbook), "w+");
    fprintf (sid, '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>\n');
    fprintf (sid, '<sst xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main" count="%d" uniqueCount="%d">', ...
             str_cnt, uniq_str_cnt);
    for ii=1:uniq_str_cnt
      if  (ismember (ii, i_tatt))
        ## Invoke original <t attribute, still in string
        fprintf (sid, "<si>%s</t></si>", strings{ii});
      else
        fprintf (sid, "<si><t>%s</t></si>", strings{ii});
      endif
    endfor
    fprintf (sid, "</sst>");
    fclose (sid);
    ## Check if new sharedStrings file entries are required
    if (isnumeric (shstr) && (! shstr))
      rstatus = 2;
      return;
    endif
  endif

  ## Return

endfunction
