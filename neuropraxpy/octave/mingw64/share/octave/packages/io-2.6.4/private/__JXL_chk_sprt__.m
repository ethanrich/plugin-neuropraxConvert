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
## @deftypefn {Function File} {@var{varagout} =} __JXL_chk_sprt__ (@var{varargin})
## Undocumented internal function
##
## @seealso{}
## @end deftypefn

## Author: Philip Nienhuis <prnienhuis@users.sf.net>
## Created: 2014-10-31

function [chk, missing3] = __JXL_chk_sprt__ (jcp, dbug=0)

  chk = 0;
  if (dbug > 1)
    printf ("\nJExcelAPI (.xls (incl. BIFF5 read)) <jxl>:\n");
  endif
  entries3 = {"jxl"}; 
  [jpchk, missing3] = chk_jar_entries (jcp, entries3, dbug);
  missing3 = entries3 (find (missing3));
  if (jpchk >= numel (entries3))
    chk = 1;
    if (dbug > 1)
      printf ("  => Java/JExcelAPI (JXL) OK.\n");
    endif
  elseif (dbug > 1)
    printf ("  => Not all required classes (.jar) for JXL in classpath\n");
  endif

endfunction
