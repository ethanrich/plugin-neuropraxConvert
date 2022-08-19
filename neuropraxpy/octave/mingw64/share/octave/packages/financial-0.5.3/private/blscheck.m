## Copyright (C) 2015 CarnĂŤ Draug <carandraug@octave.org>
## Copyright (C) 2015 Parsiad Azimzadeh <parsiad.azimzadeh@gmail.com>
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
## @deftypefn  {Function File} {[@var{Call}, @var{Put}] =} blscheck (@var{Price}, @var{Strike}, @var{Rate}, @var{Time}, @var{Volatility})
## @deftypefnx {Function File} {[@var{Call}, @var{Put}] =} blscheck (@var{Price}, @var{Strike}, @var{Rate}, @var{Time}, @var{Volatility}, @var{Yield})
## Performs input checking for the bls* functions.
##
## @itemize
## @item
## Variable: @var{Parent} The calling function.
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
## Performs input checking for the bls* functions. All variables must be the
## same size matrix. @var{Price}, @var{Strike}, @var{Time}, @var{Volatility}
## must be positive.
##
## @seealso{blsprice}
## @end deftypefn

function blscheck (Parent, Price, Strike, Rate, Time, Volatility, Yield = 0)

  ## FIXME: Error on negative Price, Strike, Time, Volatility, Yield
  persistent names = {"PRICE", "STRIKE", "RATE", "TIME", "VOLATILITY", "YIELD"};
  inputs   = {Price, Strike, Rate, Time, Volatility, Yield};
  numerics = cellfun (@isnumeric, inputs);
  if (! all (numerics))
    error ("%s: inputs must be numeric", Parent);
  endif
  scalars = cellfun (@isscalar, inputs);
  if (! all (scalars))
    sizes = cellfun (@size, inputs(! scalars), "UniformOutput", false);
    if (! all (cellfun (@(x) isequal (sizes{1}, x), sizes)))
      error ("%s: matrix arguments must all have the same size", Parent);
    endif
  endif

end
