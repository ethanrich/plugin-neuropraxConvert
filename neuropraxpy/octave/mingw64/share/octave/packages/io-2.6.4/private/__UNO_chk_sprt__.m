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
## @deftypefn {Function File} {@var{varargout} =} __UNO_chk_sprt__ (@var{varargin})
## Undocumented internal function
##
## @seealso{}
## @end deftypefn

## Author: Philip Nienhuis <prnienhuis@users.sf.net>
## Created: 2014-10-31

function [chk, missing0] = __UNO_chk_sprt__ (jcp, dbug=0)

  chk = 0;

  ## entries0(1) = not a jar but a directory (<000_install_dir/program/>)
  entries0 = {"program", "unoil", "jurt", "juh", "unoloader", "ridl"};
  
  if (dbug > 1)
    printf ("\nUNO/Java (.ods, .xls, .xlsx, .sxc) <OpenOffice.org>:\n");
  endif
  [jpchk, missing0] = chk_jar_entries (jcp, entries0, dbug);
  missing0 = entries0 (find (missing0));
  if (jpchk >= numel (entries0))
    chk = 1;
    if (dbug > 1)
      printf ("  => UNO (OOo) OK\n");
    endif
  elseif (dbug > 1)
    printf ("  => One or more UNO classes (.jar) missing in javaclasspath\n");
  endif

  ## No additional checks required

endfunction
