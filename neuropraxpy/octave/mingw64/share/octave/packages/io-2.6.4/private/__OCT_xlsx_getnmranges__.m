## Copyright (C) 2015-2020 Andreas Weber
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
## @deftypefn {Function File} {@var{retval} =} __OCT_getnmranges__ (@var{input1}, @var{input2})
##
## @seealso{}
## @end deftypefn

## Author: Andreas Weber
## Created: 2015-09-18

function [nmranges] = __OCT_xlsx_getnmranges__ (xls)

  fid = fopen (fullfile (xls.workbook, "xl", "workbook.xml"), "r");
  axml = fread (fid, Inf, "char=>char").';
  fclose (fid);

  ## Get named range nodes
  [axml] = getxmlnode (axml, "definedNames", 1, 1);
  ## Preallocate
  nmranges = cell (numel (strfind (axml, "</definedName>")), 4);

  en = 1;
  ## Loop over definedName
  for ii=1:size (nmranges, 1)
    [node, ~, en] = getxmlnode (axml, "definedName", en);
    ## Range name from attr
    nmranges{ii, 1} = getxmlattv (node, "name");
    ## Range scope from attr. Postprocess later
    nmranges{ii, 4} = getxmlattv (node, "localSheetId");
    ## Sheet and range (node contents)
    ref = getxmlnode (node, "definedName", 1, 1);
    ind = index (ref, "!");
    nmranges{ii, 2} = ref(1:ind-1);
    nmranges{ii, 3} =  strrep (ref(ind+1:end), "$", "");
  endfor

endfunction
