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
## @deftypefn {Function File} {@var{retval} =} __OXS_getnmranges__ (@var{input1}, @var{input2})
##
## @seealso{}
## @end deftypefn

## Author: Philip Nienhuis <prnienhuis@users.sf.net>
## Created: 2015-09-20

function [nmr] = __OXS_getnmranges__ (xls)

  rnms = xls.workbook.getNamedRanges ();
  nmr = cell (numel (rnms), 3);
  for ii=1:numel (rnms)
    nmr{ii, 1} = char (rnms(ii));
    rng = char ((rnms(ii).getCellRanges ())(1));
    nmr{ii, 2} = rng(1:index (rng, "!") - 1);
    nmr{ii, 3} = strrep (rng(index (rng, "!") + 1 : end), "$", "");
  endfor

endfunction
