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
## @deftypefn  {Function File} {@var{Profit} =} opprofit (@var{AssetPrice}, @var{Strike}, @var{Cost}, @var{PosFlag}, @var{OptType})
## Compute profit of an option.
##
## @itemize
## @item
## Variable: @var{AssetPrice} The price of the underlying asset at the expiry time.
## @item
## Variable: @var{Strike} The strike price the option is written on.
## @item
## Variable: @var{Cost} The premium paid/charged for the option.
## @item
## Variable: @var{PosFlag} Option position. 0 = long, 1 = short.
## @item
## Variable: @var{OptType} Option type. 0 = call option, 1 = put option.
## @end itemize
##
## @seealso{binprice, blsprice}
## @end deftypefn

function Profit = opprofit (AssetPrice, Strike, Cost, PosFlag, OptType)

  if (nargin != 5)
    print_usage ();
  elseif (! isbool (PosFlag) && any (PosFlag(:) != 0 & PosFlag(:) != 1))
    error ("opprofit: POSFLAG must be logical, 0 (long) or 1 (short)");
  elseif (! isbool (OptType) && any (OptType(:) != 0 & OptType(:) != 1))
    error ("opprofit: OPTTYPE must be logical, 0 (call) or 1 (put)");
  end

  pos = -2 * PosFlag + 1;
  opt = -2 * OptType + 1;
  Profit = pos .* (max (opt .* (AssetPrice - Strike), 0) - Cost);

endfunction

## Tests
%!assert (opprofit (100, 90, 4, 0, 0),  6)
%!assert (opprofit (80:20:120, 90, 4, 0, 0), [-4 6 26])
%!assert (opprofit (80:20:120, 80:20:120, 0, 0, 0), [0 0 0])
%!assert (opprofit (100, 90, 4, [0 0 1 1], [0 1 0 1]), [6 -4 -6 4])

## Test input validation
%!error opprofit ()
%!error opprofit (1)
%!error opprofit (1, 2)
%!error opprofit (1, 2, 3)
%!error opprofit (1, 2, 3, 4)
%!error opprofit (1, 2, 3, 4, 0)
%!error opprofit (1, 2, 3, 0, 5)
