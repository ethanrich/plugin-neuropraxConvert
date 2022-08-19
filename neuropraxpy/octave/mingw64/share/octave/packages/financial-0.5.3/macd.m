## Copyright (C) 2015 Adam Thompson <adammilesthompson [at] gmail [dot] com>
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
## @deftypefn {Function File} {[@var{macdvec, nineperma}] =} macd (@var{data})
## @deftypefnx {Function File} {[@var{macdvec, nineperma}] =} macd (@var{data}, @var{dim})
##
## Calculate the Moving Average Convergence/Divergence (MACD)
## line of an asset from the vector of prices (@var{data}).
## Also calculate the nine-period exponential moving average
## from the MACD line. If given, @var{dim} indicates whether
## each row is a set of observations (dim = 2) or each
## column is a set of observations (dim = 1, the default).
##
## The MACD line is calculated as the twelve-period
## exponential moving average (EMA) minus the 26-period EMA.
## Closing prices are typically used for the moving
## averages. The nine-period EMA of the MACD line is used as
## the signal line.
## @end deftypefn
function [macdvec, nineperma] = macd (data, dim = 1)

  ## Constants:
  S_PER = 12;
  L_PER = 26;
  SL_PER = 9;
  ## End constants

  ## Check input and set the defaults
  if nargin < 1 || nargin > 2
    print_usage ();
  elseif nargin < 2
    dim = 1;
  endif

  if dim == 2
    data = data';
  end

  ## MACD line:
  ## 12-day EMA:
  alpha = 2 / (S_PER + 1);
  sma = mean(data(1:12));
  s_ema = filter (alpha, [1 (alpha - 1)], data(12:end), sma * (1 - alpha));
  # Formula for calculating EMA provided by James Sherman, Jr.
  # http://octave.1599824.n4.nabble.com/vectorized-moving-average-td2132090.html
  ## 26-day EMA:
  alpha = 2 / (L_PER + 1);
  sma = mean(data(1:26));
  l_ema = filter (alpha, [1 (alpha - 1)], data(26:end), sma * (1 - alpha));
  ## MACD:
  s_ema = [nan(1,11) s_ema];
  l_ema = [nan(1,25) l_ema];

  macdvec = s_ema - l_ema;
  sma = mean(macdvec(26:34));
  ## Signal line:
  alpha = 2 / (SL_PER + 1);
  nineperma = filter (alpha, [1 (alpha - 1)], macdvec(34:end), sma * (1 - alpha));
  nineperma = [nan(1,33) nineperma];

endfunction

## Tests
%!shared d, m, n, a, b
%! d = [46.84 47.07 45.92 47.24 47.64 47.3 48.22 46.98 46.41 44.78 46.29 47.99 47.47 49.19 48.85 48.13 49.13 50.91 51.01 50.48 50.88 51.2 50.85 50.16 48.44 49.1 47.67 45.43 46.47 48.76 50.08 50.74 51.91 51.11 49.36 48.96 49.28 49.02 48.24 49.71];
%! m = [NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN 1.10928 0.87603 0.50460 0.29081 0.30268 0.41383 0.54884 0.74170 0.82053 0.73334 0.62476 0.55810 0.47877 0.34894 0.36051];
%! n = [NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN 0.66262 0.67677 0.66636 0.64471 0.61152 0.55901 0.51931];
%! [a, b] = macd (d);
%!assert([a, b], [m, n], 0.0001)
%! [a, b] = macd (d, 1);
%!assert([a, b], [m, n], 0.0001)
%! [a, b] = macd (d', 2);
%!assert([a, b], [m, n], 0.0001)

