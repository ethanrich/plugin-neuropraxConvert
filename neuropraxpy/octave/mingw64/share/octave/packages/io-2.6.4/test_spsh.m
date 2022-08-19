## Copyright (C) 2013-2021 Philip Nienhuis
##
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or
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
## @deftypefn {Function File}  [ @var{void} ] = test_sprdsh ()
## @deftypefnx {Function File}  [ @var{void} ] = test_sprdsh (@var{verbose})
## Test functionality of supported spreadsheet interfaces.
##
## test_spsh tests simply tests all interfaces that are found to be
## supported by chk_spreadsheet_support() function, one by one.
## It invokes the function io_testscript.m for the actual testing.
##
## As it is meant to be used interactively, no output arguments
## are returned.
##
## @seealso {io_testscript}
##
## @end deftypefn

## Author: Philip Nienhuis <prnienhuis@users.sf.net>
## Created: 2013-04-21

function [] = test_spsh (verbose = false)

  persistent intfs = {"com", "poi", "oox", "jxl", "oxs", "otk", "jod", "uno"};

  page_screen_output (0, "local");

  ## Get available interfaces
  avail_intf = uint16 (chk_spreadsheet_support ());
  rslts = cell (0, 11);

  ## Check all interfaces
  intf2 = "";
  for ii = 1:numel (intfs)
    try
      intfpatt = bitset (uint16 (0), ii, 1);## uint16 so more intfs can be added
      intfchk = bitand (intfpatt, avail_intf);
      intf = [];
      fname = "io-test.xls";
      switch intfchk
        case 1                            ## COM (ActiveX / hidden MS-Excel)
          intf = intf2 = "com";
        case 2                            ## POI (Apache POI)
          intf = "poi";
          tst_oct = 1;
        case 4                            ## POI/OOXML (Apache POI)
          intf = intf2 = "poi";
          fname = "io-test.xlsx";
        case 8                            ## JXL (JExcelAPI)
          intf = "jxl";
        case 16                           ## OXS (OpenXLS/ Extentech)
          intf = "oxs";
        case 32                           ## OTK (ODF Toolkit)
          intf = intf2 = "otk";
          fname = "io-test.ods";
        case 64                           ## JOD (jOpenDocument)
          intf = intf2 = "jod";
          fname = "io-test.ods";
        case 128                          ## UNO (LibreOffice Java-UNO bridge)
          intf = intf2 = "uno";           ## .xls
        otherwise
      endswitch
      ## If present, test selected interfaces
      if (! isempty (intf))
        printf ("\nInterface \"%s\" found.\n", upper (intf));
        rslts = [rslts ; io_testscript(intf, fname, "", verbose)];
        if (intfchk == 128)
          ## Check UNO also for .xlsx and .ods
          intf = intf2 = "uno";
          fname = "io-test.xlsx";
          rslts = [rslts ; io_testscript(intf, fname, "", verbose)];
          intf = intf2 = "uno";
          fname = "io-test.ods";
          rslts = [rslts ; io_testscript(intf, fname, "", verbose)];
        endif
      endif
    catch
      printf ("\n======== Oops, error with interface %s ========\n\n", ...
              upper (intf));
    end_try_catch
    ## Allow the OS some time for cleaning up
    pause (0.25);
  endfor
  ## Test OCT interface for xlsx
  rslts = [rslts; io_testscript("OCT", "io-test.xlsx", "", verbose)];
  ## Test OCT interface for ods
  rslts = [rslts; io_testscript("OCT", "io-test.ods", "", verbose)];
  ## Test OCT interface for gnumeric
  rslts = [rslts; io_testscript("OCT", "io-test.gnumeric", "", verbose)];

  tstmsg = {"Numeric array p.1: ",...
            "Numeric array p.2: ",...
            "Numeric array p.3: ",...
            "Numeric array p.4: ",...
            "Cellstr array p.1: ",...
            "Cellstr array p.2: ",...
            " ...special chars: ",...
            "Boolean value    : ",...
            "Formula read back: "};
  printf   ("\nInterface:         ");
  for jj=1:size (rslts, 1)
    printf (" %s ", rslts{jj, 1});
  endfor
  printf ("\nFile type          ")
  for jj=1:size (rslts, 1)
    printf ("%4s ", rslts{jj, 11}(2:end));
  endfor
  for ii=1:9
    printf ("\n%s", tstmsg{ii});
    for jj=1:size (rslts, 1)
      printf (" %2s  ", rslts{jj, ii+1});
    endfor
  endfor
  printf ("\n  +  = correct result returned\n");
  printf (  "  o  = partly correct (e.g., double rather than logical)\n");
  printf (  "  -  = erroneous or no result.\n");
  printf ("\n- End of test_spsh -\n");

endfunction
