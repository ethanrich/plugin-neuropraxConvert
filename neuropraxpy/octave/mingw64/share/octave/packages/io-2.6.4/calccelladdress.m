## Copyright (C) 2009-2021 Philip Nienhuis
##
## This program is free software; you can redistribute it and/or modify it under
## the terms of the GNU General Public License as published by the Free Software
## Foundation; either version 3 of the License, or (at your option) any later
## version.
##
## This program is distributed in the hope that it will be useful, but WITHOUT
## ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
## FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
## details.
##
## You should have received a copy of the GNU General Public License along with
## this program; if not, see <http://www.gnu.org/licenses/>.

## calccelladdress (R, C) - compute spreadsheet style cell address from
## row & column index (both 1-based).
## 
## Max column index currently set to 18278 (max ODS: 1024, OOXML: 16384).
## Row limits for ODF and OOXML are 65536 and 1048576, resp.

## Author: Philip Nienhuis <prnienhuis at users.sf.net>
## Created: 2009-12-12

function [ celladdress ] = calccelladdress (row, column)

  if (nargin < 2)
    error ("calccelladdress: Two arguments needed");
  endif

  if (column > 18278 || column < 1)
    error ("calccelladdress: specified column out of range (1..18278)");
  endif
  if (row > 1048576 || row < 1)
    error ("calccelladdress: specified row out of range (1..1048576)");
  endif

  celladdress = sprintf ("%s%d", num2col (column), row);

endfunction

%!test
%! a = calccelladdress (1, 1);
%! assert (a, "A1");

%!test
%! a = calccelladdress (378, 28);
%! assert (a, "AB378");

%!test
%! a = calccelladdress (65536, 1024);
%! assert (a, "AMJ65536");

%!test
%! a = calccelladdress (1048576, 16384);
%! assert (a, "XFD1048576");

%!test
%! a = calccelladdress (378, 26);
%! assert (a, "Z378");

%!test
%! a = calccelladdress (378, 702);
%! assert (a, "ZZ378");

%!test
%! a = calccelladdress (378, 701);
%! assert (a, "ZY378");

%!test
%! a = calccelladdress (378, 703);
%! assert (a, "AAA378");

%!test
%! a = calccelladdress (378, 676);
%! assert (a, "YZ378");
