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

## Parse a string representing a range of cells for a spreadsheet
## into nr of rows and nr of columns and also extract top left
## cell address + top row + left column. Some error checks are implemented.

## Author: Philip Nienhuis <pr.nienhuis at users.sf.net>
## Created: 2009-06-20

function [topleft, nrows, ncols, toprow, lcol] = parse_sp_range (range_org)

  crange = strrep (deblank (upper (range_org)), " ", "");
  range_error = 0; 
  nrows = 0; 
  ncols = 0;

  # Basic checks
  if (index (crange, ":") == 0)
    if (isempty (crange))
      range_error = 0;
      leftcol = "A";
      rightcol = "A";
    else
      # Only upperleft cell given, just complete range to 1x1
      # (needed for some routines)
      crange = [crange ":" crange];
    endif
  endif

  # Split up both sides of the range
  [topleft, lowerright] = strtok (crange, ":");

  # Get toprow and clean up left column
  [st, en] = regexp (topleft, '\d+');
  toprow = str2double (topleft(st:en));
  lcol = col2num (topleft(1:st-1));

  # Get bottom row and clean up right column
  [st, en] = regexp (lowerright, '\d+');
  bottomrow = str2double (lowerright(st:en));
  rcol = col2num (lowerright (2:st-1));

  # Check nr. of rows
  nrows = bottomrow - toprow + 1; 
  if (nrows < 1) 
    range_error = 1; 
  endif

  if (range_error == 0) 
    # Check
    ncols = rcol - lcol + 1;
    if (ncols < 1) 
      range_error = 1; 
    endif
  endif

  if (range_error > 0) 
    ncols = 0; 
    nrows = 0;
    error ("Spreadsheet range error!");
  endif
  
endfunction

## FIXME -- reinstate these tests one there if a way is found to test private
##          functions directly
#%!test
#%! [a b c d e] = parse_sp_range ('A1:B2');
#%! assert ([a b c d e], ['A1', 2, 2, 1, 1]);
#%
#%!test
#%! [a b c d e] = parse_sp_range ('A1:AB200');
#%! assert ([a b c d e], ['A1', 200, 28, 1, 1]);
#%
#%!test
#%! [a b c d e] = parse_sp_range ('cd230:iY65536');
#%! assert ([a b c d e], ['CD230', 65307, 178, 230, 82]);
#%
#%!test
#%! [a b c d e] = parse_sp_range ('BvV12798 : xFd1054786');
#%! assert ([b c d e], [1041989, 14439, 12798, 1946]);
