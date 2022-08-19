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

## -*- texinfo -*-
## @deftypefn {Function File} [@var{filetype}] = xlsfinfo (@var{filename} [, @var{reqintf}])
## @deftypefnx {Function File} [@var{filetype}, @var{sh_names}] = xlsfinfo (@var{filename} [, @var{reqintf}])
## @deftypefnx {Function File} [@var{filetype}, @var{sh_names}, @var{fformat}] = xlsfinfo (@var{filename} [, @var{reqintf}])
## @deftypefnx {Function File} [@var{filetype}, @var{sh_names}, @var{fformat}, @var{nmranges}] = xlsfinfo (@var{filename} [, @var{reqintf}])
## @deftypefnx {Function File} [@dots{}] = xlsfinfo (@dots{}, @var{verbose})
## Query a spreadsheet file for some info about its contents.
##
## Inputs:
## @itemize
## @var{filename} is the name, or relative or absolute filename, of a
## spreadsheet file.
##
## If multiple spreadsheet I/O interfaces have been installed,
## @var{reqintf} can be specified to request a specific interface.  If
## omitted xlsfinfo selects a suitable interface; see the help for xlsread
## for more information.
##
## If optional argument @var{verbose} (numerical or logical; always the
## last argument) is specified as logical 'true' or numerical 1, xlsfinfo
## echoes info about the spreadsheet I/O interface it uses.
## @end itemize
##
## Outputs:
## @itemize
## Return argument @var{filetype} returns a string containing a general
## description of the spreadsheet file type: "Microsoft Excel Spreadsheet"
## for Excel spreadsheets, "OpenOffice.org Calc spreadsheet" for .ods
## spreadsheets, "Gnumeric spreadsheet" for Gnumeric spreeadsheets, or
## @"" (empty string) for other or unrecognized spreadsheet formats.
##
## If @var{filename} is a recognized Excel, OpenOffice.org Calc or
## Gnumeric spreadsheet file, optional return argument @var{sh_names}
## contains an Nx2 list (cell array) of sheet names contained in
## @var{filename} and total used data ranges for each sheet, in the
## order (from left to right) in which they occur in the sheet stack.
##
## Optional return value @var{fformat} currently returns "xlWorkbookNormal"
## for .xls formats, "xlOpenXMLWorkbook" for .xlsx, "xlCSV" for .csv,
## "GnumericWorkbook" for .gnumeric, "ODSWorkbook" for .ods,
## "StarOfficeWorkbook" for .sxc, or @"" (empty) for other file formats.
##
## Optional return argument @var{nmranges} is a cell array containing all
## named data ranges in the file in the first column, the relevant sheet and
## the cell range in the second and third column and if appropriate the
## scope of the range in the fourth column. For named ranges defined for
## the entire workbook the fourth column entry is empty.
## Named ranges only work with the COM, POI, OXS and OCT interfaces, and
## with the UNO interface only properly for Excel files.
## @end itemize
##
## If no return arguments are specified the sheet names are echoed to the
## terminal screen plus for each sheet the actual occupied data range.
## The occupied cell range will have to be determined behind the scenes
## first; this can take some time for some of the Java based interfaces.
## Any Named ranges defined in the spreadsheet file will be listed on
## screen as well.
##
## For OOXML spreadsheets no external SW is required but full POI and/or
## UNO and/or COM support (see xlsopen) may work better or faster; to use
## those specify "poi", "uno" or "com" for @var{reqintf}.  For Excel '95
## files use "com" (windows only), "jxl", "oxs" or "uno".  Gnumeric and
## ODS files can be explored with the built-in OCT interface (no need to
## specify @var{reqintf} then) although again the COM, JOD, OTK or UNO
## interfaces may work faster, depending on a.o., the size of the file.
## Note that the JXL, OXS, OTK and JOD interfaces don't support Named
## ranges so when using these interfaces no information about Named ranges
## is returned.
##
## Examples:
##
## @example
##   exist = xlsfinfo ('test4.xls');
##   (Just checks if file test4.xls is a readable Excel file)
## @end example
##
## @example
##   [exist, names] = xlsfinfo ('test4.ods');
##   (Checks if file test4.ods is a readable LibreOffice Calc file and
##    returns a list of sheet names and types)
## @end example
##
## @seealso {oct2xls, xlsread, xls2oct, xlswrite}
##
## @end deftypefn

## Author: Philip Nienhuis <prnienhuis at users.sourceforge.net>
## Created: 2009-10-27

function [ filetype, sh_names, fformat, nmranges ] = xlsfinfo (filename, ...
                                                               varargin)

  persistent str2; str2 = "                                 "; ## 33 spaces
  persistent lstr2; lstr2 = length (str2);

  verbose = false;
  reqintf = "";

  if (nargin < 1 || nargin > 3)
    print_usage ();
  elseif (nargin == 2)
    if (isnumeric (varargin{1}) || islogical (varargin{1}))
      verbose = varargin{1};
    else
      reqintf = varargin{1};
    endif
  elseif (nargin == 3)
    reqintf = varargin{1};
    verbose = varargin{2};
  endif

  xls = xlsopen (filename, 0, reqintf, verbose);
  if (isempty (xls))
    return;
  endif

  toscreen = nargout < 1;

  ## If any valid spreadsheet pointer struct has been returned, it must be a
  ## valid spreadsheet. Find out what format
  [~, ~, ext] = fileparts (xls.filename);
  switch ext
    case {"xls", "xlsx", "xlsm", ".xlsb", ".xls", ".xlsx", ".xlsm", ".xlsb"}
      filetype = "Microsoft Excel Spreadsheet";
    case {"ods", ".ods"}
      filetype = "OpenOffice.org Calc spreadsheet";
    case {"gnumeric", ".gnumeric"}
      filetype = "Gnumeric spreadsheet";
    otherwise
  endswitch
  fformat = "";

  if (strcmp (xls.xtype, "COM"))
    [sh_names] = __COM_spsh_info__ (xls);

  elseif (strcmp (xls.xtype, "JOD"))
    [sh_names] = __JOD_spsh_info__ (xls);

  elseif (strcmp (xls.xtype, "JXL"))
    [sh_names] = __JXL_spsh_info__ (xls);

  elseif (strcmp (xls.xtype, "OCT"))
    [sh_names] = __OCT_spsh_info__ (xls);

  elseif (strcmp (xls.xtype, "OXS"))
    [sh_names] = __OXS_spsh_info__ (xls);

  elseif (strcmp (xls.xtype, "OTK"))
    [sh_names] = __OTK_spsh_info__ (xls);

  elseif (strcmp (xls.xtype, "POI"))
    [sh_names] = __POI_spsh_info__ (xls);

  elseif (strcmp (xls.xtype, "UNO"))
    [sh_names] = __UNO_spsh_info__ (xls);

##elseif   <New spreadsheet interfaces below>
  else
    error (sprintf ("xlsfinfo: unknown spreadsheet I/O interface - %s.\n", ...
                    xls.xtype));

  endif

  sh_cnt = size (sh_names, 1);
  if (toscreen)
    ## Echo sheet names to screen
    for ii=1:sh_cnt
      str1 = sprintf ("%3d: %s", ii, sh_names{ii, 1});
      if (index (sh_names{ii, 2}, ":"))
        str3 = [ "(Used range ~ " sh_names{ii, 2} ")" ];
      else
        str3 = sh_names{ii, 2};
      endif
      printf ("%s%s%s\n", str1, str2(1:lstr2-length (sh_names{ii, 1})), str3);
    endfor
    ## Echo named ranges
    nmranges = getnmranges (xls);
    snmr = size (nmranges, 1);
    if(snmr > 0)
      ## Find max length of entries
      nmrl = min (35, max ([cellfun("length", nmranges(:, 1)); 10]));
      shtl = min (31, max ([cellfun("length", nmranges(:, 2)); 6]));
      rnml = max ([cellfun("length", nmranges(:, 3)); 5]);
      frmt = sprintf ("%%%ds  %%%ds  %%%ds\n" , nmrl, shtl, rnml);
      printf (["\n" frmt], "Range name", "Sheet", "Range");
      printf (frmt, "----------", "-----", "-----" );
      for ii=1:size (nmranges, 1)
        printf (frmt, nmranges(ii, 1:3){:});
      endfor
    endif
  else
    if (sh_cnt > 0 && nargout > 2)
      if (strcmpi (xls.filename(end-2:end), "xls"))
        fformat = "xlWorkbookNormal";
        ## FIXME could nowadays be "xlExcel8"
      elseif (strcmpi (xls.filename(end-2:end), "csv"))
        fformat = "xlCSV";        ## Works only with COM
      elseif (strcmpi (xls.filename(end-3:end-1), "xls"))
        fformat = "xlOpenXMLWorkbook";
      elseif (strfind (lower (xls.filename(end-3:end)), 'htm'))
        fformat = "xlHtml";       ##  Works only with COM
      elseif  (strfind (lower (xls.filename(end-2:end)), 'ods'))
        fformat = "ODSWorkbook"
      elseif  (strfind (lower (xls.filename(end-7:end)), 'gnumeric'))
        fformat = "GnumericWorkbook"
      else
        fformat = "";
      endif
    endif
    if (nargout > 3)
      ## Echo named ranges
      nmranges = getnmranges (xls);
    endif
  endif

  xls = xlsclose (xls);

endfunction
