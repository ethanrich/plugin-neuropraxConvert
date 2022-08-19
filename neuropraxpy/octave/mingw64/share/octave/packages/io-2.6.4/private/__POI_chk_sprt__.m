## Copyright (C) 2014-2021 Philip Nienhuis
## 
## This program is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or
## (at your option) any later version.
## 
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
## 
## You should have received a copy of the GNU General Public License
## along with this program.  If not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*- 
## @deftypefn {Function File} {@var{vargout} =} __POI_chk_sprt__ (@var{varargin})
## Undocumented internal function
##
## @seealso{}
## @end deftypefn

## Author: Philip Nienhuis <prnienhuis@users.sf.net>
## Created: 2014-10-31

function [chk, missing1, missing2] = __POI_chk_sprt__ (jcp, dbug=0)

  chk = 0;
  ## First Check basic .xls (BIFF8) support
  if (dbug > 1)
    printf ("\nBasic POI (.xls) <poi-3> <poi-ooxml>:\n");
  endif
  ## Below entries1 order = vital
  entries1 = {{"apache-poi.", "poi-3", "poi-4"}, {"apache-poi-ooxml.", "poi-ooxml-3", "poi-ooxml-4"}};
  ## Only under *nix we might use brute force: e.g., strfind (javaclasspath, classname)
  ## as javaclasspath is one long string. Under Windows however classpath is a cell array
  ## so we need the following more subtle, platform-independent approach:
  [jpchk1, missing1] = chk_jar_entries (jcp, entries1, dbug);
  missing1 = entries1 (find (missing1));
  if (jpchk1 >= numel (entries1))
    chk = 1;
    if (dbug > 1)
      printf ("  => Apache (POI) OK\n");
    endif
  elseif (dbug > 1);
      printf ("  => Not all classes (.jar) required for POI in classpath\n");
  endif

  ## Next, check OOXML support
  if (dbug > 1)
    printf ("\nPOI OOXML (.xlsx) <xbean/xmlbean> <poi-ooxml-schemas> <dom4j>:\n");
  endif
  entries2 = {{"xbean", "xmlbean"}, {"apache-poi-ooxml-schemas", ...
              "poi-ooxml-schemas"}, "dom4j", "commons-collections4", ...
              "commons-compress-1.18"};
  [jpchk2, missing2] = chk_jar_entries (jcp, entries2, dbug);
  missing2 = entries2 (find (missing2));
  ## Check if common-collections4 is req'd (only for POI >= 3.15)
  try         ## ...cause POI may not yet be in the javaclasspath ...
    poiv = javaObject ("org.apache.poi.Version").getVersion();
    if (compare_versions (poiv, "3.14", "<=") && ...
        strncmpi (missing2, "commons-collections4", 8))
      ## Remove commons-collections from missing2
      ic = find (cellfun (@ischar, missing2));
      id = find (strncmpi ("commons-collections4", missing2(ic), 20));
      missing2(ic(id)) = [];
      jpchk2++;
      if (dbug > 2)
        printf ("  commons-collections4 not needed for POI <= 3.14\n");
      endif
    endif
    if (compare_versions (poiv, "4.0", "<=") && ...
        strncmpi (missing2, "commons-compress", 8))
      ## Remove commons-compress from missing2
      ic = find (cellfun (@ischar, missing2));
      id = find (strncmpi ("commons-compress", missing2(ic), 16));
      missing2(ic(id)) = [];
      jpchk2++;
      if (dbug > 2)
        printf ("  commons-compress not needed for POI <= 3.14\n");
      endif
    endif
  end_try_catch

  if (jpchk2 >= numel (entries2))
    ## Only bump chk if basic classes were all found
    if (chk)
      ++chk;
    endif
    if (dbug > 1)
      printf ("  => POI OOXML OK\n");
    endif
  elseif (dbug > 1)
      printf ("  => Some classes for POI OOXML support missing\n"); 
  endif

endfunction
