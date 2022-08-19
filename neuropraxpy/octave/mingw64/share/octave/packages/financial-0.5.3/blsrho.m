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
## @deftypefn  {Function File} {[@var{CallRho}, @var{PutRho}] =} blsrho (@var{Price}, @var{Strike}, @var{Rate}, @var{Time}, @var{Volatility})
## @deftypefnx {Function File} {[@var{CallRho}, @var{PutRho}] =} blsrho (@var{Price}, @var{Strike}, @var{Rate}, @var{Time}, @var{Volatility}, @var{Yield})
## Compute the Black-Scholes rho.
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
## Computes the Black-Scholes rho, the rate of change of the option value with
## respect to the risk-free interest rate.
##
## @seealso{blsdelta, blsgamma, blslambda, blsprice, blstheta, blsvega}
## @end deftypefn

function [CallRho, PutRho] = blsrho (Price, Strike, Rate, Time, Volatility, ...
                                     Yield = 0)

  if (nargin < 5 || nargin > 6)
    print_usage ();
  endif

  blscheck ("blsrho", Price, Strike, Rate, Time, Volatility, Yield);

  d2 = 1 ./ (Volatility .* sqrt (Time)) .* (log (Price ./ Strike) + ...
       (Rate - Yield - Volatility .^2 / 2) .* Time);

  phi = normcdf(d2);
  common = Strike .* Time .* exp (-Rate .* Time);

  CallRho = common .* phi;
  PutRho  = common .* (phi - 1);

endfunction

## Tests
%!test
%! [CallRho, PutRho] = blsrho (90:10:110, 100, 0.04, 1, 0.2, 0.01);
%! assert (CallRho, [30.4331 49.9552 67.3271], 1e-4)
%! assert (PutRho, [-65.6458 -46.1238 -28.7519], 1e-4)

## Test input validation
%!error blsrho ()
%!error blsrho (1)
%!error blsrho (1, 2)
%!error blsrho (1, 2, 3)
%!error blsrho (1, 2, 3, 4)
