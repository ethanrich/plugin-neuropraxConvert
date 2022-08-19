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
## @deftypefn {Function File} {@var{varargout} =} __JOD_chk_sprt__ (@var{varargin})
## Undocumented internal function
##
## @seealso{}
## @end deftypefn

## Author: Philip Nienhuis <prnienhuis@users.sf.net>
## Created: 2014-10-31

function [chk, missing6] = __JOD_chk_sprt__ (jcp, dbug=0)

  chk = 0;
  if (dbug > 1)
    printf ("\njOpenDocument (.ods + experimental .sxc readonly) <jOpendocument>:\n");
  endif
  entries6 = {"jOpenDocument"}; 
  [jpchk, missing6] = chk_jar_entries (jcp, entries6, dbug);
  missing6 = entries6 (find (missing6));
  if (jpchk >= numel(entries6))
    chk = 1;
    if (dbug > 1)
      printf ("  => jOpenDocument (JOD) OK.\n");
    endif
  elseif (dbug > 1)
    printf ("  => Not all required classes (.jar) for JOD in classpath\n");
  endif

endfunction
