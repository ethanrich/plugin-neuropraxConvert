## Copyright (C) 2008 Bill Denney <bill@denney.ws>
## Copyright (C) 2013, 2015 Carnë Draug <carandraug@octave.org>
## Copyright (C) 2015 Ronald van der Meer <revdmeer@gmail.com>
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
## @deftypefn  {Function File} {} year (@var{date})
## @deftypefnx {Function File} {} year (@var{date}, @var{f})
## Return year of a date.
##
## For a given @var{date} in a serial date number or date string format,
## returns its year.  The optional variable @var{f}, specifies the
## format string used to interpret date strings.
##
## @seealso{date, datevec, now, day, month}
## @end deftypefn

function t = year (varargin)

  if (nargin < 1 || nargin > 2)
    print_usage ();
  elseif (nargin >= 2 && ! ischar (varargin{2}))
    error ("year: F must be a string");
  endif

  t = datevec (varargin{:})(:,1);

  if (! isa (varargin{1}, "char"))
    t = reshape (t, size (varargin{1}));
  endif
endfunction

%!assert (year (523383), 1432);
%!assert (year ("12-02-34", "mm-dd-yy"), 2034);

## Test that we keep the same as the input
%!assert (year ([728647 728848]), [1994 1995]);
%!assert (year ([728647; 728848]), [1994; 1995]);

## test cell array of strings with different sizes
%!assert (year ({"12-02-34", "12-02-85"}, "mm-dd-yy"), [2034 1985]);
%!assert (year ({"12-02-34"; "12-02-85"}, "mm-dd-yy"), [2034; 1985]);

