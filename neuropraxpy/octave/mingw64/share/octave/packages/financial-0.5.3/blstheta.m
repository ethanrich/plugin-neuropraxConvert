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
## @deftypefn  {Function File} {[@var{CallTheta}, @var{PutTheta}] =} blstheta (@var{Price}, @var{Strike}, @var{Rate}, @var{Time}, @var{Volatility})
## @deftypefnx {Function File} {[@var{CallTheta}, @var{PutTheta}] =} blstheta (@var{Price}, @var{Strike}, @var{Rate}, @var{Time}, @var{Volatility}, @var{Yield})
## Compute the Black-Scholes theta.
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
## Computes the Black-Scholes theta, the rate of change of the option value with
## respect to the time-to-expiry.
##
## @seealso{blsdelta, blsgamma, blslambda, blsprice, blsrho, blsvega}
## @end deftypefn

function [CallTheta, PutTheta] = blstheta (Price, Strike, Rate, Time, ...
                                           Volatility, Yield = 0)

  if (nargin < 5 || nargin > 6)
    print_usage ();
  endif

  blscheck ("blstheta", Price, Strike, Rate, Time, Volatility, Yield);

  sqrtT       = sqrt (Time);
  sigma_sqrtT = Volatility .* sqrtT;

  d1 = 1 ./ sigma_sqrtT .* (log (Price ./ Strike) + (Rate - Yield + Volatility.^2 / 2) .* Time);
  d2 = d1 - sigma_sqrtT;

  phi1 = normcdf (d1);
  phi2 = normcdf (d2);

  disc  = exp (-Yield .* Time);
  shift = -disc .* Price .* normpdf (d1) .* Volatility / 2 ./ sqrtT;
  t1    = Rate .* Strike   .* exp (-Rate .* Time);
  t2    = Yield .* Price .* disc;

  CallTheta = shift - t1 .*      phi2  + t2 .*  phi1     ;
  PutTheta  = shift + t1 .* (1 - phi2) + t2 .* (phi1 - 1);

endfunction

## Tests
%!test
%! [CallTheta, PutTheta] = blstheta (90:10:110, 100, 0.04, 1, 0.2, 0.01);
%! assert (CallTheta, [-4.2901 -5.2337 -5.1954], 1e-4)
%! assert (PutTheta, [-1.3380 -2.3806 -2.4413], 1e-4)

## Test input validation
%!error blstheta ()
%!error blstheta (1)
%!error blstheta (1, 2)
%!error blstheta (1, 2, 3)
%!error blstheta (1, 2, 3, 4)
