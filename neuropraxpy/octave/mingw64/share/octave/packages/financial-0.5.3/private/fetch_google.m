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
##  fetch_google (@var{conn}, @var{symbol}, @var{fromdate}, @var{todate}, @var{period})
##
## Download stock data from google. (Helper for fetch.)
##
## @var{fields} are the data fields returned by Google.
##
## @var{fromdate} and @var{todate} is the date datenum for the requested
## date range.  If you enter today's date, you will get yesterday's
## data.
##
## @var{period} (default: "d") allows you to select the period for the
## data which can be any of
## @itemize
## @item 'd': daily
## @end itemize
##
## @seealso{google, fetch}
## @end deftypefn

## FIXME: Actually use the proxy info if given in the connection.
## FIXME: Do not ignore the fields input.

function [data fields] = fetch_google (conn=[], symbol="",
                                          fromdate, todate, period="d")

  error ("Google Finance no longer supports downloading stock data");

  pkg load io;

  if strcmpi(period, "w")
    error("Google Financial no longer supports weekly stock data");
  endif
  periods = struct("d", "daily");
  if strcmpi (conn.url, "http://finance.google.com")
    fromdatestr = datestr (fromdate);
    todatestr   = datestr (todate);
    ## http://finance.google.com/finance/historical?q=T&startdate=Sep+1%2C+2007&enddate=Aug+31%2C+2008&histperiod=weekly&output=csv
    geturl = sprintf (["http://finance.google.com/finance/" ...
                       "historical?" ...
                       "q=%s&startdate=%s&enddate=%s&" ...
                       "histperiod=%s&output=csv"],
                      symbol, fromdatestr, todatestr, periods.(period));
    ## FIXME: This would be more efficient if csv2cell could work on
    ## strings instead of files.
    [f, success, msg] = urlwrite (geturl, tmpnam ());
    if ! success
      error (["Could not write Google data to tmp file:" ...
              "\n%s\nURL was:\n%s"], msg, geturl)
    endif
    d = csv2cell (f);
    d{1,1} = d{1,1}(4:end); # Remove byte order mark (BOM)
    unlink (f);
    ## Pull off the header
    fields = d(1,:);
    d(1,:) = [];
    ## Put the dates into datenum format
    dates = datenum (datevec (d(:,1), "dd-mmm-yy"));
    ternary = @(c, varargin) varargin{2-logical(c)};
    filtered = cellfun (@(x) ternary(x == "-", NaN, x), d(:, 2:end));
    data = [dates, filtered];
    ## Note that google appears to have an off-by-one error in
    ## returning historical data, so make sure that we only return the
    ## requested data and not what Google sent.
    data((data(:,1) < fromdate) | (data(:,1) > todate), :) = [];
  else
    error ("Non-google connection passed to google fetch")
  endif

endfunction

