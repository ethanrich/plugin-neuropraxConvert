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
## @deftypefn  {Function File} {[@var{Call}, @var{Put}] =} blsprice (@var{Price}, @var{Strike}, @var{Rate}, @var{Time}, @var{Volatility})
## @deftypefnx {Function File} {[@var{Call}, @var{Put}] =} blsprice (@var{Price}, @var{Strike}, @var{Rate}, @var{Time}, @var{Volatility}, @var{Yield})
## Compute European call and put option prices.
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
## Computes the European call and put option prices using the Black-Scholes
## model.
##
## @seealso{blskprice, blsdelta, blsgamma, blsimpv, blslambda, blsrho, blstheta, blsvega}
## @end deftypefn

function [Call, Put] = blsprice (Price, Strike, Rate, Time, Volatility, ...
                                 Yield = 0)

  if (nargin < 5 || nargin > 6)
    print_usage ();
  endif

  blscheck ("blsprice", Price, Strike, Rate, Time, Volatility, Yield);

  sigma_sqrtT = Volatility .* sqrt (Time);

  d1 = 1 ./ sigma_sqrtT .* (log (Price ./ Strike) + (Rate - Yield + ...
       Volatility.^2 / 2) .* Time);
  d2 = d1 - sigma_sqrtT;

  phi1 = normcdf (d1);
  phi2 = normcdf (d2);
  disc = exp (-Rate .* Time);
  F    = Price .* exp ((Rate - Yield) .* Time);

  Call = disc .* (F .*      phi1  - Strike .*  phi2     );
  Put  = disc .* (Strike .* (1 - phi2) + F .* (phi1 - 1));

endfunction

## Tests
%!test
%! [Call, Put] = blsprice (90:10:110, 100, 0.04, 1, 0.2, 0.01);
%! assert (Call, [4.4037 9.3197 16.1217], 1e-4)
%! assert (Put, [11.3781 6.3937 3.2952], 1e-4)

## Test input validation
%!error blsprice ()
%!error blsprice (1)
%!error blsprice (1, 2)
%!error blsprice (1, 2, 3)
%!error blsprice (1, 2, 3, 4)
%!error blsprice ("invalid", "type", "argument", 4, 5)
%!error blsprice ({1, 2, 3}, [2 7 8], [8 3 1], 4, 10)
