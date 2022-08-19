## Copyright (C) 2008 Thomas Treichl <thomas.treichl@gmx.net>
## Copyright (C) 2013 Carnë Draug <carandraug@octave.org>
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

## -*- texinfo -*-
## @deftypefn  {Function File} {} ascii ()
## @deftypefnx {Function File} {} ascii (@var{columns})
## Print ASCII table.
##
## If this function is called without any input argument and without any output
## argument then prints a nice ASCII-table (excluding special characters with
## hexcode 0x00 to 0x20).  The input argument @var{columns} specifies the
## number of columns and defaults to 4.
##
## If it is called with one output argument then return the ASCII table as
## a string without displaying anything.  Run @code{demo ascii} for examples.
##
## @seealso{char, isascii, toascii}
## @end deftypefn

function table = ascii (vcol = 4)

  if (nargin > 1)
    print_usage ();
  elseif (! isnumeric (vcol) || ! isscalar (vcol) ||
          fix (vcol) != vcol || vcol < 1)
    error ("ascii: COLUMNS must be a positive integer");
  endif

  ## First char is #32 (0x20) and last char is #128 (0x80)
  voff = floor ((128 - 32) / vcol);

  ## Print a first row for the and underline that row
  vtab = [repmat(" Dec Hex Chr ", [1 vcol])
          repmat("-------------", [1 vcol])];

  ## Create the lines and columns of the asci table
  for vpos = 32:(32+voff)
    vline = "";
    for vcnt = 1:vcol
      vact  = (vcnt-1)*voff+vpos;
      vstr  = {num2str(vact), dec2hex(vact), char(vact)};
      vline = [vline sprintf(" %3s", vstr{1:length (vstr)}) " "];
    endfor
    vtab = [vtab; vline];
  endfor

  ## Print table to screen or return it to output argument
  if (nargout == 0)
    display (vtab);
  else
    table = vtab;
  endif
endfunction

%!demo
%! ## Display pretty table of conversion between ASCII, decimal and hexadecimal
%! ascii ()

%!demo
%! ## Display 6 columns table of conversion between ASCII, decimal and hexadecimal
%! ascii (6)

%!demo
%! ## Return a string with a pretty formatted table (but don't display it)
%! table = ascii (1)
%! display (table (65, :));

%!test
%! str = ascii (5);
%! assert (str(1,:), " Dec Hex Chr  Dec Hex Chr  Dec Hex Chr  Dec Hex Chr  Dec Hex Chr ");
%! assert (str(4,:), "  33  21   !   52  34   4   71  47   G   90  5A   Z  109  6D   m ");

%!test
%! str = ascii (1);
%! assert (str(1,:), " Dec Hex Chr ");
%! assert (str(6,:), "  35  23   # ");

%!error <positive> ascii (0)
%!error <integer>  ascii (4.5)
%!error <COLUMNS>  ascii ("dec")
