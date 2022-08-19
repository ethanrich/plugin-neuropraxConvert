## Copyright (C) 2009-2021 Philip Nienhuis
##
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with Octave; see the file COPYING.  If not, see
## <http://www.gnu.org/licenses/>.7

## -*- texinfo -*-
## @deftypefn {Function File} @var{xls} = xlsopen (@var{filename})
## @deftypefnx {Function File} @var{xls} = xlsopen (@var{filename}, @var{readwrite})
## @deftypefnx {Function File} @var{xls} = xlsopen (@var{filename}, @var{readwrite}, @var{reqintf})
## @deftypefnx {Function File} @var{xls} = xlsopen (@var{filename}, @var{readwrite}, @var{reqintf}, @var{verb})
## Get a pointer to a spreadsheet in memory in the form of return argument
## (file pointer struct) @var{xls}.
##
## Calling xlsopen without specifying a return argument is fairly useless
## and considered an error!  After processing the spreadsheet, the file
## pointer must be explicitly closed by calling xlsclose() to release possibly
## large amounts of RAM.
##
## @var{filename} should be a valid spreadsheet file name (including
## extension); see "help xlsread" for an overview of supported spreadsheet file
## formats.
##
## If @var{readwrite} is set to 0 (default value) or omitted, the spreadsheet
## file is opened for reading.  If @var{readwrite} is set to true or 1, a
## spreadsheet file is opened (or created) for reading & writing.
##
## Optional input argument @var{reqintf} can be used to override the
## spreadsheet I/O interface (see below) that otherwise would automatically
## be selected by xlsopen.  In most situations this parameter is unneeded as
## xlsopen automatically selects the most useful interface present, depending
## on installed external support software and requested file type.  A
## user-specified interface selection can be reset to default by entering
## a numeric value of -1.
##
## If a value of 1 or true is entered for @var{verb}, xlsopen returns info about
## the spreadsheet I/O interfaces that were found and/or are requested and
## active.  The default value is false (no info on interfaces is shown).
##
## xlsopen works with interfaces, which are links to support software, mostly
## external. @*
## The built-in 'OCT' interface needs no external software and allows
## I/O from/to OOXML (Excel 2007 and up), ODS 1.2 and Gnumeric. @* For all other
## spreadsheet formats, or if you want more speed and/or more flexibility,
## additional external software is required.  See "help xlsread" for more info. @*
## Currently implemented interfaces to external SW are (in order of preference)
## 'COM' (Excel/COM), 'POI' (Java/Apache POI), 'JXL' (Java/JExcelAPI), 'OXS'
## (Java/OpenXLS), 'UNO' (Java/OpenOffice.org - EXPERIMENTAL!), 'OTK'
## (ODF Toolkit), 'JOD' (jOpendocument) or 'OCT' (native Octave); see below:
##
## @table @asis
## @item xls and .xlsx:
## One or more of (1) a Java JRE plus Apache POI >= 3.5, and/or JExcelAPI
## and/or OpenXLS, and/or OpenOffice.org (or clones) installed on your computer
## + proper javaclasspath set, or (2 - Windows only) OF-windows package and
## MS-Excel.  These interfaces are referred to as POI, JXL, OXS, UNO and COM,
## resp., and are preferred in that order by default (depending on presence of
## the pertinent support SW).  Currently the OCT interface has the lowest
## priority. @*
## Excel'95 spreadsheets (BIFF5) can only be read using the JXL (JExcelAPI),
## UNO (Open-/LibreOffice), and  COM (Excel-ActiveX) interfaces.
## @end item
##
## @item .ods, .sxc:
## A Java JRE plus one or more of (ODFtoolkit (version 0.7.5 or 0.8.6 - 0.8.8)
## & xercesImpl v.2.9.1), jOpenDocument, or OpenOffice.org (or clones)
## installed on your computer + proper javaclasspath set.  These interfaces
## are referred to as OTK, JOD, and UNO resp., and are preferred in that order
## by default (depending on presence of support SW).  The OCT interface has
## lowest priority). @*
## The old OpenOffice.org .sxc format can be read using the UNO interface and
## older versions of the JOD interface.
## @end item
##
## @item Other formats:
## Apart from .gnumeric, by invoking the UNO interface one can read any format
## that the installed LibreOffice version supports. The same goes (on Windows
## systems) for MS-Excel.  However, writing to other file formats than .xlsx,
## .ods, .gnumeric and .xls is not implemented.
## @end item
## @end table
##
## The utility function chk_spreadsheet_support.m can be useful to set the
## javaclasspath for the Java-based interfaces.
##
## Beware: 'zombie' Excel invocations may be left running invisibly in case
## of COM errors or after forgetting to close the file pointer.  Similarly for
## LibreOffice, which may even prevent Octave from being closed (the reason
## the UNO interface is still experimental).
##
## Examples:
##
## @example
##   xls = xlsopen ('test1.xls');
##   (get a pointer for reading from spreadsheet test1.xls)
##
##   xls = xlsopen ('test2.xls', 1, 'POI');
##   (as above, indicate test2.xls will be written to; in this case using Java
##    and the Apache POI interface are requested)
## @end example
##
## @seealso {xlsclose, xlsread, xlswrite, xls2oct, oct2xls, xlsfinfo,
## chk_spreadsheet_support}
##
## @end deftypefn

## Author: Philip Nienhuis <prnienhuis at users.sf.net>
## Created: 2009-11-29

function [ xls ] = xlsopen (filename, xwrite=0, reqinterface=[], verbose=false)

  persistent interfaces; persistent chkintf; persistent lastintf;
  ## interfaces.<intf> = [] (not yet checked),
  ##                      0 (found to be unsupported or unwanted), or
  ##                      1 (checked and OK)

  ## Define preferred order of (default) file extensions
  persistent prefext = {".xls", ".xlsx", ".xlsm", ".ods", ".gnumeric", ".csv"};

  if (isempty (chkintf) || (isnumeric (reqinterface) && reqinterface == -1))
    ## Either not yet checked, or selection to be reset to default
    chkintf = 1;
    interfaces = struct ("COM", [], "JXL", [], "JOD", [], "OCT", 1, ...
                         "OTK", [], "OXS", [], "POI", [], "UNO", []);
    if (isnumeric (reqinterface))
      reqinterface = "";
    endif
  endif
  if (isempty (lastintf))
    lastintf = "---";
  endif
  xlsintf_cnt = 1;

  ## Bit mask keeping track of detected/supported interfaces
  xlssupport = 0;

  ## Input checks
  if (nargout < 1)
      error (["xlsopen: no return argument specified!\n", ...
              "usage:  XLS = xlsopen (Xlfile [, Rw] [, reqintf])\n"]);
  endif
  if (! (islogical (xwrite) || isnumeric (xwrite)))
      error (["xlsopen: numerical or logical value expected for arg ## 2 ", ...
              "(readwrite)\n"]);
  endif
  if (ischar (filename))
    [pth, fnam, ext] = fileparts (filename);
    if (isempty (fnam))
      error ("xlsopen: no filename or empty filename specified");
    endif
    if (xwrite && ! isempty (pth))
      apth = make_absolute_filename (pth);
      if (exist (apth) != 7)
        error ("xlsopen: cannot write into non-existent directory:\n'%s'\n", ...
               apth);
      endif
    endif
  else
    error ("xlsopen: filename expected for argument #1");
  endif

  if (! isempty (reqinterface))
    intfmsg = "requested";
    if (! (ischar (reqinterface) || iscell (reqinterface)))
      error (["xlsopen: arg. #3 (interface) not recognized - ", ...
              "character value required\n"]);
    endif
    ## Turn arg3 into cell array if needed
    if (! iscell (reqinterface))
      reqinterface = {reqinterface};
    endif
    reqinterface = cellfun (@upper, reqinterface, "uni", 0);
    ## Check if previously used interface matches a requested interface
    if (isempty (regexpi (reqinterface, lastintf, "once"){1}) || ...
        ! interfaces.(reqinterface{1}))
      ## New interface requested. Provisionally disable all interfaces
      interfaces.COM = 0; interfaces.JOD = 0; interfaces.JXL = 0;
      interfaces.OCT = 0; interfaces.OTK = 0; interfaces.OXS = 0;
      interfaces.POI = 0; interfaces.UNO = 0;
      for ii=1:numel (reqinterface)
        ## Try to invoke requested interface(s) for this call. Check if it
        ## is supported anyway by emptying the corresponding var.
        try
          interfaces.(reqinterface{ii}) = [];
        catch
          error (sprintf (["xlsopen: unknown interface \"%s\" requested.\n"
                 "Only COM, JOD, JXL, OCT, OTK, OXS, POI or UNO) supported\n"], ...
                 reqinterface{}));
        end_try_catch
      endfor
      if (verbose)
        printf ("\nChecking requested interface(s): ");
      endif
      interfaces = getinterfaces (interfaces, verbose);
      ## Well, is/are the requested interface(s) supported on the system?
      xlsintf_cnt = 0;
      for ii=1:numel (reqinterface)
        if (! interfaces.(toupper (reqinterface{ii})))
          ## No it aint
          if (verbose)
            printf ("%s is not supported.\n", upper (reqinterface{ii}));
          endif
        else
          ++xlsintf_cnt;
        endif
      endfor
      ## Reset interface check indicator if no requested support found
      if (! xlsintf_cnt)
        chkintf = [];
        xls = [];
        return
      endif
    endif
  else
    intfmsg = "available";
  endif

  ## Check if spreadsheet file exists. First check (supported) file name suffix:
  ## FIXME: invoke subfunct mtchext() rather than repeat below code several times
  ftype = 0;
  has_suffix = 1;
  [~, ~, ext] = fileparts (filename);
  if (! isempty (ext))
    ext = lower (ext);
    ## Is .xls or .xls[x,m,b] or .ods or .gnumeric at right(most) position?
    if (ismember (ext, prefext))
      switch ext
        case ".xls"                       ## Regular (binary) BIFF
          ftype = 1;
        case {".xlsx", ".xlsm", ".xlsb"}  ## Zipped XML / OOXML. Catches xlsx, xlsb, xlsm
          ftype = 2;
        case ".ods"                       ## ODS 1.2 (Excel 2007+ & OOo/LO can read ODS)
          ftype = 3;
        case ".sxc"                       ## jOpenDocument (JOD) can read from
          ftype = 4;                      ## .sxc files, but only if odfvsn = 2
        case ".gnumeric"                  ## Zipped XML / gnumeric
          ftype = 5;
        case ".csv"                       ## csv. Detected for xlsread afficionados
          ftype = 6;
        otherwise
          ## FIXME here could come the extraneous ones like .fods, .uos, .wk1, ...
      endswitch
    endif
  else
    has_suffix = 0;
  endif

  ## Adapt file open mode for readwrite argument.
  ## Var readwrite is really used to avoid creating files when wanting
  ## to read, or not finding not-yet-existing files when wanting to write
  ## a new one.  Adapt file open mode for readwrite argument
  if (xwrite)
    fmode = "r+b";
    if (! has_suffix)
      ## Provisionally add .xlsx suffix to filename (most used format)
      filename = [filename ".xlsx"];
      ext = ".xlsx";
      ftype = 2;
    endif
  else
    fmode = "rb";
    if (! has_suffix)
      ## Try to find find an existing file with a recognized file extension
      filnm = mtchext (filename, prefext);
      if (! isempty (filnm))
        ## Simply choose the first one
        if (isstruct (filnm))
          filename = filnm(1).name;
        else
          filename = filnm;
        endif
      endif
    endif
  endif
  ## Explore for filename in relevant rw mode. stat() can't see if file is locked
  fid = fopen (filename, fmode);
  if (fid < 0)                      ## File doesn't exist...
    if (! xwrite)                   ## ...which obviously is fatal for reading...
      ## FIXME process open apps (Excel, LibreOffice, etc) before hard error
      error ( sprintf ("xlsopen: file %s not found\n", filename));
    else                            ## ...but for writing, we need more info:
      fid = fopen (filename, "rb"); ## Check if it exists at all...
      if (fid < 0)                  ## File didn't exist yet. Simply create it
        xwrite = 3;
      else                          ## File exists, but isn't writable => Error
        fclose (fid);               ## Do not forget to close the handle neatly
        error (sprintf (["xlsopen: write mode requested but file %s is ", ...
                        "not writable\n"], filename));
      endif
    endif
  else
    ## Close file anyway to avoid COM or Java errors
    fclose (fid);
  endif

  ## Check for the various interfaces. No problem if they've already been
  ## checked, getinterfaces (far below) just returns immediately then.
  interfaces = getinterfaces (interfaces, verbose);

  ## If no external interface was detected and no suffix was given, use .xlsx
  if (! has_suffix && ! (interfaces.COM + interfaces.POI + ...
                         interfaces.JXL + interfaces.OXS + ...
                         interfaces.UNO))
%    ## Just add 'x' - .xls was already added higher up
%    filename = [filename "x"];
    ftype = 2;
  endif

  ## Initialize file ptr struct
  xls = struct ("xtype",    "NONE",
                "app",      [],
                "filename", [],
                "workbook", [],
                "changed",  0,
                "limits",   []);

  ## Keep track of which interface is selected
  xlssupport = 0;

  ## Interface preference order is defined below:
  ## currently COM -> POI -> JXL -> OXS -> OTK -> JOD -> UNO -> OCT
  ## ftype (file type) is conveyed depending on interface capabilities

  if ((! xlssupport) && interfaces.COM && (ftype != 5))
    ## Excel functioning has been tested above & file exists, so we just invoke it.
    if (verbose)
      printf ("   Invoking COM ...");
    endif
    [ xls, xlssupport, lastintf ] = __COM_spsh_open__ (xls, xwrite, filename, xlssupport);

  elseif ((! xlssupport) && ((interfaces.POI >= 2 && ftype <= 2) || ...
                             (interfaces.POI == 1 && ftype == 1)))
    if (verbose)
      printf ("   Invoking POI ...");
    endif
    [ xls, xlssupport, lastintf ] = __POI_spsh_open__ (xls, xwrite, filename, xlssupport, ftype, interfaces);

  elseif ((! xlssupport) && interfaces.JXL && ftype == 1)
    if (verbose)
      printf ("   Invoking JXL ...");
    endif
    [ xls, xlssupport, lastintf ] = __JXL_spsh_open__ (xls, xwrite, filename, xlssupport, ftype);

  elseif ((! xlssupport) && interfaces.OXS && ftype == 1)
    if (verbose)
      printf ("   Invoking OXS ...");
    endif
    [ xls, xlssupport, lastintf ] = __OXS_spsh_open__ (xls, xwrite, filename, xlssupport, ftype);

  elseif (interfaces.OTK && ! xlssupport && ftype == 3)
    if (verbose)
      printf ("   Invoking OTK ...");
    endif
    [ xls, xlssupport, lastintf ] = ...
              __OTK_spsh_open__ (xls, xwrite, filename, xlssupport);

  elseif (interfaces.JOD && ! xlssupport && (ftype == 3 || ftype == 4))
    if (verbose)
      printf ("   Invoking JOD ...");
    endif
    [ xls, xlssupport, lastintf ] = ...
              __JOD_spsh_open__ (xls, xwrite, filename, xlssupport);

  elseif ((! xlssupport) && interfaces.UNO && (ftype != 5))
    if (verbose)
      printf ("   Invoking UNO ...");
    endif
    ## Warn for LO / OOo stubbornness
    if (ftype == 0 || ftype == 5 || ftype == 6)
      warning ("UNO interface will write ODS format for unsupported file extensions\n")
    endif
    [ xls, xlssupport, lastintf ] = __UNO_spsh_open__ (xls, xwrite, filename, xlssupport);

  elseif ((! xlssupport) && interfaces.OCT && ...
      (ftype == 2 || ftype == 3 || ftype == 5))
    if (verbose)
      printf ("   Invoking OCT ...");
    endif
    [ xls, xlssupport, lastintf ] = __OCT_spsh_open__ (xls, xwrite, filename, xlssupport, ftype);
  endif

  ## Rounding up. If none of the interfaces is supported we're out of luck.
  if (! xlssupport)
    if (isempty (reqinterface))
      ## If no suitable interface was detected (COM or UNO can read .csv), handle
      ## .csv in xlsread (as that's where Matlab n00bs would expect .csv support)
      if (ftype != 6)
        ## This message is appended after message from getinterfaces()
        if (verbose)
          printf ("None.\n");
        endif
        warning ("xlsopen: no'%s' spreadsheet I/O support with %s interfaces.\n", ...
                 ext, intfmsg);
      endif
    else
      ## No match between file type & interface found
      warning ("xlsopen: file type not supported by %s %s %s %s %s %s %s %s\n", ...
                reqinterface{:});
    endif
    xls = [];
    ## Reset found interfaces for re-testing in the next call. Add interfaces if needed.
    chkintf = [];
  else
    ## From here on xwrite is tracked via xls.changed in the various lower
    ## level r/w routines
    xls.changed = xwrite;

    ## xls.changed = 0 (existing/only read from), 1 (existing/data added), 2 (new,
    ## data added) or 3 (pristine, no data added).
    ## Until something was written to existing files we keep status "unchanged".
    if (xls.changed == 1)
      xls.changed = 0;
    endif
  endif

endfunction


function fname = mtchext (fname, prefext)

  ## In case of multiple files with same name, pick the one with preferred ext.
  flist = {dir([fname ".*"]).name};
  exts = cell2mat (cell2mat (regexpi (flist, '.*(\.\w+$)', "tokens")));
  ## Get first matching file extension. ismember() arg order = vital!
  extm = find (ismember (prefext, exts));
  if (! isempty (extm))
    fname = flist(extm);
  else
    fname = [fname prefext{1}];
  endif

endfunction
