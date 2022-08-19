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
## @deftypefn  {Function File} {@var{Volatility} =} blsimpv (@var{Price}, @var{Strike}, @var{Rate}, @var{Time}, @var{Value})
## @deftypefnx {Function File} {@var{Volatility} =} blsimpv (@var{Price}, @var{Strike}, @var{Rate}, @var{Time}, @var{Value}, @var{Limit})
## @deftypefnx {Function File} {@var{Volatility} =} blsimpv (@var{Price}, @var{Strike}, @var{Rate}, @var{Time}, @var{Value}, @var{Limit}, @var{Yield})
## @deftypefnx {Function File} {@var{Volatility} =} blsimpv (@var{Price}, @var{Strike}, @var{Rate}, @var{Time}, @var{Value}, @var{Limit}, @var{Yield}, @var{Tolerance})
## @deftypefnx {Function File} {@var{Volatility} =} blsimpv (@var{Price}, @var{Strike}, @var{Rate}, @var{Time}, @var{Value}, @var{Limit}, @var{Yield}, @var{Tolerance}, @var{Class})
## Computes implied volatility under the Black-Scholes model.
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
## Variable: @var{Value} Price of the European option from which the
## underlying's volatility is derived.
## @item
## Variable: @var{Limit} (Optional, default = 10) Upper bound of the implied
## volatility.
## @item
## Variable: @var{Yield} (Optional, default = 0) Annualized, continuously
## compounded rate of dividends of the underlying asset.
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

function Volatility = blsimpv (Price, Strike, Rate, Time, Value,        ...
                               Limit = 10, Yield = 0, Tolerance = 1e-6, ...
                               Class = true)

  if (nargin < 5 || nargin > 9)
    print_usage ();
  endif

  ## Get maximum sizes of matrices
  res_size_row = max ([rows(Price) rows(Strike) rows(Rate) rows(Time)      ...
                       rows(Value) rows(Limit) rows(Yield) rows(Tolerance) ...
                       rows(Class)]);
  res_size_col = max ([columns(Price) columns(Strike) columns(Rate) ...
                       columns(Time)  columns(Value) columns(Limit) ...
                       columns(Yield) columns(Tolerance) columns(Class)]);
  res_size = [res_size_row res_size_col];

  ## Resize scalars
  Price     = resize_scalar (res_size, Price,     "PRICE");
  Strike    = resize_scalar (res_size, Strike,    "STRIKE");
  Rate      = resize_scalar (res_size, Rate,      "RATE");
  Time      = resize_scalar (res_size, Time,      "TIME");
  Value     = resize_scalar (res_size, Value,     "VALUE");
  Limit     = resize_scalar (res_size, Limit,     "LIMIT");
  Yield     = resize_scalar (res_size, Yield,     "YIELD");
  Tolerance = resize_scalar (res_size, Tolerance, "TOLERANCE");

  if (isscalar (Class))
    Class = repmat ({Class}, res_size);
  elseif (! isequal (size (Class), res_size))
    error ("blsimpv: CLASS must be a scalar or cell array of conforming size with other inputs",
           arg_name);
  endif

  ## Check that all values in the cell array option are either boolean
  ## or the string call, and put. Replace the strings call and put by their
  ## respective boolean and then convert it into a boolean matrix.
  if (iscell (Class))
    bool_idx = cellfun ("islogical", Class);
    call_idx = strcmpi (Class, "call");
    put_idx  = strcmpi (Class, "put");
    if (! all (bool_idx | put_idx | call_idx))
      error ("blsimpv: all values in OPTION must be logical, \"call\", or \"put\"");
    endif
    Class(call_idx) = true;
    Class(put_idx)  = false;
    Class = cell2mat (Class);
  endif

  Volatility = zeros (res_size); # output matrix

  for j = 1:res_size_row
    for k = 1:res_size_col

      ## Make option set
      ## At the time of writing, fzero did not recognize the
      ## GradObj option.
      opts = optimset ("fzero");
      opts = optimset (opts, "TolX", Tolerance(j, k), "GradObj", "on");

      ## Construct function
      if (Class(j, k)) # call
        fun = @(x) blscall (Price(j, k), Strike(j, k), Rate(j, k), Time(j, k), x,
                             Yield(j, k)) - Value(j, k);
      else # put
        fun = @(x) blsput (Price(j, k), Strike(j, k), Rate(j, k), Time(j, k), x,
                           Yield(j, k)) - Value(j, k);
      endif

      ## Solve
      try
        [x, fval, exitflag, output] = fzero (fun, [Tolerance(j, k) Limit(j, k)], opts);
        if (exitflag != 1)
          x = NaN;
        endif
      catch
        x = NaN;
      end_try_catch
      Volatility(j, k) = x;

    endfor
  endfor

endfunction

function sc = resize_scalar (res_size, sc, arg_name);
  if (isscalar (sc))
    sc = repmat (sc, res_size);
  elseif (! isequal (size(sc), res_size))
    error ("blsimpv: %s must be a scalar or matrix of conforming size with other inputs",
           arg_name);
  endif
endfunction

function [C, v] = blscall (Price, Strike, Rate, Time, x, Yield)
  C = blsprice (Price, Strike, Rate, Time, x, Yield);
  v = blsvega  (Price, Strike, Rate, Time, x, Yield);
endfunction

function [P, v] = blsput (Price, Strike, Rate, Time, x, Yield)
  [~, P]  = blsprice (Price, Strike, Rate, Time, x, Yield);
  v       = blsvega  (Price, Strike, Rate, Time, x, Yield);
endfunction

## Tests
%!assert (blsimpv (100, 100, 0.04, 1, [9.9251 6.0040], 1, 0, 1e-6, [1 0]), [0.2 0.2], 1e-4)

## Test input validation
%!error blsimpv ()
%!error blsimpv (1)
%!error blsimpv (1, 2)
%!error blsimpv (1, 2, 3)
%!error blsimpv (1, 2, 3, 4)
%!error blsimpv (1, 2, 3, 4, 5, 6, 7, 8, 2)
