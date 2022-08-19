## Copyright (C) 2016-2020 Carnë Draug <carandraug@octave.org>
## Copyright (C) 2011-2021 Philip Nienhuis
##
## This program is free software; you can redistribute it and/or
## modify it under the terms of the GNU General Public License as
## published by the Free Software Foundation; either version 3 of the
## License, or (at your option) any later version.
##
## This program is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
## General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; if not, see
## <http:##www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {} {} __enter_io_package__ ()
## Undocumented internal function of io package.
##
## Search io pkg java jars and add found ones to javaclasspath.
##
## @end deftypefn

## PKG_ADD: __init_io__ ()

function __init_io__ ()
  ## First check if Java support is available
  HAVE_JAVA = isempty (javachk ("jvm"));
  if (HAVE_JAVA)
    ## OK, Java built-in / supported. Check environment var
    userdir = getenv ("OCTAVE_IO_JAVALIBS");
    if (ispc)
      homedir = getenv ("USERPROFILE");
      # (MinGW) assume jar files are in /lib/java 
      libdir = fullfile (OCTAVE_HOME, "lib");
  # elseif (ismac)
  #   ## Who knows where OSX keeps e.g., Apache POI stuff? if it does at all...
    elseif (isunix)
      homedir = tilde_expand ("~");
      ## On linux, spreadsheet .jars are often found somewhere in /usr/share/java
      libdir = "/usr/share";
    else
      ## Set libdir to "." to avoid searching in a root dir
      libdir = ".";
    endif

    ## Do we have a 64-bit indexing Octave at hand?
    ## (thanks to Markus Muetzel for the suggestion to try MAXSIZE)
    [~, maxsize] = computer ();
    amd64y = maxsize > 2^31 - 1;

    ## Find LibreOffice or OpenOffice.org
    ooopath = "";
    ## Possible locations for  OOo or LO.
    bnam = {"C:/Program Files (X86)", ...
                 "C:/Program Files", ...
                 "C:/Programs", ...
                 "/opt", ...
                 "/usr/lib"};
    if (amd64y)
      ## 64-bit indexing Octave won't work with 32-bit LibreOffice/OpenOffice.org
      bnam(1) = [];
    endif
    ii = 0;
    while (isempty (ooopath) && ii < numel (bnam))
      ooopath = glob ([ bnam{++ii} "/[Ll]ibre[Oo]ffice*"]);
      ## Watch out for uninstalled previous LO installations that just keep prefs
      if (! isempty (ooopath) && ! (exist ([ooopath{1} filesep "program"]) == 7))
        ooopath = "";
      endif
    endwhile
    ii = 0;
    while (isempty (ooopath) && ii < numel (bnam))
      ooopath = glob ([ bnam{++ii} "/[Oo]pen[Oo]ffice.org*"]);
      ## Watch out for uninstalled previous OOo installations that just keep prefs
      if (! isempty (ooopath) && ! (exist ([ooopath{1} filesep "program"]) == 7))
        ooopath = "";
      endif
    endwhile
    ii = 0;
    while (isempty (ooopath) && ii < numel (bnam))
      ooopath = glob ([ bnam{++ii} "/ooo*"]);
      ## Watch out for uninstalled previous OOo installations that just keep prefs
      if (! isempty (ooopath) && ! (exist ([ooopath{1} filesep "program"]) == 7))
        ooopath = "";
      endif
    endwhile
    if (! isempty (ooopath))
      ooopath = ooopath{:};
    else
      ooopath = "";
    endif

    ## One big try-catch to circumvent possible problems on Linux
    try
      if (! isempty (userdir))
        if (strcmpi (userdir, "no") || strcmpi (userdir, "false") || strcmpi (userdir, "0"))
          ## Do not load Java class libs .jar files). First clean up, then return
          clear libdir spr_status userdir homedir bnam ooopath ii;
          return
        endif
        ## First allow some time for io package to be fully loaded
        pause (0.25);
        ## Check first for user-, then system supplied jars
        if (exist (userdir) == 7)
          ## Userdir is a subdir
          spr_status = chk_spreadsheet_support (userdir, 0, ooopath);
        endif
        ## Also try user's home directory
      elseif (isunix && ...
        ! (strcmpi (userdir, "no") || strcmpi (userdir, "false") || strcmpi (userdir, "0")))
        ## On non-Windows systems, automatic loading of Java classes is opt-in due to
        ## excessive search time (see bug #42044). Most of the delay is due to searching
        ## for the Libre/OpenOffice.org jars
        clear libdir spr_status userdir homedir bnam ooopath ii HAVE_JAVA amd64y;
        return
      else
        ## Allow some time for io package to be fully loaded
        pause (0.25);
      endif
      ## Try <HOME>/java
      spr_status = chk_spreadsheet_support ([ homedir filesep "java" ], 0, ooopath);
      ## Only then search for system-supplied jars. ooopath has been searched
      spr_status = chk_spreadsheet_support ([ libdir filesep "java" ], 0);
    catch
      warning ("(Automatic loading of spreadsheet I/O Java classlibs failed)\n");
    end_try_catch
  endif

endfunction
