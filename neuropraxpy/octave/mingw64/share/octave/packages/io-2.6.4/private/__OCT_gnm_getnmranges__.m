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
## @deftypefn {Function File} {@var{retval} =} __OCT_gnm_getnmranges__ (@var{input1}, @var{input2})
##
## @seealso{}
## @end deftypefn

## Author: Philip Nienhuis <prnienhuis@users.sf.net>
## Created: 2015-09-19

function [nmr] = __OCT_gnm_getnmranges__ (xls)

  ## Read xml
  fid = fopen (xls.workbook, "r");
  xml = fread (fid, Inf, "char=>char").';
  fclose (fid);

  ## Get gnm:name nodes with value subnodes containing a range.
  ## Whitespace is a dummy token here
  pttrn = '<gnm:name>(\w+)</gnm:name>(\s*)<gnm:value>([\$A-Z0-9:]+?)</gnm:value>';

  ## First workbook scope; that precedes first sheet
  nmr = reshape (cell2mat (regexp (xml(1:xls.sheets.shtidx(1)), pttrn, "tokens")), [], 3);
  if (! isempty (nmr))
    nmr(:, 2) = repmat ("", size (nmr, 1), 1);
  else
    nmr = cell (0, 3);
  endif
  ## Next, for each sheet
  for ii=1:numel (xls.sheets.sh_names)
    st = xls.sheets.shtidx(ii);
    en = xls.sheets.shtidx(ii+1) - 1;
    names = reshape (cell2mat (regexp (xml(st:en), pttrn, "tokens")), [], 3);
    if (! isempty (names))
      names(:, 2) = repmat (xls.sheets.sh_names{ii}, size (names, 1), 1);
      nmr = [nmr ; names];
    endif
  endfor
  nmr(:, 3) = strrep (nmr(:, 3), "$", "");

endfunction
