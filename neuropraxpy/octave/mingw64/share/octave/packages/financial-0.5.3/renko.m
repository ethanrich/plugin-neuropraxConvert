## Copyright (C) 2015 Parsiad Azimzadeh <parsiad.azimzadeh@gmail.com>
##
## This program is free software; you can redistribute it and/or modify it under
## the terms of the GNU Lesser General Public License as published by the Free
## Software Foundation; either version 3 of the License, or (at your option) any
## later version.
##
## This program is distributed in the hope that it will be useful, but WITHOUT
## ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
## FITNESS FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License
## for more details.
##
## You should have received a copy of the GNU Lesser General Public License
## along with this program; if not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn  {Function File} renko (@var{X})
## @deftypefnx {Function File} renko (@var{X}, @var{threshold})
## Plots price changes using a Renko chart.
##
## @itemize
## @item
## Variable: @var{X} An M-by-2 matrix in which the first column contains datenum
## bers and the second contains prices.
## @item
## Variable: @var{threshold} (Optional, default = 1.) A new box is added only
## when subsequent prices change by more than the threshold.
## @end itemize
##
## @example
## X = [...
##   730299.00  23.45; ...
##   730300.00  23.30; ...
##   730305.00  24.00; ...
##   730310.00  23.50; ...
##   730315.00  23.55; ...
##   730320.00  24.11; ...
##   730325.00  26.00; ...
##   730330.00  26.59; ...
##   730335.00  26.50; ...
##   730340.00  26.40; ...
##   730345.00  25.00];
## renko(X, .1);
## @end example
##
## @seealso{bolling, candle, highlow, kagi, linebreak, movavg, pointfig, priceandvol, volarea}
## @end deftypefn

function renko (X, threshold = 1.)

  ## Input checking
  if (nargin < 1 || nargin > 2)
    print_usage ();
  elseif (! (ismatrix (X) && isreal (X) && size (X, 2) == 2))
    error ("renko: X must be a real matrix with exactly two columns");
  elseif (size (X, 1) < 2)
    error ("renko: X must have at least two data points");
  elseif (! (isscalar (threshold) && isreal (threshold) && threshold >= 0.))
    error ("renko: THRESHOLD must be a nonnegative real scalar");
  elseif (! (all (diff (X(:, 1)) > 0)))
    error ("renko: the first column of X should be increasing");
  endif

  fig = figure;
  washold = ishold; hold on; grid on;
  ax = gca;

  total = [];

  m = size (X, 1);
  while (m >= 2)

    found_n = false;
    n = m - 1;
    for n = (m-1):-1:1
      if (abs(X(n, 2) - X(m, 2)) >= threshold)
        found_n = true;
        while (n > 1 && abs(X(n-1, 2) - X(n, 2)) < threshold)
          n = n - 1;
        endwhile
        break;
      endif
    endfor

    if (! found_n)
      break;
    endif

    if (X(m, 2) > X(n, 2))
      direction = -1;
    else
      direction = +1;
    endif

    X2 = fliplr (X(m, 2):(direction*threshold):X(n, 2));
    tmp = (1 - (X(m, 2) - X2(1)) / (X(m, 2) - X(n, 2))) * (X(m, 1) - X(n, 1)) + X(n, 1);
    X1 = linspace (tmp, X(m, 1), length (X2));

    l = plot (X1, X2, "s");
    if (direction == -1)
      set (l, "MarkerFaceColor", "w");
    else
      set (l, "MarkerFaceColor", "k");
    endif
    set (l, "MarkerEdgeColor", "k");

    m = n;

    minX = X(1);

  endwhile

  axis([minX X(end, 1) -Inf Inf]);
  ticks = get (ax, "XTick");
  dates = datestr (ticks, 1);

  set (ax, "XTickLabel", dates)

  if (! washold)
    hold off
  endif

endfunction

