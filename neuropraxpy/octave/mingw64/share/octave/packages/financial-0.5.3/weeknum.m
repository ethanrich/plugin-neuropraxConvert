## Copyright (C) 2015 Ronald van der Meer
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
## @deftypefn  {Function File} {[@var{n}, @var{y}] =} weeknum (@var{d})
## @deftypefnx {Function File} {[@var{n}, @var{y}] =} weeknum (@var{d}, @var{w})
## @deftypefnx {Function File} {[@var{n}, @var{y}] =} weeknum (@var{d}, @var{w}, @var{e})
## Return the week number of the year of a date
##
## @var{d} is a serial date number or datestring.
##
## @var{w} is (optionally) the day that defines the first day of the week
## (1 is Sunday, 2 is Monday etc.). Default is 1 (Sunday).
##
## @var{e} is a boolean to toggle the "European" definition that the first
## week should contain at least 4 days of the new year. (And hence always
## contains 4th of January).  Default is 0, in which case the first week of
## the year is the week that contains the first day of the year.
##
## Please note that when @var{e} is zero, days in a week that overlap two
## years do not all return the same weeknumber.
##
## @var{y} will be the year in which the week falls.
## When e=0 (default) @var{y} will always be the year of the input date.
## When e=1, the week may be in the next or previous year.
##
## @emph{Note}: In ISO8601 weeks start with Monday. The first week of a year
## is the week that contains at least 4 days (and hence contains the first
## Thursday of the year and also always contains the 4th of January).
## So for an ISO8601 weeknumber use: @code{@var{n} = weeknum (@var{d}, 2, 1)}.
##
## @seealso{datenum, datestr}
## @end deftypefn

function [n, y] = weeknum (d, w = 1, e = false)

  if (nargin < 1 || nargin > 3)
    print_usage ();
  elseif (! isscalar (w) || w < 1 || w > 7)
    error ("weeknum: W must be a scalar between 1 and 7");
  endif

  if (isa (d, "char"))
    d = datenum (d);
  endif

  d = floor (d); # reduce resolution to days

  ## first day of the week considering the week start day in w
  firstdayofweek = d - mod (weekday (d) - w, 7);
  y = year (d);

  if (e)
    firstdayofnextyear = datenum (y + 1, 1, 1);
    ## when week has 3 or less days in this year, so it falls in next year
    inextyear = find ((firstdayofnextyear - firstdayofweek) < 4);
    y(inextyear) = y(inextyear) + 1;

    ## when week has 4 or more days in previous year, so it falls in the
    ## previous year
    iprevyear = find (datenum (y, 1, 1) - firstdayofweek > 3);
    y(iprevyear) = y(iprevyear) - 1;

    ## by "european" definition first week contains the 4th of januari
    dayinfirstweek = datenum (y, 1, 4);
  else
    ## otherwise the first week is defined by the week that contains the
    ## first day of the year
    dayinfirstweek=datenum(y,1,1);
  endif
  firstdayoffirstweek = dayinfirstweek - mod (weekday (dayinfirstweek) - w, 7);

  n = (firstdayofweek - firstdayoffirstweek) / 7 + 1;
endfunction

%!assert (weeknum (728647), 52)
## Test vector inputs for both directions
%!assert (weeknum ([728647 728848]), [52 27])
%!assert (weeknum ([728647 ;728648]), [52 ;52])
%!assert (weeknum ([736413 736813 ; 737213 737613]), [13 17 ; 22 28])

## Tests ISO examples from http://en.wikipedia.org/wiki/ISO_week_date
%!assert (weeknum (datenum (2005, 01, 01), 2, 1), 53)
%!assert (weeknum (datenum (2005, 01, 02), 2, 1), 53)
%!assert (weeknum (datenum (2005, 12, 31), 2, 1), 52)
%!assert (weeknum (datenum (2007, 01, 01), 2, 1), 1)
%!assert (weeknum (datenum (2007, 12, 30), 2, 1), 52)
%!assert (weeknum (datenum (2007, 12, 31), 2, 1), 1)
%!assert (weeknum (datenum (2008, 01, 01), 2, 1), 1)
%!assert (weeknum (datenum (2008, 12, 28), 2, 1), 52)
%!assert (weeknum (datenum (2008, 12, 29), 2, 1), 1)
%!assert (weeknum (datenum (2008, 12, 30), 2, 1), 1)
%!assert (weeknum (datenum (2008, 12, 31), 2, 1), 1)
%!assert (weeknum (datenum (2009, 01, 01), 2, 1), 1)
%!assert (weeknum (datenum (2009, 12, 31), 2, 1), 53)
%!assert (weeknum (datenum (2010, 01, 01), 2, 1), 53)
%!assert (weeknum (datenum (2010, 01, 02), 2, 1), 53)
%!assert (weeknum (datenum (2010, 01, 03), 2, 1), 53)

##A vector which combines next- and previous year exceptions
%!assert (weeknum ([datenum(2005, 1, 1) datenum(2008, 12, 29)], 2, 1), [53 1])

%!test
%! [n, y] = weeknum (datenum (2010, 1, 3), 2, 1);
%! assert ([n y],[53 2009])
##http://www.mathworks.com/help/finance/weeknum.html says weeknum('08-jan-2004',1,1)
##should be 2 but this is not correct occording to their own definition

%!demo
%! d = datenum (2014, 12, 29);
%! [w, y] = weeknum (datenum (2014, 12, 29), 2, 1);
%! disp(['In ISO8601 ' datestr(d) ' is week ' num2str(w) ' of year ' num2str(y)])
%! disp(['Octave default weeknumber for ' datestr(d) ' is ' num2str(weeknum (d))])

