## Copyright (C) 2009-2021 by Philip Nienhuis
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
## this program; if not, see <http.//www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} [@var{numarr}, @var{txtarr}, @var{rawarr},  @var{limits}] = xlsread (@var{filename})
## @deftypefnx {Function File} [@var{numarr}, @var{txtarr}, @var{rawarr}, @var{limits}] = xlsread (@var{filename}, @var{wsh})
## @deftypefnx {Function File} [@var{numarr}, @var{txtarr}, @var{rawarr}, @var{limits}] = xlsread (@var{filename}, @var{range})
## @deftypefnx {Function File} [@var{numarr}, @var{txtarr}, @var{rawarr}, @var{limits}] = xlsread (@var{filename}, @var{wsh}, @var{range})
## @deftypefnx {Function File} [@var{numarr}, @var{txtarr}, @var{rawarr}, @var{limits}] = xlsread (@var{filename}, @var{wsh}, @var{range}, @var{interface}, @dots{})
## @deftypefnx {Function File} [@var{numarr}, @var{txtarr}, @var{rawarr}, @var{limits}] = xlsread (@var{filename}, @var{wsh}, @var{range}, @var{options}, @dots{})
## @deftypefnx {Function File} [@var{numarr}, @var{txtarr}, @var{rawarr}, @var{limits}] = xlsread (@var{filename}, @var{wsh}, @var{range}, @var{verbose}, @dots{})
## @deftypefnx {Function File} [@var{numarr}, @var{txtarr}, @var{rawarr}, @var{extout}, @var{limits}] = xlsread (@var{filename}, @var{wsh}, @var{range}, @var{func_handle}, @dots{})
## Read data from a spreadsheet file.
##
## Out of the box, xlsread can read data from .xlsx, .ods and .gnumeric
## spreadsheet files.  For .xlsx it is relatively fast (when reading an
## entire sheet), for .ods quite slow and for .gnumeric it's the only
## choice. @*
## For reading from other file formats or for faster I/O, see below under
## "Spreadsheet I/O interfaces".
##
## @indentedblock
## ==========@ Input arguments@ =============
## @end indentedblock
##
## Required parameter:
##
## @var{filename}: the spreadsheet file to read data from.  If it does
## not contain any directory (i.e., full or relative path), the file is
## assumed to be in the current directory.  The filename extension
## (e.g., .ods, .xlsx or .gnumeric) must be included in the file name;
## when using the UNO interface all file formats can be read that are
## supported by the locally installed OpenOffice.org or LibreOffice
## version (e.g., wk1, csv, dbf, .xlsm, etc.).  The same holds for COM
## (MS-Excel) on Windows when the windows package is loaded.
##
## Optional parameters:
##
## @var{wsh} is either numerical or text; in the latter case it is
## case-sensitive and it may be max. 31 characters long for .xls and
## .xlsx formats; for .ods the limit is much larger (> 2000 chars).
## Note that in case of a numerical @var{wsh} this number refers to the
## position in the visible sheet stack, counted from the left in a
## spreadsheet program window.  The default is numerical 1, i.e.
## corresponding to the leftmost sheet tab in the spreadsheet file. @*
## Note: xlsread ignores the concept of "active worksheet" (i.e., the
## worksheet shown if the file is opened in a spreadheet program).
##
## @var{range} is expected to be a regular spreadsheet range format,
## or "" (empty string, indicating all data in a worksheet).
## If no explicit range is specified the occupied cell range will have
## to be determined behind the scenes first; this can take some time for
## the native OCT and Java-based interfaces (but the results may be more
## reliable than that of UNO/LibreOffice or ActiveX/COM).
## Instead of a spreadsheet range a Named range defined in the
## spreadsheet file can be used as well. In that case the Named range
## should be specified as 3rd argument and the value of 2nd argument
## @var{wsh} doesn't matter as the worksheet associated with the
## specified Named range will be used.
##
## @indentedblock
## If only the first argument @var{filename} is specified, xlsread will
## try to read all contents (as if a range of @"" (empty string) was
## specified) from the first = leftmost (or the only) worksheet.
##
## If only two arguments are specified, xlsread assumes the second
## argument to be @var{range} if it is a string argument and contains
## a ":" or if it is @"" (empty string), and in those cases assumes
## the data must be read from the leftmost worksheet (not necessarily
## Sheet1). @*
## However, if only two arguments are specified and the second argument
## is either numeric or a text string that does not contain a ".", it is
## assumed to be @var{wsh} and to refer to a worksheet.  In that case
## xlsread tries to read all data contained in that worksheet.
##
## To be able to use Named ranges, the second input argument should
## refer to a worksheet and the third should be the Named range.
## @end indentedblock
##
## After these "regular" input arguments a number of optional arguments
## can be supplied in any desired order, but just one of each optional
## argument type:
##
## @table @asis
## @item @var{interface} (character or cellstr value)
## (see also further below under "Spreadsheet I/O interfaces".)
## @var{Interface} (often a three-character case-insensitive text string)
## can be used to override the automatic interface selection by xlsread
## out of the locally supported ones.
##
## For .ods I/O select one or more of "jod", "otk", "uno" or "oct" for
## @var{reqintf} (see help for xlsopen). @*
## For I/O to/from .xlsx files a value of 'com', 'poi', 'uno', or 'oct'
## can be specified.  For Excel'95 files use 'com', or if Excel is not
## installed use 'jxl', 'basic' or 'uno'. POI can't read Excel'95 but
## will try to fall back to JXL.
##
## As @var{reqintf} can also be a cell array of strings, one can select
## or exclude one or more interfaces. If no interface was explicitly
## selected, Octave will select one automatically based on available
## external support software.  Octave will keep using a selected
## interface during an Octave ession as long as no other interface is
## specified, even if in the mean time other support software becomes
## available (e.g., by loading a package).  The other way round,
## removing external support software while the interface it is based
## on was selected, is not advised and might lead to unpredictable
## behavior.
## @end item
##
## @item @var{func_handle}
## If a function handle is specified, the pertinent function (having at
## most two output arrays) will be applied to the numeric output data of
## xlsread. Any second output of the function will be in a 4th output
## argument @var{extout} of xlsread; output argument @var{limits}
## becomes the 5th argument then (see below).
## @end item
##
## @item @var{options} (struct value)
## xlsread's data output can be influenced to some extent by a number of
## other options.  See OPTIONS in "help xls2oct" for an overview.
## @end item
##
## @item @var{verbose} (logical value)
## To show which spreadsheet I/O interfaces have been found or which one
## is requested and active, enter true or a numeric 1 for @var{verbose}.
## The default value is false (no info about found interfaces).
## @end item
## @end table
##
##
## @indentedblock
## ==========@ Output arguments@ =============
## @end indentedblock
##
## Return argument @var{numarr} contains the numeric data, optional
## return arguments @var{txtarr} and @var{rawarr} contain text strings
## and the raw spreadsheet cell data, respectively. @*
## Return argument @var{limits} contains the outer column/row numbers
## of the read spreadsheet range where @var{numarr}, @var{txtarr} and
## @var{rawarr} have come from (remember, xlsread trims outer rows and
## columns). @*
## In case a function handle was specified (see above), @var{extout}
## will be the 4th output argument and @var{limits} the 5th, to be
## Matlab compatible with regard to function handle output.
##
## Erroneous data and empty cells are set to NaN in @var{numarr} and
## turn up empty in @var{txtarr} and @var{rawarr}.  Date/time values in
## Excel are returned as numerical values in @var{numarr}.  Note that
## Excel and Octave have different date base values (epoch; 1/1/1900 &
## 1/1/0000, resp.).  When using the COM interface, spreadsheet date
## values lying before 1/1/1900 are returned as strings, formatted as
## they appear in the spreadsheet.  The returned date format for other
## interfaces depend on interface type and support SW version.
##
## @var{numarr} and @var{txtarr} are trimmed from empty outer rows
## and columns.  Be aware that the COM interface does the same for
## @var{rawarr}, so any returned array may turn out to be smaller than
## requested in @var{range}.  Use the last return argument @var{LIMITS}
## for info on the cell ranges your data came from.
## If you don't want the output to be trimmed, specify an Options struct
## containing a field "strip_array" with contents 0 or false as extra
## input argument (see above).
##
## Remarks: @*
## --------
##
## When reading from merged cells, all array elements NOT corresponding
## to the leftmost or upper spreadsheet cell will be treated as if the
## "corresponding" cells are empty.
##
## xlsread is just a wrapper for a collection of scripts that find out
## the interface to be used (COM, Java/POI, Java/JOD, Java/OXS, Java/UNO,
## etc.), select one, and then do the actual reading.  Function
## parsecell() is invoked to separate the numerical and text data from
## the raw output array. @*
## For each call to xlsread (1) the selected interface must be started,
## (2) the spreadsheet file read into memory, (3) the data read from the
## requested worksheet, and (4) the file closed, interface closed and
## memory released.  When reading multiple ranges from the same file (in
## optionally multiple, separate worksheets) a significant speed boost
## can be obtained by invoking those scripts directly as in: @*
##
## xlsopen / xls2oct [/ parsecell] / ... / xlsclose @*
##
## That way it is also possible to mix reading and writing (or vice
## versa) - (except for the JXL interface): @*
##
## xlsopen / xls2oct [/ parsecell] / oct2xls / ... / xlsclose @*
##
## Beware: @*
## When using the COM interface, hidden Excel invocations may be kept
## running silently ("zombie invocations") if the spreadsheet file isn't
## closed correctly or in case of unexpected errors.  For the UNO interface
## it can be worse - hidden LibreOffice invocations may even prevent Octave
## from closing.
##
##
## @indentedblock
## ==========@ Spreadheet I/O interfaces@ =============
## @end indentedblock
##
## To be able to read from other file formats or for faster reading,
## external software is required.  The connection to such external
## software is called an "interface".  Below is an overview of the
## supported interfaces with the pertinent required external software
## together with a speed indication:
## @multitable {1} {12} {123567890123456789012345678901234567890} {1234567890}
## @item * @tab OCT @tab built-in, no external SW required @tab see above
## @item * @tab JOD @tab Java JRE and jOpendocument @tab fastest
## @item * @tab OTK @tab Java JRE and ODF Toolkit @tab slow
## @item * @tab UNO @tab Java JRE and LibreOffice or OpenOffice.org @tab **
## @item * @tab COM @tab (Windows only) octave-forge windows package and MS-Excel @tab **
## @item * @tab POI @tab Java JRE and Apache POI @tab intermediate
## @item * @tab JXL @tab Java JRE and JExcelAPI @tab intermediate
## @item * @tab OXS @tab Java JRE and OpenXLS @tab fastest
## @end multitable
## @indentedblock
## ** UNO needs to start up LibreOffice (or OpenOffice.org) behind the scenes
## which takes time.  But once LibreOffice is loaded, reading is very fast, so
## for large .ods spreadsheet files it may be the fastest option.  Similar
## holds for the COM interface, Excel and .xls/.xlsx files.
## @end indentedblock
##
## The table below offers an overview of the file formats currently
## supported by each interface.  For each file format, xlsread
## automatically first tries the leftmost installed interface in the table.
##
## @multitable {1234567890123456789} {1} {1} {1234567} {1} {1} {1} {1} {1} {1}
## @item @tab -----------------------@ Interfaces@ -------------------
## @headitem File extension  @tab COM @tab POI @tab POI+OOXML @tab JXL @tab OXS @tab UNO @tab OTK @tab JOD @tab OCT
## @item .ods                @tab @ ~ @tab     @tab           @tab     @tab     @tab @ + @tab @ + @tab @ + @tab @ +
## @item .sxc                @tab     @tab     @tab           @tab     @tab     @tab @ + @tab     @tab @ R @tab
## @item .xls (Excel95)      @tab @ R @tab     @tab           @tab @ R @tab     @tab @ R @tab     @tab     @tab
## @item .xls (Excel97-2003) @tab @ + @tab @ + @tab    @ +    @tab @ + @tab @ + @tab @ + @tab     @tab     @tab
## @item .xlsx (Excel2007+)  @tab @ ~ @tab     @tab    @ +    @tab     @tab (+) @tab @ + @tab     @tab     @tab @ +
## @item .xlsb, xlsm         @tab @ ~ @tab     @tab           @tab     @tab @ ? @tab @ + @tab     @tab     @tab @ R?
## @item .wk1                @tab @ + @tab     @tab           @tab     @tab     @tab @ R @tab     @tab     @tab
## @item .wks                @tab @ + @tab     @tab           @tab     @tab     @tab @ R @tab     @tab     @tab
## @item .dbf                @tab     @tab     @tab           @tab     @tab     @tab @ + @tab     @tab     @tab
## @item .fods               @tab     @tab     @tab           @tab     @tab     @tab @ + @tab     @tab     @tab
## @item .uos                @tab     @tab     @tab           @tab     @tab     @tab @ + @tab     @tab     @tab
## @item .dif                @tab     @tab     @tab           @tab     @tab     @tab @ + @tab     @tab     @tab
## @item .csv                @tab @ + @tab     @tab           @tab     @tab     @tab @ R @tab     @tab     @tab
## @item .gnumeric           @tab     @tab     @tab           @tab     @tab     @tab     @tab     @tab     @tab @ +
## @end multitable
##
## ~ = dependent on LO/OOo/Excel version; @* + = read/write; @* R = only reading. @*
## (+) unfortunately OOXML support in the OpenXLS Java library itself is
##     buggy, so OOXML support for OXS has been disabled (but it is implemented)
##
## The utility function chk_spreadsheet_support.m is useful for
## checking and setting up external support SW (e.g., adding relevant
## Java .jar libraries to the javaclasspath).
##
##
## @indentedblock
## ==============@ Examples@ =================
## @end indentedblock
##
## Basic usage to get numerical data from a spreadsheet:
##
## @example
##   A = xlsread ('test4.xls', '2nd_sheet', 'C3.AB40');
##   (which returns the numeric contents in range C3.AB40 in worksheet
##   '2nd_sheet' from file test4.xls into numeric array A)
## @end example
##
## A little more involved:
##
## @example
##   [An, Tn, Ra, limits] = xlsread ('Sales2009.ods', 'Third_sheet');
##   (which returns all data in worksheet 'Third_sheet' in file 'Sales2009.ods'
##   into array An, the text data into array Tn, the raw cell data into
##   cell array Ra and the ranges from where the actual data came in limits)
## @end example
##
## How to select an interface; in this example two:
##
## @example
##   numarr = xlsread ('Sales2010.xls', 4, [], @{'JXL', 'COM'@});
##   (Read all data from 4th worksheet in file Sales2010.xls using either JXL
##    or COM interface (i.e, exclude POI, OXS, UNO and OCT interfaces).
## @end example
##
## @seealso {xlswrite, xlsopen, xls2oct, parsecell, xlsclose, xlsfinfo, oct2xls}
##
## @end deftypefn

## Author. Philip Nienhuis <prnienhuis at users.sf.net>
## Created. 2009-10-16

function [ numarr, txtarr, rawarr, varargout ] = xlsread (fn, wsh, datrange, varargin)

  rstatus = 0;

  if (nargin < 1)
    error ("xlsread: no input arguments specified\n")
  elseif (! ischar (fn))
    error (["xlsread: filename (text string) expected for argument #1, ", ...
            "not a %s\n"], class (fn));
  elseif (nargin == 1)
    wsh = 1;
    datrange = "";
  elseif (nargin == 2)
    ## Find out whether 2nd argument = worksheet or range
    if (isnumeric (wsh) || (isempty (strfind (wsh, ":" )) && ! isempty (wsh)))
      ## Apparently a worksheet specified
      datrange = "";
    else
      ## Range specified
      datrange = wsh;
      wsh = 1;
    endif
  endif
  reqintf = hndl = opts = extout = [];

  ## Process additional input arguments beyond #3
  verbose = false;
  if (nargin > 3)
    for ii=1:nargin-3
      if (ischar (varargin{ii}))
        ## Request a certain interface
        reqintf = varargin{ii};
        ## A small gesture for Matlab compatibility. JExcelAPI supports BIFF5.
        if (! isempty (reqintf) && ischar (reqintf) && strcmpi (reqintf, "BASIC"))
          reqintf = {"JXL"};
          printf ("(BASIC (BIFF5) support request translated to JXL)\n");
        endif
      elseif (strcmp (class (varargin{ii}), "function_handle"))
        ## Function handle to apply to output "num"
        hndl = varargin{ii};
      elseif (isstruct(varargin{ii}))
        ## Options struct. It will be validated in xls2oct, just convey here.
        opts = varargin{ii};
      elseif ((isnumeric (varargin{ii}) && isreal (varargin{ii}) && ...
               isfinite (varargin{ii})) || islogical (varargin{ii}))
        ## Show spreadsheet I/O interfaces at first start
        verbose = logical (varargin{ii});
      else
        error ("xlsread: illegal input arg. #%d", ii);
      endif
    endfor
  endif

  rawarr = txtarr = {};
  numarr = varagout{1} = varargout{2} = [];

  ## Checks done. First check for .csv as that doesn't need xlsopen etc;
  ## a convenience for lazy Matlab users (see bugs #40993 & #44511).
  [~, ~, ext] = fileparts (fn);
  if strcmpi (ext, ".csv")
    warning ("xlsread: invoking dlmread to read .csv file ...");
    if (isempty (datrange))
      numarr = dlmread (fn, ",");
    else
      numarr = dlmread (fn, ",", datrange);
    endif
    return

  else
    ## Get raw data into cell array "rawarr". xlsopen finds out what interface
    ## to use. If none found, just return as xlsopen will complain enough.
    unwind_protect                   ## Needed to catch COM errors & to be able
                                     ## to close stray Excel invocations
      ## Get pointer array to spreadsheet file
      xls_ok = 0;
      xls = xlsopen (fn, 0, reqintf, verbose);
      if (! isempty (xls))
        xls_ok = 1;

        ## Get data from spreadsheet file & return handle
        [rawarr, xls, rstatus] = xls2oct (xls, wsh, datrange, opts);

        ## Save some results before xls is wiped
        rawlimits = xls.limits;
        xtype = xls.xtype;

        if (rstatus)
          [numarr, txtarr, lims] = parsecell (rawarr, rawlimits);
          if (! isempty (hndl) && ! isempty (numarr))
            try
              varargout{1} = feval (hndl, numarr);
            catch
              warning (["xlsread: applying specified function handle ", ...
                        "failed with error:\n'%s'\n"], lasterr);
              varargout{1} = [];
            end_try_catch
            varargout{2} = lims;
          else
            varargout{1} = lims;
          endif
        endif
      endif

    unwind_protect_cleanup
      ## Close spreadsheet file
      if (xls_ok)
        xls = xlsclose (xls);
      endif

    end_unwind_protect
  endif

endfunction
