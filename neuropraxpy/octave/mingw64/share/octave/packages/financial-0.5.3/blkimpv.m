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
## @deftypefn  {Function File} {@var{Volatility} =} blkimpv (@var{Price}, @var{Strike}, @var{Rate}, @var{Time}, @var{Value})
## @deftypefnx {Function File} {@var{Volatility} =} blkimpv (@var{Price}, @var{Strike}, @var{Rate}, @var{Time}, @var{Value}, @var{Limit})
## @deftypefnx {Function File} {@var{Volatility} =} blkimpv (@var{Price}, @var{Strike}, @var{Rate}, @var{Time}, @var{Value}, @var{Limit}, @var{Tolerance})
## @deftypefnx {Function File} {@var{Volatility} =} blkimpv (@var{Price}, @var{Strike}, @var{Rate}, @var{Time}, @var{Value}, @var{Limit}, @var{Tolerance}, @var{Class})
## Compute implied volatility under the Black-Scholes model.
##
## @itemize
## @item
## Variable: @var{Price} The current price of the underlying asset (a futures
## contract).
## @item
## Variable: @var{Strike} Exercise price of the futures option.
## @item
## Variable: @var{Rate} The risk-free interest rate.
## @item
## Variable: @var{Time} The time-to-expiry.
## @item
## Variable: @var{Value} Price of the European option from which the
## underlying's volatility is derived.
## @item
## Variable: @var{Limit} (Optional, default = 10) Upper bound of the implied
## volatility.
## @item
## Variable: @var{Tolerance} (Optional, default = 1e-6) Tolerance with which the
## root-finding method terminates.
## @item
## Variable: @var{Class} (Optional, default = @{'call'@}) Option class (call or
## put). To specify a call option, use a value of true or @{'call'@}. To specify
## put options, use a value of false or @{'put'@}.
## @end itemize
##
## Computes the implied volatility under the Black-Scholes model from a given
## market option price.
##
## @seealso{blsdelta, blsgamma, blslambda, blsprice, blsrho, blstheta}
## @end deftypefn

function Volatility = blkimpv (Price, Strike, Rate, Time, Value, ...
                               Limit = 10, Tolerance = 1e-6, Option = true)
  if (nargin < 5 || nargin > 8)
    print_usage ();
  endif

  Volatility = blsimpv (Price .* exp (-Rate .* Time), Strike, Rate, Time, ...
                        Value, Limit, 0, Tolerance, Option);
endfunction

## Tests
%!assert (blkimpv (90, 100, 0.04, 1, [3.4484 13.0563], 1, 1e-6, [1 0]), [0.2 0.2], 1e-4)

## Test input validation
%!error blkimpv ()
%!error blkimpv (1)
%!error blkimpv (1, 2)
%!error blkimpv (1, 2, 3)
%!error blkimpv (1, 2, 3, 4)
%!error blkimpv (1, 2, 3, 4, 5, 6, 7, 8, 2)
