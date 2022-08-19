## Copyright (C) 2008 Bill Denney <bill@denney.ws>
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
## @deftypefn {[@var{data} @var{fields}] =}
##  fetch_yahoo (@var{conn}, @var{symbol}, @var{fromdate}, @var{todate}, @var{period})
##
## Download stock data from yahoo. (Helper for fetch.)
##
## @var{fields} are the data fields returned by Yahoo.
##
## @var{fromdate} and @var{todate} is the date datenum for the requested
## date range.  If you enter today's date, you will get yesterday's
## data.
##
## @var{period} (default: "d") allows you to select the period for the
## data which can be any of
## @itemize
## @item 'd': daily
## @item 'w': weekly
## @item 'm': monthly
## @item 'v': dividends
## @end itemize
##
## @seealso{yahoo, fetch}
## @end deftypefn

## FIXME: Actually use the proxy info if given in the connection.
## FIXME: Do not ignore the fields input.

function [data fields] = fetch_yahoo (conn=[], symbol="",
                                          fromdate, todate, period="d")

  error ("Yahoo! Finance no longer supports downloading stock data");

  pkg load io;

  if strcmpi (conn.url, "http://quote.yahoo.com")
    fromdate = datevec (fromdate);
    todate   = datevec (todate);
    geturl   = sprintf (["http://ichart.finance.yahoo.com/table.csv" ...
                         "?s=%s&d=%d&e=%d&f=%d&g=%s&a=%d&b=%d&c=%d&" ...
                         "ignore=.csv"],
                         symbol, todate(2)-1, todate(3), todate(1),
                         period,
                         fromdate(2)-1, fromdate(3), fromdate(1));
    disp(geturl);
    ## FIXME: This would be more efficient if csv2cell could work on
    ## strings instead of files.
    [f, success, msg] = urlwrite (geturl, tmpnam ());
    if ! success
      error ("Could not write Yahoo data to tmp file:\n%s", msg)
    endif
    d = csv2cell (f);
    unlink(f);
    ## Pull off the header
    fields = d(1,:);
    d(1,:) = [];
    dates  = strvcat (d(:,1));
    dates  = datenum(str2num(dates(:,1:4)),
                     str2num(dates(:,6:7)),
                     str2num(dates(:,9:10)));
    data   = [dates, cell2mat(d(:,2:end))];
  else
    error ("Non-yahoo connection passed to yahoo fetch")
  endif

endfunction

