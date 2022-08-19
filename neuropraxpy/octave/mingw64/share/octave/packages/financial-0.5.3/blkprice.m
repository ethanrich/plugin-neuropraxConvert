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
## @deftypefn {Function File} {[@var{Call}, @var{Put}] =} blkprice (@var{Price}, @var{Strike}, @var{Rate}, @var{Time}, @var{Volatility})
## Compute European call and put option price using the Black-76 model.
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
## Variable: @var{Volatility} The volatility of the underlying asset.
## @end itemize
##
## @seealso{binprice, blsprice}
## @end deftypefn

function [Call, Put] = blkprice (Price, Strike, Rate, Time, Volatility)

  if (nargin != 5)
    print_usage ();
  endif

  [Call, Put] = blsprice (Price .* exp (-Rate .* Time), Strike, Rate, Time, ...
                          Volatility);

endfunction

## Tests
%!test
%! [Call, Put] = blkprice (90:10:110, 100, 0.04, 1, 0.2);
%! assert (Call, [3.4484 7.6532 13.7316], 1e-4)
%! assert (Put, [13.0563 7.6532 4.1237], 1e-4)

## Test input validation
%!error blkprice ()
%!error blkprice (1)
%!error blkprice (1, 2)
%!error blkprice (1, 2, 3)
%!error blkprice (1, 2, 3, 4)
