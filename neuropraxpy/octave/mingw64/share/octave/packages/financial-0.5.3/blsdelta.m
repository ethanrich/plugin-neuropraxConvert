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
## @deftypefn  {Function File} {[@var{CallDelta}, @var{PutDelta}] =} blsdelta (@var{Price}, @var{Strike}, @var{Rate}, @var{Time}, @var{Volatility})
## @deftypefnx {Function File} {[@var{CallDelta}, @var{PutDelta}] =} blsdelta (@var{Price}, @var{Strike}, @var{Rate}, @var{Time}, @var{Volatility}, @var{Yield})
## Computes the Black-Scholes delta, the rate of change of the option value with
## respect to the value of the underlying asset.
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
## Variable: @var{Yield} (Optional, default = 0) Annualized, continuously
## compounded rate of dividends of the underlying asset.
## @end itemize
##
##
## @seealso{blsgamma, blslambda, blsprice, blsrho, blstheta, blsvega}
## @end deftypefn

function [CallDelta, PutDelta] = blsdelta (Price, Strike, Rate, Time, ...
                                           Volatility, Yield = 0)

  if (nargin < 5 || nargin > 6)
    print_usage ();
  endif

  blscheck ("blsdelta", Price, Strike, Rate, Time, Volatility, Yield);

  d1 = 1 ./ (Volatility .* sqrt (Time)) .* (log (Price ./ Strike) + ...
       (Rate - Yield + Volatility .^2 / 2) .* Time);

  phi = normcdf (d1);

  CallDelta = exp (-Yield .* Time) .* phi;
  PutDelta = exp (-Yield .* Time) .* (phi - 1);

endfunction

## Tests
%!test
%! [CallDelta, PutDelta] = blsdelta (90:10:110, 100, 0.04, 1, 0.2, 0.01);
%! assert (CallDelta, [0.3871 0.5927 0.7586], 1e-4)
%! assert (PutDelta, [-0.6030 -0.3973 -0.2314], 1e-4)

## Test input validation
%!error blsdelta ()
%!error blsdelta (1)
%!error blsdelta (1, 2)
%!error blsdelta (1, 2, 3)
%!error blsdelta (1, 2, 3, 4)
