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
## @deftypefn  {Function File} {[@var{AssetPrice}, @var{OptionValue}] =} binprice (@var{Price}, @var{Strike}, @var{Rate}, @var{Time}, @var{Increment}, @var{Volatility}, @var{OptType})
## @deftypefnx {Function File} {[@var{AssetPrice}, @var{OptionValue}] =} binprice (@var{Price}, @var{Strike}, @var{Rate}, @var{Time}, @var{Increment}, @var{Volatility}, @var{OptType}, @var{DividendRate})
## @deftypefnx {Function File} {[@var{AssetPrice}, @var{OptionValue}] =} binprice (@var{Price}, @var{Strike}, @var{Rate}, @var{Time}, @var{Increment}, @var{Volatility}, @var{OptType}, @var{DividendRate}, @var{Dividend}, @var{ExDiv})
## Compute American call and put option prices using a binomial tree.
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
## Variable: @var{Increment} Time increment. @var{Increment} is rounded to
## ensure that @var{Time}/@var{Increment} is an integer.
## @item
## Variable: @var{Volatility} The volatility of the underlying asset.
## @item
## Variable: @var{OptType} Option type. 1 = call option, 0 = put option.
## @item
## Variable: @var{DividendRate} (Optional, default = 0) Annualized, continuously
## compounded rate of dividends of the underlying asset.
## @item
## Variable: @var{Dividend} (Optional, default = 0) The dividend payment at an
## ex-dividend date as specified by @var{ExDiv}.
## @item
## Variable: @var{ExDiv} (Optional, default = 0) A vector used to determine the
## ex-dividend dates. For each j, @var{ExDiv}(j) * @var{Increment} is the
## corresponding dividend date.
## @end itemize
##
## Computes the American call and put option prices using the
## Cox-Ross-Rubinstein binomial tree.
##
## Discrete dividends (i.e. @var{Dividend} and @var{ExDiv}) have not yet been
## implemented.
##
## Binomial trees are a particular explicit finite difference method for solving
## the Black-Scholes equation (see
## @cite{M. Rubinstein. On the relation between binomial and trinomial option
## pricing models. Journal of Derivatives, 8(2):47-50, 2000}),
## and exhibit linear convergence along with the usual strict stability
## requirements of an explicit method.
## The serious practitioner should consider using a more
## sophisticated method, and use binomial trees only for explanatory or
## heuristic purposes.
##
## @seealso{blkprice, blsprice}
## @end deftypefn

function [AssetPrice, OptionValue] = binprice (Price, Strike, Rate, Time, ...
                                               Increment, Volatility,     ...
                                               OptType, DividendRate = 0, ...
                                               Dividend = 0, ExDiv = 0 )

  ## Input checking
  if (nargin < 7 || nargin > 10)
    print_usage ();
  elseif (! isbool (OptType) && ! isequal (OptType, 0) && ...
          ! isequal (OptType, 1))
    error ("binprice: OPTTYPE must be logical, 0 (call) or 1 (put)");
  elseif (! isscalar (Price) || ! isscalar (Strike) || ! isscalar (Rate) || ...
      ! isscalar (Increment) || !isscalar (Volatility) || ...
      !isscalar (DividendRate))
    error ("binprice: all inputs except DIVIDEND and EXDIV must be scalars");
  elseif (! isreal (Price) || Price < 0)
    error ("binprice: PRICE must be a nonnegative number");
  elseif (! isreal (Strike) || Strike < 0)
    error ("binprice: STRIKE must be a nonnegative number");
  elseif (! isreal (Rate))
    error ("binprice: RATE must be a number");
  elseif (! isreal (Time) || Time <= 0)
    error ("binprice: TIME must be a positive number");
  elseif (! isreal (Increment) || Increment <= 0)
    error ("binprice: INCREMENT must be a positive number");
  elseif (! isreal (Volatility) || Volatility < 0)
    error ("binprice: VOLATILITY must be a nonnegative number");
  elseif (! isreal (DividendRate))
    error ("binprice: DIVIDENDRATE must be a number");
  elseif (! isequal (Dividend, 0) || ! isequal (ExDiv, 0))
    error ("binprice: DIVIDEND and EXDIV not yet implemented");
  endif

  ## Storage
  N = round ( Time / Increment ) + 1;
  AssetPrice = OptionValue = zeros (N);

  Increment = Time / (N - 1);

  ## Return from up and down moves
  u = exp (Volatility * sqrt (Increment));
  d = 1 / u;

  ## Martingale measure
  a = exp (Rate * Increment);
  p = (a * exp (-DividendRate * Increment) - d) / (u - d);
  q = 1 - p;

  ## Build tree
  AssetPrice(1, 1) = Price;
  for n = 2:N
    AssetPrice(1:(n - 1), n) = u * AssetPrice(1:(n - 1), n - 1);
    AssetPrice(n, n) = d * AssetPrice(n - 1, n - 1);
  endfor

  ## Initial condition
  opt = 2 * OptType - 1;
  OptionValue(:, N) = max (opt * (AssetPrice(:, N) - Strike), 0);

  ## Time-stepping loop
  for n = (N - 1):-1:1
    HoldValue = (q * OptionValue(2:(n + 1), n + 1) + ...
                 p * OptionValue(1:n,       n + 1)) / a;

    OptionValue(1:n, n) = max (HoldValue, opt * (AssetPrice(1:n, n) - Strike));
  endfor

endfunction

## Tests
%!test
%! [AssetPrice, OptionValue] = binprice (100, 100, 0.04, 1, 0.25, 0.2, 0, 0.01);
%! assert (OptionValue(1:2,1:2), [6.4701 2.2159; 0 11.0776], 1e-4)

## Test input validation
%!error binprice ()
%!error binprice (1)
%!error binprice (1, 2)
%!error binprice (1, 2, 3)
%!error binprice (1, 2, 3, 4)
%!error binprice (1, 2, 3, 4, 5)
%!error binprice (1, 2, 3, 4, 5, 6)
