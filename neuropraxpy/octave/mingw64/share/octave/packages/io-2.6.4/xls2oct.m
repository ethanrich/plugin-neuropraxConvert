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
## @deftypefn {Function File} [ @var{rawarr}, @var{xls}, @var{rstatus} ] = xls2oct (@var{xls})
## @deftypefnx {Function File} [ @var{rawarr}, @var{xls}, @var{rstatus} ] = xls2oct (@var{xls}, @var{wsh})
## @deftypefnx {Function File} [ @var{rawarr}, @var{xls}, @var{rstatus} ] = xls2oct (@var{xls}, @var{wsh}, @var{range})
## @deftypefnx {Function File} [ @var{rawarr}, @var{xls}, @var{rstatus} ] = xls2oct (@var{xls}, @var{wsh}, @var{range}, @var{options})
## Read data contained within cell range @var{range} from worksheet @var{wsh}
## in a spreadsheet file pointed to in struct @var{xls}.
##
## Spreadsheet file pointer @var{xls} is supposed to have been created earlier
## by xlsopen in the same octave session.
##
## @var{wsh} is either numerical or text, in the latter case it is 
## case-sensitive; for .xlsx and .xls formats it may be max. 31 characters
## long.  Note that in case of a numerical @var{wsh} this number refers to
## the position in the total sheet stack, counted from the left in a
## spreadsheet program window.  The default is numerical 1, i.e. corresponding
## to the leftmost sheet tab in the spreadsheet file.
##
## @var{range} is expected to be either a regular spreadsheet range format,
## "" (empty string, indicating all data in a worksheet), or a "Named range"
## defined in the spreadsheet file.  In case of a Named range, the worksheet
## associated with that Named range will be used instead of the one specified
## in @var{wsh}.  If no range is specified or is specified as an empty string
## the occupied cell range will have to be determined behind the scenes first;
## this can take some time for the Java-based interfaces.  Be aware that in
## COM/ActiveX interface the inferred range can be outdated.  The Java-based
## interfaces are more reliable in this respect albeit much slower.
##
## Optional argument @var{options}, a structure, can be used to specify
## various read modes by setting option fields in the struct to true (1) or
## false (0).  Currently recognized option fields are:
##
## @table @asis
## @item "formulas_as_text"
## If set to TRUE or 1, spreadsheet formulas (if at all present) are read as
## formula strings rather than the evaluated formula result values (the latter
## if at all present in th spreadsheet).  The default value is 0 (FALSE).
##
## @item "strip_array"
## Set the value of this field set to TRUE or 1 to strip the returned
## output array @var{rawarr} from empty outer columns and rows. The
## spreadsheet cell rectangle limits from where the data actually
## came will be updated.  The default value is FALSE or 0 (no cropping).
## When using the COM interface, the output array is always cropped.
##
## @item "convert_utf"
## If set to 1 or TRUE, xls2oct tries to do a best job of converting
## UTF-8 characters to one-byte characters so that they display
## properly in Octave if that uses a terminal that does not support
## UTF-8 encoding (e.g., Windows 7 and below).
## For the COM interface this conversion is done by libraries
## outside Octave so for COM this option has no effect.
## @end table
##
## If only the first argument @var{xls} is specified, xls2oct will try
## to read all contents from the first = leftmost (or the only) worksheet
## (as if a range of @"" (empty string) was specified).
## 
## If only two arguments are specified, xls2oct assumes the second
## argument to be @var{wsh}.  In that case xls2oct will try to read all
## data contained in that worksheet.
##
## Return argument @var{rawarr} contains the raw spreadsheet cell data.
## Use utility function parsecell() to separate numeric and text values from
## @var{rawarr}.
##
## Optional return argument @var{xls} contains the pointer struct. If any
## data were read, field @var{xls}.limits contains the outermost column and
## row numbers of the actually returned cell range.
##
## Optional return argument @var{rstatus} will be set to 1 if the requested
## data have been read successfully, 0 otherwise. 
##
## Erroneous data and empty cells turn up empty in @var{rawarr}.  Date/time
## values in xlsx/.xls files are returned as numerical values.  Note that
## Excel and Octave have different date base values (epoch; 1/1/1900 and
## 1/1/0000, respectively).  The epoch of returned date values depend on
## interface and version of the support SW.
## Be aware that the COM interface trims @var{rawarr} from empty outer rows &
## columns, so a returned cell array may turn out to be smaller than requested
## in @var{range}, independent of field 'formulas_as_text' in @var{options}.
## When using COM, POI, or UNO interface, formulas in cells are evaluated; if
## that fails cached values are retrieved.  These may be outdated depending
## on "Automatic calculation" settings when the spreadsheet was saved.
##
## When reading from merged cells, all array elements NOT corresponding 
## to the leftmost or upper spreadsheet cell will be treated as if the
## "corresponding" spreadsheet cells are empty.
##
## Examples:
##
## @example
##   A = xls2oct (xls1, '2nd_sheet', 'C3:AB40');
##   (which returns the numeric contents in range C3:AB40 in worksheet
##   '2nd_sheet' from a spreadsheet file pointed to in pointer struct xls1,
##   into numeric array A) 
## @end example
##
## @example
##   [An, xls2, status] = xls2oct (xls2, 'Third_sheet');
## @end example
##
## @seealso {oct2xls, xlsopen, xlsclose, parsecell, xlsread, xlsfinfo, xlswrite}
##
## @end deftypefn

## Author: Philip Nienhuis <prnienhuis at users.sf.net>
## Created: 2010-10-16

function [ rawarr, xls, rstatus ] = xls2oct (xls, wsh=1, datrange="", spsh_opts=[])

  ## Check if xls struct pointer seems valid
  if (! isstruct (xls))
    error ("xls2oct: file ptr struct expected for argument #1\n"); 
  endif
  test1 = ! isfield (xls, "xtype");
  test1 = test1 || ~isfield (xls, "workbook");
  test1 = test1 || isempty (xls.workbook);
  test1 = test1 || isempty (xls.app);
  test1 = test1 || ~ischar (xls.xtype);
  if test1
    error ("xls2oct: invalid xls file pointer struct\n");
  endif

  ## Check worksheet ptr
  if (! (ischar (wsh) || isnumeric (wsh)))
    error ("xls2oct: integer (index) or text (wsh name) expected for arg #2\n");
  elseif (isempty (wsh))
    wsh = 1;
  endif

  ## Check range
  if (! (isempty (datrange) || ischar (datrange)))
    error ("xls2oct: character string expected for arg #3 (range)\n"); 
  elseif (! isempty (datrange))
    ## Check for range name and convert it to range & optionally sheet 1.
    ## Check if it matches a range
    [datrange, wsh, xls] = chknmrange (xls, datrange, wsh);
  endif

  ## Check & setup options struct
  if (nargin < 4 || isempty (spsh_opts))
    spsh_opts.formulas_as_text = 0;
    spsh_opts.strip_array = 1;
    spsh_opts.convert_utf = 0;
    ## Future options:

  elseif (isstruct (spsh_opts))
    if (! isfield (spsh_opts, "formulas_as_text"))
      spsh_opts.formulas_as_text = 0;
    endif
    if (! isfield (spsh_opts, "strip_array"))
      spsh_opts.strip_array = 1;
    endif
    if (! isfield (spsh_opts, "convert_utf"))
      spsh_opts.convert_utf = 0;
    endif
    ## Future options:

  else
    error ("xls2oct: structure expected for arg #4 (options)\n");
  endif

  ## Select the proper interfaces
  switch upper (xls.xtype)
    case "COM"
      ## Call Excel thru COM / ActiveX server
      [rawarr, xls, rstatus] = __COM_spsh2oct__ (xls, wsh, datrange, spsh_opts);
    case "JOD"
      ## Read ods file tru Java & jOpenDocument. First check for formula support
      if ((xls.odfvsn < 4) && spsh_opts.formulas_as_text)
        ## Not supported in jOpenDucument < 1.3
        warning (["xls2oct: option 'formulas_as_text' not supported\n", ...
                  "in jOpenDocument < 1.3; please upgrade. Option ignored.\n"]);
        spsh_opts.formulas_as_text = 0;
      endif
      [rawarr, xls, rstatus] = __JOD_spsh2oct__ (xls, wsh, datrange, spsh_opts);
    case "JXL"
      ## Read xls file thru JExcelAPI
      [rawarr, xls, rstatus] = __JXL_spsh2oct__ (xls, wsh, datrange, spsh_opts);
    case "OTK"
      ## Read ods file tru Java & ODF toolkit
      switch xls.odfvsn
        case "0.7.5"
          [rawarr, xls, rstatus] = __OTK_ods2oct__ (xls, wsh, datrange, spsh_opts);
        case {"0.8.6", "0.8.7", "0.8.8"}
          [rawarr, xls, rstatus] = __OTK_spsh2oct__ (xls, wsh, datrange, spsh_opts);
        otherwise
          error ("xls2oct: unsupported odfdom version or invalid ods file pointer.\n");
      endswitch
      [rawarr, xls, rstatus] = __OTK_spsh2oct__ (xls, wsh, datrange, spsh_opts);
    case "OXS"
      ## Read xls file thru OpenXLS
      [rawarr, xls, rstatus] = __OXS_spsh2oct__ (xls, wsh, datrange, spsh_opts);
    case "POI"
      ## Read xls file thru Java POI
      [rawarr, xls, rstatus] = __POI_spsh2oct__ (xls, wsh, datrange, spsh_opts);
    case "UNO"
      ## Read xls file thru OpenOffice.org UNO (Java) bridge
      [rawarr, xls, rstatus] = __UNO_spsh2oct__ (xls, wsh, datrange, spsh_opts);
    case "OCT"
      ## Read xls file thru native Octave
      if (strcmpi (xls.app, "xlsx"))
        [rawarr, xls, rstatus] = __OCT_xlsx2oct__ (xls, wsh, datrange, spsh_opts);
      elseif (strcmpi (xls.app, "gnumeric"))
        [rawarr, xls, rstatus] = __OCT_gnm2oct__ (xls, wsh, datrange);
      elseif (strcmpi (xls.app, "ods"))
        [rawarr, xls, rstatus] = __OCT_ods2oct__ (xls, wsh, datrange, spsh_opts);
      else
        error ("xls2oct: file format not supported for OCT interface\n");
      endif
      ## Replace XML escape sequences by regular characters
      idx = cellfun (@ischar, rawarr);
      rawarr(idx) = strrep (rawarr(idx), "&amp;",  "&");
      rawarr(idx) = strrep (rawarr(idx), "&lt;",   "<");
      rawarr(idx) = strrep (rawarr(idx), "&gt;",   ">");
      rawarr(idx) = strrep (rawarr(idx), "&apos;", "'");
      rawarr(idx) = strrep (rawarr(idx), "&quot;",  '"');
    otherwise
      error (sprintf ("xls2oct: unknown Excel .xls interface - %s.\n", xls.xtype));
  endswitch

  ## Optionally strip empty outer rows and columns & keep track of original data location
  if (spsh_opts.strip_array)
    emptr = cellfun ("isempty", rawarr);
    if (all (all (emptr)))
      rawarr = {};
      xls.limits = [];
    else
      nrows = size (rawarr, 1); ncols = size (rawarr, 2);
      irowt = 1;
      while (all (emptr(irowt, :))), irowt++; endwhile
      irowb = nrows;
      while (all (emptr(irowb, :))), irowb--; endwhile
      icoll = 1;
      while (all (emptr(:, icoll))), icoll++; endwhile
      icolr = ncols;
      while (all (emptr(:, icolr))), icolr--; endwhile

      ## Crop output cell array and update limits
      rawarr = rawarr(irowt:irowb, icoll:icolr);
      xls.limits = xls.limits + [icoll-1, icolr-ncols; irowt-1, irowb-nrows];
    endif
  endif

endfunction
