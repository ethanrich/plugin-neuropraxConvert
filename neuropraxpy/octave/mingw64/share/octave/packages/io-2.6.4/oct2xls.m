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
## @deftypefn {Function File} [ @var{xls}, @var{rstatus} ] = oct2xls (@var{arr}, @var{xls})
## @deftypefnx {Function File} [ @var{xls}, @var{rstatus} ] = oct2xls (@var{arr}, @var{xls}, @var{wsh})
## @deftypefnx {Function File} [ @var{xls}, @var{rstatus} ] = oct2xls (@var{arr}, @var{xls}, @var{wsh}, @var{range})
## @deftypefnx {Function File} [ @var{xls}, @var{rstatus} ] = oct2xls (@var{arr}, @var{xls}, @var{wsh}, @var{range}, @var{options})
## Add data in 1D/2D CELL array @var{arr} into a cell range @var{range}
## in worksheet @var{wsh} in a spreadsheet file pointed to in structure
## @var{xls}.
##
## Return argument @var{xls} equals supplied argument @var{xls} and is
## updated by oct2xls.
## A subsequent call to xlsclose is needed to write the updated spreadsheet
## to disk (and -if needed- close the LibreOffice (OOo) or Excel invocation).
##
## @var{arr} can be any 1D or 2D array containing numerical, logical and/or
## character data (cellstr) except complex.  Mixed type arrays can only be
## cell arrays.
##
## @var{xls} must be a valid pointer struct created earlier by xlsopen.
##
## @var{wsh} can be a number or string (max. 31 chars for .xlsx/.xls files).
## If it is numeric it refers to the position in the total sheet stack incl.
## e.g., chartsheets.
##
## In case of existing files, some checks are made for existing worksheet
## names or numbers, or whether @var{wsh} refers to an existing sheet with
## a type other than worksheet (e.g., chart).
## When new worksheets are to be added to the spreadsheet file, they are
## inserted to the right of all existing worksheets.  The pointer to the
## "active" sheet (shown when opened in a spreadsheet program) remains
## untouched.
##
## If @var{range} is omitted or just the top left cell of the range is
## specified, the actual range to be used is determined by the size of
## @var{arr}.  If nothing is specified for @var{range} the top left cell
## is assumed to be 'A1'.  If defined in the spreadsheet file, a "Named
## range" can also be specified.  In that case @var{wsh} will be ignored
## and the worksheet associated with the specified Named range will be
## used.
##
## Data are added to the worksheet, ignoring other data already present;
## existing data in the range to be used will be overwritten.
##
## If @var{range} contains merged cells, only the elements of @var{arr}
## corresponding to the top or left spreadsheet cells of those merged cells
## will be written, other array cells corresponding to that cell will be
## ignored.
##
## Optional argument @var{options}, a structure, can be used to specify
## various write modes.
## @table @asis
## @item "formulas_as_text"
## If set to 1 or TRUE formula strings (i.e., text strings (assumed to
## start with "=" and end in a ")") are to be written as literal
## text strings rather than as spreadsheet formulas. (The latter is the
## default).
##
## @item 'convert_utf'
## If set to 1 or TRUE, oct2xls converts one-byte characters outside the
## range [32:127] to UTF-8 so that they are properly entered as UTF-8
## encoded text in spreadsheets.  The default value is 0.
## This setting has no effect for the COM interface as that does the
## encoding automatically using libraries outside Octave.
## @end table
##
## Beware that -if invoked- LibreOffice or Excel invocations may be left
## running silently in case of Java or COM errors.  Invoke xlsclose with a
## proper pointer struct to try to close them.
## When using Java, note that large data array sizes elements may exhaust
## the Java shared memory space for the default Java memory settings.
## For larger arrays, appropriate memory settings are needed in the file
## java.opts; then the maximum array size for the Java-based spreadsheet
## options may be in the order of 10^6 elements.  In caso of UNO this
## limit is not applicable and spreadsheets may be much larger.
##
## Examples:
##
## @example
##   [xlso, status] = oct2xls ('arr', xlsi, 'Third_sheet', 'AA31:AB278');
## @end example
##
## @seealso {xls2oct, xlsopen, xlsclose, xlsread, xlswrite, xlsfinfo}
##
## @end deftypefn

## Author: Philip Nienhuis <prnienhuis at users sf net>
## Created: 2009-12-01

function [ xls, rstatus ] = oct2xls (obj, xls, wsh=1, crange="", spsh_opts=[])

  if (nargin < 2)
    error ("oct2xls: needs a minimum of 2 arguments.");
  endif
  
  ## Validate input array, make sure it is a cell array
  if (isempty (obj))
    warning ("oct2xls: request to write empty matrix - ignored."); 
    rstatus = 1;
    return;
  elseif (isnumeric (obj))
    obj = num2cell (obj);
  elseif (ischar (obj))
    obj = {obj};
    printf ("(oct2xls: input character array converted to 1x1 cell)\n");
  elseif (! iscell (obj))
    error ("oct2xls: input array neither cell nor numeric array\n");
  endif
  if (ndims (obj) > 2)
    error ("oct2xls: only 2-dimensional arrays can be written to spreadsheet\n"); 
  endif
  ## Cast all numerical values to double as spreadsheets only have
  ## double/boolean/text type
  idx = cellfun (@isnumeric, obj, "UniformOutput", true);
  obj(idx) = cellfun (@double, obj(idx), "UniformOutput", false);

  ## Check xls file pointer struct
  test1 = ! isfield (xls, "xtype");
  test1 = test1 || ! isfield (xls, "workbook");
  test1 = test1 || isempty (xls.workbook);
  test1 = test1 || isempty (xls.app);
  test1 = test1 || ! ischar (xls.xtype);
  if (test1)
    error ("oct2xls: invalid xls file pointer struct\n");
  endif

  ## Check worksheet ptr
  if (! (ischar (wsh) || isnumeric (wsh)))
    error ("oct2xls: integer (index) or text (wsh name) expected for arg # 3\n");
  elseif (isempty (wsh))
    wsh = 1;
  endif

  ## Check range
  if (! isempty (crange) && ! ischar (crange))
    error ("oct2xls: character string expected for arg #4 (range)\n");
  elseif (isempty (crange))
    crange = "";
  elseif (! isempty (crange))
    ## Check for range name and convert it to range & optionally sheet
    ## 1. Check if it matches a range
    alfnm = "[abcdefghijklmnopqrstuvwxyz]+[0123456789]+";
    rlims = cell2mat (cell2mat (regexp (lower (deblank (crange)), ...
                                ["(^" alfnm ":" alfnm "$|^" alfnm "$)"], "tokens")));
    if (isempty (rlims))
      ## Apparently no cell range - check for Named range
      [crange, wsh, xls] = chknmrange (xls, crange, wsh);
    else
      if (isempty (strfind (rlims, ":")))
        if (strcmpi (xls.filename(end-4:end-1), ".xls"))
          crange = [rlims ":XFD1048576"];     ## OOXML has ridiculously large limits
        elseif (strcmpi (xls.filename(end-3:end), ".ods"))
          crange = [rlims ":AMJ1048576"];     ## LO max. 1024 columns
        else
          ## FIXME .gnumeric and other formats unknown
          crange = [rlims ":IV65536"];        ## Regular xls limits
        endif
      endif
    endif
  endif

  ## Various options 
  if (isempty (spsh_opts))
    spsh_opts.formulas_as_text = 0;
    spsh_opts.convert_utf = 0;
    ## other options to be implemented here
  elseif (isstruct (spsh_opts))
    if (! isfield (spsh_opts, "formulas_as_text"))
      spsh_opts.formulas_as_text = 0; 
    endif
    if (! isfield (spsh_opts, "convert_utf"))
      spsh_opts.convert_utf = 0;
    endif
    ## other options to be implemented here
  else
    error ("oct2xls: structure expected for arg #5\n");
  endif
  
  if (nargout < 1)
    printf ("oct2xls: warning: no output spreadsheet file pointer specified.\n");
  endif

  ## Select interface to be used
  switch upper (xls.xtype)
    case, "COM"
      ## ActiveX / COM
      [xls, rstatus] = __COM_oct2spsh__ (obj, xls, wsh, crange, spsh_opts);
    case, "JOD"
      ## Write ods file tru Java & jOpenDocument. API still leaves lots to be wished...
      [ xls, rstatus ] = __JOD_oct2spsh__ (obj, xls, wsh, crange);
    case, "JXL"
      ## Invoke Java and JExcelAPI
      [xls, rstatus] = __JXL_oct2spsh__ (obj, xls, wsh, crange, spsh_opts);
    case, "OXS"
      ## Invoke Java and OpenXLS
      [xls, rstatus] = __OXS_oct2spsh__ (obj, xls, wsh, crange, spsh_opts);
    case, "OTK"
      ## Write ods file thru Java & ODF toolkit.
      switch xls.odfvsn
        case "0.7.5"
          [ xls, rstatus ] = __OTK_oct2ods__ (obj, xls, wsh, crange, spsh_opts);
        case {"0.8.6", "0.8.7", "0.8.8"}
          [ xls, rstatus ] = __OTK_oct2spsh__ (obj, xls, wsh, crange, spsh_opts);
        otherwise
          error ("oct2ods: unsupported odfdom version\n");
      endswitch
    case, "POI"
      ## Invoke Java and Apache POI
      [xls, rstatus] = __POI_oct2spsh__ (obj, xls, wsh, crange, spsh_opts);
    case, "UNO"
      ## Invoke Java and UNO bridge (OpenOffice.org)
      [xls, rstatus] = __UNO_oct2spsh__ (obj, xls, wsh, crange, spsh_opts);
    case, "OCT"
      ## Replace illegal XML characters by XML escape sequences
      idx = cellfun (@ischar, obj);
      obj(idx) = strrep (obj(idx), "&", "&amp;" );
      obj(idx) = strrep (obj(idx), "<", "&lt;"  );
      obj(idx) = strrep (obj(idx), ">", "&gt;"  );
      obj(idx) = strrep (obj(idx), "'", "&apos;");
      obj(idx) = strrep (obj(idx), '"', "&quot;" );
      ## Invoke native Octave code (only ods/xlsx/gnumeric)
      [xls, rstatus] = __OCT_oct2spsh__ (obj, xls, wsh, crange, spsh_opts);
    otherwise
      error (sprintf ("oct2xls: unknown Excel .xls interface - %s.\n", xls.xtype));
  endswitch

endfunction
