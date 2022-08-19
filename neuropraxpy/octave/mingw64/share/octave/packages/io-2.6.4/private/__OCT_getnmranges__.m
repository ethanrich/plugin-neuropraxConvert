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

## Author: Philip Nienhuis <prnienhuis@users.sf.net>
## Created: 2015-09-18

function [nmranges] = __OCT_getnmranges__ (xls)

  [~, ~, ext] = fileparts (xls.filename);
  switch ext
    case ".xlsx"
      nmranges = __OCT_xlsx_getnmranges__ (xls);
    case ".ods"
      nmranges = __OCT_ods_getnmranges__ (xls);
    case ".gnumeric"
      nmranges = __OCT_gnm_getnmranges__ (xls);
    otherwise
      error ("This should not happen - pls file bug report");
  endswitch

endfunction
