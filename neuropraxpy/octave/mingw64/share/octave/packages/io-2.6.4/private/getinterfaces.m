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
## <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} @var{interfaces} = getinterfaces (@var{interfaces})
## Get supported Excel .xls file read/write interfaces from the system.
## Each interface for which the corresponding field is set to empty
## will be checked. So by manipulating the fields of input argument
## @var{interfaces} it is possible to specify which
## interface(s) should be checked.
##
## Currently implemented interfaces comprise:
## - ActiveX / COM (native Excel in the background)
## - Java & JExcelAPI (.xls)
## - Java & jOpendocument (.ods, .sxc)
## - Java & ODFtoolkit (.ods)
## - Java & OpenXLS (only JRE >= 1.4 needed) (.xls)
## - Java & Apache POI (.xls, .xlsx)
## - Java & UNO bridge (native OpenOffice.org in background) - EXPERIMENTAL!!
## - native Octave, only for .xlsx (OOXML), .ODS1.2, . gnumeric
##
## Examples:
##
## @example
##   interfaces = getinterfaces (interfaces);
## @end example

## Author: Philip Nienhuis <prnienhuis at users.sf.net>
## Created: 2009-11-29

function [interfaces] = getinterfaces (interfaces, verbose=true)

  ## tmp1 = [] (not initialized), 0 (No Java detected), or 1 (Working Java found)
  persistent tmp1 = [];
  persistent tmp2 = [];
  persistent has_java = [];                           ## Built-in Java support
  persistent jcp;                                     ## Java class path
  persistent uno_1st_time = 0;

  if (isempty (has_java))
    has_java = __have_feature__ ("JAVA");
  endif

  if  (isempty (interfaces.COM) && isempty (interfaces.JXL) ...
    && isempty (interfaces.JOD) && isempty (interfaces.POI) ...
    && isempty (interfaces.OTK) && isempty (interfaces.OXS) ...
    && isempty (interfaces.UNO))
    ## Looks like first call to xlsopen. Check Java support
    if (verbose)
      printf ("Detected interfaces: ");
    endif
    tmp1 = [];
  elseif (isempty (interfaces.COM) || isempty (interfaces.JXL) ...
       || isempty (interfaces.JOD) || isempty (interfaces.POI) ...
       || isempty (interfaces.OTK) || isempty (interfaces.OXS) ...
       || isempty (interfaces.UNO))
    ## Can't be first call. Here one of the Java interfaces may be requested
    if (! tmp1)
      ## Check Java support again
      tmp1 = [];
    elseif (has_java)
      ## Renew jcp (javaclasspath) as it may have been updated since last call
      jcp = javaclasspath ("-all");
      if (isunix && ! iscell (jcp));
        jcp = strsplit (char (jcp), pathsep ());
      endif
    endif
  endif

  ## Check if MS-Excel COM ActiveX server runs (only on Windows!)
  if (ispc && isempty (interfaces.COM))
    interfaces.COM = 0;
    try
      app = actxserver ("Excel.application");
      ## Close Excel. Yep this is inefficient when we need only one r/w action,
      ## but it quickly pays off when we need to do more with the same file
      ## (+, MS-Excel code is in OS cache anyway after this call so no big deal)
      app.Quit();
      delete (app);
      if (verbose)
        printf ("COM; ");
      endif
      ## If we get here, the call succeeded & COM works.
      interfaces.COM = 1;
    catch
      ## COM non-existent. Only print message if COM is explicitly requested (tmp1==[])
      if (! isempty (tmp1) && verbose)
        printf ("ActiveX not working; no Excel installed?\n");
      endif
    end_try_catch
  endif

  if (has_java)
    if (isempty (tmp1))
    ## Check Java support
      [tmp1, jcp] = __chk_java_sprt__ ();
      if (! tmp1)
        ## No Java support found
        tmp1 = 0;
        if (isempty (interfaces.JXL) || isempty (interfaces.JOD)...
          || isempty (interfaces.OTK) || isempty (interfaces.OXS)...
          || isempty (interfaces.POI) || isempty (interfaces.UNO))
          ## Some or all Java-based interface(s) explicitly requested but no Java support
          if (verbose)
            printf (" no Java support found (no Java JRE or JDK ?)");
          endif
        endif
        ## Set Java-based interfaces to 0 anyway as there's no Java support
        interfaces.JOD = 0;
        interfaces.JXL = 0;
        interfaces.OTK = 0;
        interfaces.OXS = 0;
        interfaces.POI = 0;
        interfaces.UNO = 0;
        if (verbose)
          printf ("\n");
        endif
        ## No more need to try any Java interface
        return
      endif
    endif

    ## Try Java & Apache POI
    if (isempty (interfaces.POI))
      interfaces.POI = 0;
      ## Check basic .xls (BIFF8) support
      [chk, ~, missing2] = __POI_chk_sprt__ (jcp);
      if (chk > 0)
        interfaces.POI = chk;
        if (verbose)
          printf ("POI");
          if (isempty (missing2))
            printf (" (& OOXML)");
          endif
          printf ("; ");
        endif
      endif
    endif

    ## Try Java & JExcelAPI
    if (isempty (interfaces.JXL))
      interfaces.JXL = 0;
      chk = __JXL_chk_sprt__ (jcp);
      if (chk)
        interfaces.JXL = 1;
        if (verbose)
          printf ("JXL; ");
        endif
      endif
    endif

    ## Try Java & OpenXLS
    if (isempty (interfaces.OXS))
      interfaces.OXS = 0;
      chk = __OXS_chk_sprt__ (jcp);
      ## Beware of unsupported openxls jar versions (chk must be > 0)
      if (chk >= 1)
        interfaces.OXS = 1;
        if (verbose)
          printf ("OXS; ");
        endif
      endif
    endif

    ## Try Java & jOpenDocument
    if (isempty (interfaces.JOD))
      interfaces.JOD = 0;
      chk = __JOD_chk_sprt__ (jcp);
      if (chk)
        interfaces.JOD = 1;
        if (verbose)
          printf ("JOD; ");
        endif
      endif
    endif

    ## Try Java & ODF toolkit
    if (isempty (interfaces.OTK))
      interfaces.OTK = 0;
      [chk, missing5] = __OTK_chk_sprt__ (jcp);
      ## Beware of unsupported odfdom jar versions
      if (chk >= 1)
        interfaces.OTK = 1;
        if (verbose)
          printf ("OTK; ");
        endif
      endif
    endif

    ## Try Java & UNO
    if (isempty (interfaces.UNO))
      interfaces.UNO = 0;
      chk = __UNO_chk_sprt__ (jcp);
      if (chk)
        interfaces.UNO = 1;
        if (verbose)
          printf ("UNO; ");
        endif
        if (verbose)
          uno_1st_time = min (++uno_1st_time, 2);
        endif
      endif
    endif

  else
    ## Set Java-based interfaces to 0 anyway as there's no Java support
    interfaces.JOD = 0;
    interfaces.JXL = 0;
    interfaces.OTK = 0;
    interfaces.OXS = 0;
    interfaces.POI = 0;
    interfaces.UNO = 0;

  endif

  ## Native Octave. Nothing to check, always supported
  if (isempty (interfaces.OCT))
    interfaces.OCT = 1;
    if (verbose)
      printf ("OCT");
    endif
  endif

  if (verbose)
    printf ("\n");
  endif

  ## ---- Other interfaces here, similar to the ones above.
  ##      Java interfaces should be in the has-java if-block

  ## FIXME the below stanza should be dropped once UNO is stable.
  # Echo a suitable warning about experimental status:
  if (uno_1st_time == 1 && verbose)
    ++uno_1st_time;
    printf ("\nPLEASE NOTE: UNO (=OpenOffice.org-behind-the-scenes) is EXPERIMENTAL\n");
    printf ("After you've opened a spreadsheet file using the UNO interface,\n");
    printf ("xlsclose on that file will kill ALL OpenOffice.org invocations,\n");
    printf ("also those that were started outside and/or before Octave!\n");
    printf ("Trying to quit Octave w/o invoking xlsclose will only hang Octave.\n\n");
  endif

endfunction
