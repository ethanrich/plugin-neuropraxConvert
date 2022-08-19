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
## @deftypefn {Function File} {@var{nmr} =} getnmranges (@var{xls})
## Get named ranges from spreadsheet pointed to in spreasheet file ptr xls
##
## @seealso{}
## @end deftypefn

## Author: Philip Nienhuis <prnienhuis@users.sf.net>
## Created: 2015-09-18

function [nmranges] = getnmranges (xls)

  intf = xls.xtype;
  switch intf
    case "COM"
      nmranges = __COM_getnmranges__ (xls);
    case "POI"
      nmranges = __POI_getnmranges__ (xls);
    case "JXL"
      nmranges = __JXL_getnmranges__ (xls);
    case "OXS"
      nmranges = __OXS_getnmranges__ (xls);
    case "UNO"
      nmranges = __UNO_getnmranges__ (xls);
    case "OTK"
      nmranges = __OTK_getnmranges__ (xls);
    case "JOD"
      nmranges = __JOD_getnmranges__ (xls);
    case "OCT"
      nmranges = __OCT_getnmranges__ (xls);
    otherwise
      error "(This error shouldn't happen, please enter bug report");
  endswitch

  ## Remove quotes from sheet names with spaces
  nmranges(:, 2) = regexprep (nmranges(:, 2), "^'?([^'].*[' ]+.*)'$", '$1');

endfunction
