## Copyright (C) 2017-2021 Philip Nienhuis
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
## @deftypefn {Function File} {@var{retval} =} __COM_getnmranges__ (@var{input1}, @var{input2})
##
## @seealso{}
## @end deftypefn

## Author: Philip Nienhuis <prnienhuis@users.sf,net>
## Created: 2015-09-21

function [nmr] = __COM_getnmranges__ (xls)

  wb = xls.workbook;
  names = wb.Names ();
  nmr = cell (0, 3);

  for ii=1:names.Count
    try
      ## Only add Ranges
      rng = strrep (wb.Names(ii).RefersTo, "$", "");
      nmr{end+1, 3} = rng(index (rng, "!")+1:end);
      name = wb.Names(ii).Name;
      nmr{end, 2} = name(1:index (name, "!")-1);
      if (isempty (nmr{end, 2}))
        ## Get sheet name from Range
        nmr{end, 2} = rng(2:index (rng, "!")-1);
      endif
      nmr{end, 1} = name(index(name, "!")+1:end);
    catch
    end_try_catch
  endfor

endfunction
