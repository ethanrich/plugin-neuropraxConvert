## Copyright (C) 2008 Bill Denney <bill@denney.ws>
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
## @deftypefn  {Function File} {[@var{num}, @var{str}] =} month (@var{date})
## @deftypefnx {Function File} {[@dots{}] =} month (@var{date}, @var{f})
## Return month of a date.
##
## For a given @var{date} in a serial date number or date string format,
## returns its month number (@var{num}) or 3 letter name (@var{str}).
##
## The optional variable @var{f}, specifies the format string used to
## interpret date strings.
##
## @seealso{date, datevec, now, day, year}
## @end deftypefn

function [num, str] = month (varargin)

  if (nargin < 1 || nargin > 2)
    print_usage ();
  elseif (nargin >= 2 && ! ischar (varargin{2}))
    error ("month: F must be a string");
  endif

  num = datevec (varargin{:})(:,2);
  str = datestr ([0 num 0 0 0 0], "mmm");

endfunction

%!assert (nthargout (1:2, @month, 523383), {12 "Dec"});
%!assert (nthargout (1:2, @month, "12-02-34", "mm-dd-yy"), {12 "Dec"});

