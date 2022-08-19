## Copyright (C) 2013 Parsiad Azimzadeh <parsiad.azimzadeh@gmail.com>
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
## @deftypefn  {Function File} {@var{Vega} =} blsvega (@var{Price}, @var{Strike}, @var{Rate}, @var{Time}, @var{Volatility})
## @deftypefnx {Function File} {@var{Vega} =} blsvega (@var{Price}, @var{Strike}, @var{Rate}, @var{Time}, @var{Volatility}, @var{Yield})
## Computes the Black-Scholes vega.
##
## @itemize
## @item
## Variable: @var{Price} The current price of the underlying asset.
## @item
## Variable: @var{Strike} The strike price the option is written on.
## @item
## Variable: @var{Rate} The risk-free interest rate.
## @item
## Variable: @var{Time} The time-to-expiry.
## @item
## Variable: @var{Volatility} The volatility of the underlying asset.
## @item
## Variable: @var{Yield} (Optional, default = 0) Annualized, continuously compounded rate of dividends of the underlying asset.
## @end itemize
##
## Computes the Black-Scholes vega, the rate of change of the option value with
## respect to the volatility of the underlying asset.
##
## @seealso{blsdelta, blsgamma, blslambda, blsprice, blsrho, blstheta}
## @end deftypefn

function Vega = blsvega (Price, Strike, Rate, Time, Volatility, Yield = 0)

  if (nargin < 5 || nargin > 6)
    print_usage ();
  endif

  blscheck ("blsvega", Price, Strike, Rate, Time, Volatility, Yield);

  sqrtT = sqrt (Time);
  d1 = 1 ./ (Volatility .* sqrtT) .* (log (Price ./ Strike) + ...
       (Rate - Yield + Volatility.^2 / 2) .* Time);
  Vega = Price .* exp (-Yield .* Time) .* normpdf (d1) .* sqrtT;

endfunction

## Tests
%!test
%assert (blsvega(90:10:110, 100, 0.04, 1, 0.2, 0.01), [34.2115   38.2821   33.3682], 1e-4)

## Test input validation
%!error blsvega ()
%!error blsvega (1)
%!error blsvega (1, 2)
%!error blsvega (1, 2, 3)
%!error blsvega (1, 2, 3, 4)
