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
## @deftypefn  {Function File} {[@var{CallEl}, @var{PutEl}] =} blslambda (@var{Price}, @var{Strike}, @var{Rate}, @var{Time}, @var{Volatility})
## @deftypefnx {Function File} {[@var{CallEl}, @var{PutEl}] =} blslambda (@var{Price}, @var{Strike}, @var{Rate}, @var{Time}, @var{Volatility}, @var{Yield})
## Computes elasticity of option under the Black-Scholes model.
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
## Computes the elasticity of an option under the Black-Scholes model.
## Elasticity measures the percent change in the option price per percent change
## in the underlying asset price.
##
## Update: the following bug has been fixed in MATLAB R2014a(5.3):
## There is a bug in the MATLAB version of blslambda in which the deltas of the
## option are not discounted by @var{Yield} in the nonzero dividend case. That
## is, they compute normcdf(d1) * S / V when they should compute
## exp(-Yield*T) * normcdf(d1) * S / V. At the time of writing, this bug is
## present in the financial toolbox shipped with R2013a. Both this version of
## blslambda and that shipped with R2013a agree when there are no dividends.
##
## @seealso{blsdelta, blsgamma, blsprice, blsrho, blstheta, blsvega}
## @end deftypefn

function [CallEl, PutEl] = blslambda (Price, Strike, Rate, Time, ...
                                      Volatility, Yield = 0)

  if (nargin < 5 || nargin > 6)
    print_usage ();
  endif

  blscheck ("blslambda", Price, Strike, Rate, Time, Volatility, Yield);

  [Call, Put] = blsprice (Price, Strike, Rate, Time, Volatility, Yield);
  [CallDelta, PutDelta] = blsdelta (Price, Strike, Rate, Time, Volatility, ...
                                    Yield);

  CallEl = CallDelta .* Price ./ Call;
  PutEl  = PutDelta  .* Price ./ Put;

endfunction

## Tests
%!test
%! [CallEl, PutEl] = blslambda (90:10:110, 100, 0.04, 1, 0.2);
%! assert (CallEl, [7.7536 6.2258 5.0647], 1e-4)
%! assert (PutEl, [-4.8955 -6.3639 -7.8941], 1e-4)
%!test
%! [CallEl, PutEl] = blslambda (90:10:110, 100, 0.04, 1, 0.2, 0.01);
%! assert (CallEl, [7.9108 6.3601 5.1762], 1e-4)
%! assert (PutEl, [-4.7695 -6.2139 -7.7255], 1e-4)

## Test input validation
%!error blslambda ()
%!error blslambda (1)
%!error blslambda (1, 2)
%!error blslambda (1, 2, 3)
%!error blslambda (1, 2, 3, 4)
