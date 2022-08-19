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
## @deftypefn {Function File} {@var{varargout} =} __OXS_chk_sprt__ (@var{varargin})
## Undocumented internal function
##
## @seealso{}
## @end deftypefn

## Author: Philip Nienhuis <prnienhuis@users.sf.net>
## Created: 2014-10-31

function [chk, missing4] = __OXS_chk_sprt__ (jcp, dbug=0)

  chk = 0;
  if (dbug > 1)
    printf ("\nOpenXLS (.xls - BIFF8 & .xlsx - OOXML) <OpenXLS>:\n");
  endif
  entries4 = {"OpenXLS", "gwt-servlet-deps"}; 
  [jpchk, missing4] = chk_jar_entries (jcp, entries4, dbug);
  missing4 = entries4 (find (missing4));
  if (jpchk >= numel (entries4))
    ## Check OpenXLS.jar version
    chk = 1;
    try
      ## ...a method that is first introduced in OpenXLS v.10
      oxsvsn = javaMethod ("getVersion", "com.extentech.ExtenXLS.GetInfo");
      ## If we get here, we do have v. 10
      if (dbug > 2)
        printf ("  OpenXLS version:         %s\n", oxsvsn);
      endif
      if (dbug > 1)
        if (jpchk >= numel (entries4))
          printf ("  => Java/OpenXLS (OXS) OK.\n");
        else
          printf ("  => Not all required classes (.jar) for OXS in classpath\n");
        endif
      endif
    catch
      ## Wrong OpenXLS.jar version (probably <= 6.08). v. 10 is required now
      chk = -1;
      warning ("OpenXLS.jar version is outdated; please upgrade to v.10\n");
    end_try_catch
 endif

endfunction
