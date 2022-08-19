## Copyright (C) 2017 dekalog (https://dekalogblog.blogspot.com)
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
## @deftypefn  {Function File} candle (@var{HighPrices}, @var{LowPrices}, @var{ClosePrices}, @var{OpenPrices})
## @deftypefnx {Function File} candle (@var{HighPrices}, @var{LowPrices}, @var{ClosePrices}, @var{OpenPrices}, @var{color})
## @deftypefnx {Function File} candle (@var{HighPrices}, @var{LowPrices}, @var{ClosePrices}, @var{OpenPrices}, @var{color}, @var{dates})
## @deftypefnx {Function File} candle (@var{HighPrices}, @var{LowPrices}, @var{ClosePrices}, @var{OpenPrices}, @var{color}, @var{dates}, @var{dateform})
## Plot the @var{HighPrices}, @var{LowPrices}, @var{ClosePrices} and @var{OpenPrices} of a security as a candlestick chart.
##
## @itemize
## @item
## Variable: @var{HighPrices} Column vector of high prices for a security.
## @item
## Variable: @var{LowPrices} Column vector of low prices for a security.
## @item
## Variable: @var{ClosePrices} Column vector of close prices for a security.
## @item
## Variable: @var{OpenPrices} Column vector of open prices for a security.
## @item
## Variable: @var{Color} (Optional, default = "brwk") Candlestick color is
## specified as a case insensitive four character row vector, e.g. "brwk". The
## characters that are accepted are k, b, c, r, m, w, g and y for black, blue,
## cyan, red, magenta, white, green and yellow respectively. Default colors are
## "brwk" applied in order to bars where the closing price is greater than the
## opening price, bars where the closing price is less than the opening price,
## the chart background color and the candlestick wicks. If fewer than four
## colors are specified, they are applied in turn in the above order with
## default colors for unspecified colors. For example, user supplied colors
## "gm" will plot green upbars and magenta downbars with a default white
## background and black wicks. If the user specified color for background is
## black, without specifying the wick color, e.g. "gmk", the default wick color
## is white. All other choices for background color will default to black for
## wicks. If all four colors are user specified, those colors will be used. Doji
## bars and single price bars, e.g. open = high = low = close, are plotted with
## the color for wicks, with single price bars being plotted as points/dots.
## @item
## Variable: @var{Dates} (Optional) Dates for user specified x-axis tick labels.
## Dates can be a serial date number column (see datenum), a datevec matrix (See
## datevec) or a character vector of dates. If specified as either a datenum or
## a datevec, the @var{Dateform} argument is required.
## @item
## Variable: @var{Dateform} (Optional) Either a date character string or a
## single integer code number used to format the x-axis tick labels (See
## datestr). Only required if @var{Dates} is specified as a serial date number
## column (See datenum) or a datevec matrix (See datevec).
## @end itemize
##
## @seealso{datenum, datestr, datevec, highlow, bolling, dateaxis, movavg,
## pointfig}
## @end deftypefn

function candle (varargin)

  ## Input checking
  if (nargin < 4 || nargin > 7)
    print_usage ();
  endif
  HighPrices = varargin{1};
  LowPrices = varargin{2};
  ClosePrices = varargin{3};
  OpenPrices = varargin{4};
  if (nargin == 4)
    color = "brwk";
  endif
  if (nargin >= 5)
    color = varargin{5};
  endif
  if (nargin >= 6)
    dates = varargin{6};
  endif
  if (nargin >= 7)
    dateform = varargin{7};
  endif
  function retval = is_price_vector (prices)
    retval = isnumeric (prices) && isvector (prices) && iscolumn (prices);
  endfunction
  if ( ! (is_price_vector (HighPrices) && is_price_vector (LowPrices) && ...
          is_price_vector (ClosePrices) && is_price_vector (OpenPrices) ) )
    error ("candle: prices must be numeric column vector");
  endif
  num_points = length (HighPrices);
  if ( ! (num_points == length (LowPrices) && ...
          num_points == length (ClosePrices) && ...
          num_points == length (OpenPrices) ) )
    error ("candle: price vectors must be of the same size");
  endif

  ## Make figure
  fig = figure;
  washold = ishold;
  hold on;

  ## Is color a character vector?
  if (ischar (color) && size (color, 1) == 1)
    if (size (color, 2) == 1)                      # only one color has been user specified
      color = [tolower(color) "rwk"];              # so add default colors for down bars, background and wicks
    elseif (size (color, 2) == 2)                  # two colors have been user specified
      color = [tolower(color) "wk"];               # so add default colors for background and wicks
    elseif (size (color, 2) == 3)                  # three colors have been user specified
      if (color(3) == "k" || color(3) == "K")      # if user selected background is black
       color = [tolower(color) "w"];               # set wicks to default white
      else
       color = [tolower(color) "k"];               # else default black wicks
      endif
    elseif (size (color, 2) >= 4)                  # all four colors have been user specified, extra character inputs ignored
      color = tolower (color);                     # correct in case user input contains upper case e.g. "BRWK"
    endif
  else
    warning ("candle: COLOR should be a character row vector; ignoring user input");
    color = "brwk";
  endif                                            # end of nargin >= 5 && ischar (color) && size (color, 1) == 1 if statement

  x = 1 : num_points;
  wicks = HighPrices .- LowPrices;
  body = ClosePrices .- OpenPrices;
  up_down = sign (body);
  scaling = 10 / num_points;
  body_width = max(20 * scaling, 1);
  wick_width = 1;
  doji_size = 10 * max(scaling, 1);
  one_price_size = 2 * max(scaling, 1);

  ## Background color
  plot (HighPrices, color(3), LowPrices, color(3));
  fill ( [ min(xlim) max(xlim) max(xlim) min(xlim) ], ...
         [ min(ylim) min(ylim) max(ylim) max(ylim) ], color(3) );

  function [X, Y] = helper(idx, hi, lo)
    high_nan = low_nan = nan (num_points, 1);
    high_nan(idx) = hi(idx);
    low_nan(idx) = lo(idx);
    X = reshape ([ x           ; x          ; nan(1, num_points) ], [], 1);
    Y = reshape ([ high_nan(:)'; low_nan(:)'; nan(1, num_points) ], [], 1);
  endfunction

  ## Plot the wicks
  [X, Y] = helper(1 : num_points, HighPrices, LowPrices);
  plot (X, Y, color(4), "linewidth", wick_width);

  ## FIXME: Use rectangle bar bodies

  ## Plot the up bar bodies
  [X, Y] = helper (find (up_down == 1), ClosePrices, OpenPrices);
  plot (X, Y, color(1), "linewidth", body_width);

  ## Plot the down bar bodies
  [X, Y] = helper (find (up_down == -1), OpenPrices, ClosePrices);
  plot (X, Y, color( 2 ), "linewidth", body_width);

  ## Doji bars
  doji_ix = find ((HighPrices > LowPrices) .* (ClosePrices == OpenPrices));
  if (length (doji_ix) >= 1)
    plot (x(doji_ix), ClosePrices(doji_ix), ["+" char(color(4))], "markersize", doji_size);
  endif

  ## Prices all the same
  one_price_ix = find ((HighPrices == LowPrices) .* (HighPrices == OpenPrices) .* (HighPrices == ClosePrices));
  if (length (one_price_ix) >= 1)
    plot (x(one_price_ix), ClosePrices(one_price_ix), ["." char(color(4))], "markersize", one_price_size);
  endif

  ## Revert to previous value of hold
  if (! washold)
    hold off
  endif

  ## No date argument
  if (nargin < 6)
    return
  endif
  if (! ismatrix (dates))
    warning ("candle: DATES must be a matrix; ignoring DATES");
    return
  endif
  if (! (isnumeric (dates) || ischar (dates)))
    warning ("candle: DATES must be of numeric or character type");
    return
  endif
  if (size (dates, 1) != num_points)
    warning ("candle: DATES and price vectors must be of the same length; ignoring DATES");
    return
  endif
  if (nargin < 7 && isnumeric (dates))
    warning ("candle: if DATES is a serial date number (see datenum) or a datevec matrix (see datevec), DATEFORM is required; ignoring DATES");
    return
  endif
  if (nargin >= 7)
    if (ischar (dates))
      warning ("candle: DATES is of character type but DATEFORM is also specified; ignoring DATES");
      return
    endif
    if (isnumeric (dateform) && (dateform < 0 || dateform > 31))
      warning ("candle: DATEFORM integer code number is out of bounds (See datestr); ignoring DATES");
      return
    elseif (isnumeric (dateform) && rem (dateform, 1) > 0)
      warning ("candle: DATEFORM code number should be an integer 0 - 31 (See datestr); ignoring DATES");
      return
    endif
    if (size (dates, 2) == 1)
      is_monotonically_increasing = sum (dates == cummax (dates)) / size (dates, 1);
      if (is_monotonically_increasing != 1)
        warning ("candle: DATES does not appear to be a serial date number column as it is not monotonically increasing; ignoring DATES");
        return
      endif
    endif
  endif

  if (nargin == 6)
    ticks = cellstr (dates);
  else
    ticks = datestr (dates, dateform);
    ticks = mat2cell (ticks, ones (size (ticks, 1), 1), size (ticks, 2));
  endif

  ## FIXME: choose the number of ticks in a smarter way
  num_ticks = 5;
  xx = 1 : floor(num_points / num_ticks) : num_points;

  h = gca ();
  set (h, "xtick", xx);
  set (h, ["x" "ticklabel"], ticks(xx));

endfunction

%!demo 1
%! close();
%! OpenPrices = [ 1292.4; 1291.7; 1291.8; 1292.2; 1291.5; 1291.0; 1291.0; 1291.5; 1291.7; 1291.5; 1290.7 ];
%! HighPrices = [ 1292.6; 1292.1; 1292.5; 1292.3; 1292.2; 1292.2; 1292.7; 1292.4; 1292.3; 1292.1; 1292.9 ];
%! LowPrices = [ 1291.3; 1291.3; 1291.7; 1291.1; 1290.7; 1290.2; 1290.3; 1291.1; 1291.2; 1290.5; 1290.4 ];
%! ClosePrices = [ 1291.8; 1291.7; 1292.2; 1291.5; 1291.0; 1291.1; 1291.5; 1291.7; 1291.6; 1290.8; 1292.8 ];
%! candle( HighPrices, LowPrices, ClosePrices, OpenPrices );
%! title("default plot.");

%!demo 2
%! close();
%! OpenPrices = [ 1292.4; 1291.7; 1291.8; 1292.2; 1291.5; 1291.0; 1291.0; 1291.5; 1291.7; 1291.5; 1290.7 ];
%! HighPrices = [ 1292.6; 1292.1; 1292.5; 1292.3; 1292.2; 1292.2; 1292.7; 1292.4; 1292.3; 1292.1; 1292.9 ];
%! LowPrices = [ 1291.3; 1291.3; 1291.7; 1291.1; 1290.7; 1290.2; 1290.3; 1291.1; 1291.2; 1290.5; 1290.4 ];
%! ClosePrices = [ 1291.8; 1291.7; 1292.2; 1291.5; 1291.0; 1291.1; 1291.5; 1291.7; 1291.6; 1290.8; 1292.8 ];
%! candle( HighPrices, LowPrices, ClosePrices, OpenPrices, 'brk' );
%! title("default plot with user selected black background");

%!demo 3
%! close();
%! OpenPrices = [ 1292.4; 1291.7; 1291.8; 1292.2; 1291.5; 1291.0; 1291.0; 1291.5; 1291.7; 1291.5; 1290.7 ];
%! HighPrices = [ 1292.6; 1292.1; 1292.5; 1292.3; 1292.2; 1292.2; 1292.7; 1292.4; 1292.3; 1292.1; 1292.9 ];
%! LowPrices = [ 1291.3; 1291.3; 1291.7; 1291.1; 1290.7; 1290.2; 1290.3; 1291.1; 1291.2; 1290.5; 1290.4 ];
%! ClosePrices = [ 1291.8; 1291.7; 1292.2; 1291.5; 1291.0; 1291.1; 1291.5; 1291.7; 1291.6; 1290.8; 1292.8 ];
%! candle( HighPrices, LowPrices, ClosePrices, OpenPrices, 'brkg' );
%! title("default color candlestick bodies and user selected background and wick colors");

%!demo 4
%! close();
%! OpenPrices = [ 1292.4; 1291.7; 1291.8; 1292.2; 1291.5; 1291.0; 1291.0; 1291.5; 1291.7; 1291.5; 1290.7 ];
%! HighPrices = [ 1292.6; 1292.1; 1292.5; 1292.3; 1292.2; 1292.2; 1292.7; 1292.4; 1292.3; 1292.1; 1292.9 ];
%! LowPrices = [ 1291.3; 1291.3; 1291.7; 1291.1; 1290.7; 1290.2; 1290.3; 1291.1; 1291.2; 1290.5; 1290.4 ];
%! ClosePrices = [ 1291.8; 1291.7; 1292.2; 1291.5; 1291.0; 1291.1; 1291.5; 1291.7; 1291.6; 1290.8; 1292.8 ];
%! candle( HighPrices, LowPrices, ClosePrices, OpenPrices, 'gmby' );
%! title("all four colors being user selected");

%!demo 5
%! close();
%! OpenPrices = [ 1292.4; 1291.7; 1291.8; 1292.2; 1291.5; 1291.0; 1291.0; 1291.5; 1291.7; 1291.5; 1290.7 ];
%! HighPrices = [ 1292.6; 1292.1; 1292.5; 1292.3; 1292.2; 1292.2; 1292.7; 1292.4; 1292.3; 1292.1; 1292.9 ];
%! LowPrices = [ 1291.3; 1291.3; 1291.7; 1291.1; 1290.7; 1290.2; 1290.3; 1291.1; 1291.2; 1290.5; 1290.4 ];
%! ClosePrices = [ 1291.8; 1291.7; 1292.2; 1291.5; 1291.0; 1291.1; 1291.5; 1291.7; 1291.6; 1290.8; 1292.8 ];
%! datenum_vec = [ 7.3702e+05; 7.3702e+05 ;7.3702e+05; 7.3702e+05; 7.3702e+05; 7.3702e+05; 7.3702e+05; ...
%! 7.3702e+05; 7.3702e+05; 7.3702e+05; 7.3702e+05 ];
%! candle( HighPrices, LowPrices, ClosePrices, OpenPrices, 'brwk', datenum_vec, "yyyy-mm-dd" );
%! title("default plot with datenum dates and character dateform arguments");

%!demo 6
%! close();
%! OpenPrices = [ 1292.4; 1291.7; 1291.8; 1292.2; 1291.5; 1291.0; 1291.0; 1291.5; 1291.7; 1291.5; 1290.7 ];
%! HighPrices = [ 1292.6; 1292.1; 1292.5; 1292.3; 1292.2; 1292.2; 1292.7; 1292.4; 1292.3; 1292.1; 1292.9 ];
%! LowPrices = [ 1291.3; 1291.3; 1291.7; 1291.1; 1290.7; 1290.2; 1290.3; 1291.1; 1291.2; 1290.5; 1290.4 ];
%! ClosePrices = [ 1291.8; 1291.7; 1292.2; 1291.5; 1291.0; 1291.1; 1291.5; 1291.7; 1291.6; 1290.8; 1292.8 ];
%! datenum_vec = [ 7.3702e+05; 7.3702e+05 ;7.3702e+05; 7.3702e+05; 7.3702e+05; 7.3702e+05; 7.3702e+05; ...
%! 7.3702e+05; 7.3702e+05; 7.3702e+05; 7.3702e+05 ];
%! candle( HighPrices, LowPrices, ClosePrices, OpenPrices, 'brk', datenum_vec, 29 );
%! title("default plot with user selected black background with datenum dates and integer dateform arguments");

%!demo 7
%! close();
%! OpenPrices = [ 1292.4; 1291.7; 1291.8; 1292.2; 1291.5; 1291.0; 1291.0; 1291.5; 1291.7; 1291.5; 1290.7 ];
%! HighPrices = [ 1292.6; 1292.1; 1292.5; 1292.3; 1292.2; 1292.2; 1292.7; 1292.4; 1292.3; 1292.1; 1292.9 ];
%! LowPrices = [ 1291.3; 1291.3; 1291.7; 1291.1; 1290.7; 1290.2; 1290.3; 1291.1; 1291.2; 1290.5; 1290.4 ];
%! ClosePrices = [ 1291.8; 1291.7; 1292.2; 1291.5; 1291.0; 1291.1; 1291.5; 1291.7; 1291.6; 1290.8; 1292.8 ];
%! datenum_vec = [ 7.3702e+05; 7.3702e+05 ;7.3702e+05; 7.3702e+05; 7.3702e+05; 7.3702e+05; 7.3702e+05; ...
%! 7.3702e+05; 7.3702e+05; 7.3702e+05; 7.3702e+05 ];
%! datevec_vec = datevec( datenum_vec );
%! candle( HighPrices, LowPrices, ClosePrices, OpenPrices, 'brwk', datevec_vec, 23 );
%! title("default plot with datevec dates and integer dateform arguments");

%!demo 8
%! close();
%! OpenPrices = [ 1292.4; 1291.7; 1291.8; 1292.2; 1291.5; 1291.0; 1291.0; 1291.5; 1291.7; 1291.5; 1290.7 ];
%! HighPrices = [ 1292.6; 1292.1; 1292.5; 1292.3; 1292.2; 1292.2; 1292.7; 1292.4; 1292.3; 1292.1; 1292.9 ];
%! LowPrices = [ 1291.3; 1291.3; 1291.7; 1291.1; 1290.7; 1290.2; 1290.3; 1291.1; 1291.2; 1290.5; 1290.4 ];
%! ClosePrices = [ 1291.8; 1291.7; 1292.2; 1291.5; 1291.0; 1291.1; 1291.5; 1291.7; 1291.6; 1290.8; 1292.8 ];
%! character_dates = char ( [] );
%! for i = 1 : 11
%! character_dates = [ character_dates ; "a date" ] ;
%! endfor
%! candle( HighPrices, LowPrices, ClosePrices, OpenPrices, 'brk', character_dates );
%! title("default plot with user selected black background with character dates argument");
