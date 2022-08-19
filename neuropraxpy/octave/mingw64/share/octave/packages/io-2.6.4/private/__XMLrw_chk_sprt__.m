## Copyright (C) 2015-2021 Philip Nienhuis
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
## @deftypefn {Function File} {@var{retval} =} __XMLrw_chk_sprt__ (@var{input1}, @var{input2})
##
## @seealso{}
## @end deftypefn

## Author: Philip Nienhuis <prnienhuis@users.sf.net>
## Created: 2015-11-03

function [chk, missing] = __XMLrw_chk_sprt__ (jcp, dbug=0)

  chk = 0;
  if (dbug > 2)
    printf ("xerces:\n");
  endif
  ## We need xerces and one of xml-apis/xml-commons-apis
  entries = {"xerces", {"xml-apis", "xml-commons-apis"}}; 
  [jpchk, missing] = chk_jar_entries (jcp, entries, dbug);
  missing = entries (find (missing));
  ## Check xerces version (2.11.0+ needed)
  try
    xvsn = javaMethod ("getVersion", "org.apache.xerces.impl.Version");
    ## Get version string proper
    xvsn = cell2mat (cell2mat (regexp (xvsn, '(\d+\.\d+\.\d+)', 'tokens')));
    if (compare_versions (xvsn, "2.11.0", ">=") && isempty (missing))
      chk = (jpchk == numel (entries));
    endif
    if (dbug > 2)
      printf ("  xerces version:          %s\n", xvsn);
    endif
  catch
  end_try_catch

endfunction
