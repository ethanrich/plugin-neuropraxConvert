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
## @deftypefn {Function File} @var{rstatus} = xlswrite (@var{filename}, @var{arr})
## @deftypefnx {Function File} @var{rstatus} = xlswrite (@var{filename}, @var{arr}, @var{wsh})
## @deftypefnx {Function File} @var{rstatus} = xlswrite (@var{filename}, @var{arr}, @var{range})
## @deftypefnx {Function File} @var{rstatus} = xlswrite (@var{filename}, @var{arr}, @var{wsh}, @var{range})
## @deftypefnx {Function File} @var{rstatus} = xlswrite (@var{filename}, @var{arr}, @var{wsh}, @var{range}, @var{reqintf}, @dots{})
## @deftypefnx {Function File} @var{rstatus} = xlswrite (@var{filename}, @var{arr}, @var{wsh}, @var{range}, @var{verbose}, @dots{})
## Add data in 1D/2D array @var{arr} to a spreadsheet file.
##
## Out of the box, xlswrite can write data to .xlsx, .ods and .gnumeric
## spreadsheet files.  For .xlsx it is relatively fast, for .ods quite
## slow and for .gnumeric it's the only choice. @*
## For writing to other file formats or for faster I/O, see the help for
## xlsread (under "Spreadsheet I/O interfaces").
##
## Required parameters: @*
## --------------------
##
## @var{filename} must be a valid spreadsheet file name (including file
## name extension).  If @var{filename} does not contain any directory path,
## the file is saved in the current directory.  Writing .xlsm and .xlsb
## is untested but may only reliably be possible with the COM and UNO
## interfaces.
##
## @var{arr} can be any 1D or 2D array containing numerical, logical and/or
## character data (cellstr) except complex.  Mixed numeric/text arrays can
## only be cell arrays.
##
## Optional parameters: @*
## --------------------
##
## @var{wsh} can be a number or string (max. 31 chars for .xls and .xlsx,
## unlimited for .ods). In case of a not yet existing spreadsheet file, only
## one sheet will be created, used & named according to @var{wsh}.
## In case of existing files, some checks are made for existing sheet
## names or numbers, or whether @var{wsh} refers to an existing sheet with
## a type other than worksheet (e.g., chart). @*
## When new sheets are to be added to the spreadsheet file, they are
## inserted to the right of all existing sheets. The pointer to the
## "active" sheet (shown when the file is opened in an external spreadsheet
## program) remains untouched.
##
## @var{range} is expected to be a regular spreadsheet range.
## Data is added to the worksheet; existing data in the requested
## range will be overwritten. @*
## Array @var{arr} will be clipped at the right and/or bottom if its size
## is bigger than can be accommodated in @var{range}.
## If @var{arr} is smaller than the @var{range} allows, it is placed
## in the top left rectangle of @var{range} and existing cell values
## outside the rectangle will be retained.
## If the third argument is a sheet name and @var{range} is specified as
## just one cell, it is taken as the topleft cell and the bottomright
## cell range address is determined from the data.
##
## @indentedblock
## If only 3 arguments are given, the 3rd is assumed to be a spreadsheet
## range if it contains a ":" or is a completely empty string (interpreted
## as A1:AMJ1048576 for .ods, A1:IV65336 for regular .xls or A1:XFD1048576
## for OOXML .xlsx).  The 3rd argument is assumed to refer to a worksheet
## if it is a numeric value or a non-empty text string not containing ":".
## To enter a range of just one cell specify e.g., "F3:F3".
##
## If @var{range} contains merged cells, only the elements of @var{arr}
## corresponding to the top or left spreadsheet cells of those merged
## cells will be written, other array cells corresponding to that merged
## cell will be ignored. In other words, merged spreadsheet cells won't
## be "unmerged".
##
## Instead of a spreadsheet range a Named range defined in the spreadsheet
## file can be used as well. In that case the Named range should be
## specified as 4th argument and the value of 3rd argument @var{wsh}
## doesn't matter as the worksheet associated with the specified Named
## range will be used.
## @end indentedblock
##
## After @var{range} some optional arguments can be specified:
##
## @table @asis
## @item @var{reqintf} (character value)
## When no external support SW for spreadsheet I/O ('interface') is
## installed (see below), xlsread can only write to .xlsx, .ods and
## .gnumeric files using the default (built-in) 'OCT' interface.  If
## external support SW is installed, xlswrite will try locate it
## automatically and invoke it, allowing more file types to be written.
## Multiple spreadsheet I/O 'interfaces' can be installed side-by-side;
## xlswrite will then try to invoke the most suitable one depending
## on file type. @*
## The optional last argument @var{reqintf} can be used to override
## that automatic selection by xlswrite.  The value of @var{reqintf}
## is case-insensitive.  For an overview of interfaces and external
## support software, see the help for xlsread. @*
## Multiple interfaces can be selected if entered as a cell array of
## strings.  Writing gnumeric files can only be done with the OCT
## interface, it is selected automatically for that file type.
## @end item
##
## @item @var{verbose} (numerical or logical value)
## If a value of true (logical) or 1 (numerical) is specified, xlswrite
## will echo the found spreadsheet I/O interfaces when it is started for
## the first time in an Octave session or when @var{reqintf} was
## specified.  If @var{verbose} is omitted or a value of false or 0
## (zero) is specified (the default) no interface info is shown.
## @end item
## @end table
##
## @var{rstatus} returns 1 if writing succeeded, 0 otherwise.
##
## xlswrite is a mere wrapper for various functions which find out what
## spreadsheet interface to use (COM, POI, JOD, etc), followed by
## separate functions for opening, writing to, and closing a spreadsheet
## file.  For each call to xlswrite such an interface must be started
## and a spreadsheet file loaded and written.  When writing to multiple
## ranges and/or sheets in the same spreadsheet file, or reading from
## and writing to the same spreadsheet file, a significant speed bonus can
## be obtained by invoking those scripts directly with multiple calls to
## oct2xls (one for each sheet or range) surrounded by one call to xlsopen
## and xlsclose:
##
## (xlsopen / octxls / oct2xls / .... / xlsclose)
##
## or (mixing reading and writing in any desired order)
##
## (xlsopen / xls2oct / .... / octxls / .... / xlsclose)
##
## Example:
##
## @example
##   status = xlswrite ...
##            ('test4.xls', 'arr', 'Third_sheet', 'C3:AB40');
##   (which adds the contents of array arr (any type) to
##    range C3:AB40 in worksheet 'Third_sheet' in file
##    test4.xls and returns a logical True (= numerical 1)
##    in 'status' if all went well)
## @end example
##
## @seealso {xlsread, oct2xls, xls2oct, xlsopen, xlsclose, xlsfinfo,
## chk_spreadsheet_support}
##
## @end deftypefn

## Author: Philip Nienhuis <prnienhuis at users.sf.net>
## Created: 2009-10-16

function [ rstatus ] = xlswrite (filename, arr, arg3, arg4, varargin)

  rstatus = r_extnd = 0;

  ## Sanity checks
  if (nargin < 2)
    error ("xlswrite: insufficient arguments - see 'help xlswrite'\n");
  elseif (! ischar (filename))
    error ("xlswrite: first argument must be a filename (incl. suffix)\n");
  elseif (nargin == 2)
    ## Assume first worksheet and full worksheet starting at A1
    wsh = 1;
    crange = setrange (filename, "A1");
  elseif (nargin == 3)
    ## Find out whether 3rd argument = worksheet or range
    if (isnumeric (arg3) || (isempty (strfind (arg3, ":")) && ! isempty (arg3)))
      ## Apparently a worksheet specified
      wsh = arg3;
      crange = setrange (filename, "A1");
    else
      ## Range specified
      wsh = 1;
      crange = arg3;
    endif
  elseif (nargin >= 4)
    wsh = arg3;
    crange = arg4;
    r_extnd = (! isempty (crange) && isempty (strfind (crange, ":")) && nargin >= 4);
  endif

  reqintf = [];
  verbose = false;
  for ii=1:numel (varargin)
    if (ischar (varargin{ii}))
      reqintf = varargin{ii};
    elseif ((isnumeric (varargin{ii}) && isreal (varargin{ii}) && ...
             isfinite (varargin{ii})) || islogical (varargin{ii}))
      verbose = varargin{ii};
    else
      error ("xlswrite: unrecognized argument nr %d", ii);
    endif
  endfor

  if (isempty (wsh))
    wsh = 1;
  endif
  if (isempty (crange) || r_extnd)
    if (r_extnd)
      tlcl = crange;
    else
      tlcl = "A1";
    endif
    crange = setrange (filename, tlcl);
  endif

  ## Parse range
  [topleft, nrows, ncols, trow, lcol] = parse_sp_range (crange);

  ## Check if arr fits in range
  [nr, nc] = size (arr);
  if ((nr > nrows) || (nc > ncols))
    # Array too big; truncate
    nr = min (nrows, nr);
    nc = min (ncols, nc);
    warning ("xlswrite - array truncated to %d by %d to fit in range %s\n", ...
             nrows, ncols, crange);
    ## Adapt crange
    crange = [ calccelladdress(trow, lcol) ":" ...
               calccelladdress(trow+nrows-1, lcol+ncols-1) ];
  endif

#  unwind_protect          ## Needed to be sure LibreOffice/Excel can be closed
                          ## i.c.o. errors
    xls_ok = 0;
    xls = xlsopen (filename, 1, reqintf, verbose);
    if (! isempty (xls))
      xls_ok = 1;

      [xls, rstatus] = oct2xls (arr(1:nr, 1:nc), xls, wsh, crange);
    endif

#  unwind_protect_cleanup
    if (xls_ok && ! isempty (xls))
      xls = xlsclose (xls);
    endif

#  end_unwind_protect

  if (! isempty (xls))
    ## Apparently the file pointer couldn't be cleared, usually due to errors
    rstatus = 0;
  endif

endfunction


function crange = setrange (filename, tlcl)

  if (strcmpi (filename(end-4:end-1), ".xls"))
    ## OOXML has ridiculously large limits
    crange = ":XFD1048576";
  elseif (strcmpi (filename(end-3:end), ".ods"))
    ## .ods limits as of LO > 3.3
    crange = ":AMJ1048576";
  else
    ## Regular xls limits
    crange = ":IV65536";
  endif
  crange = [tlcl crange];

endfunction
