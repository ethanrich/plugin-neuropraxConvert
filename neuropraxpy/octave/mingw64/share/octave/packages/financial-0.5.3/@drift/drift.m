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
## @deftypefn  {Function File} {@var{DriftRate} =} drift (@var{A}, @var{B})
## Creates an object to represent the drift rate of a stochastic differential
## equation (SDE).
##
## @center @var{DriftRate}(t, X_t) = A(t) + B(t) * X_t
## @center dX_t = @var{DriftRate}(t, X_t)dt + DiffusionRate(t, X_t)dW_t.
##
## @itemize
## @item (X_t) is an NVARS-dimensional process;
## @item (W_t) is an NBROWNS-dimensional Wiener process.
## @end itemize
##
## @itemize
## @item
## Variable: @var{A} An NVARS-by-1 vector or a function. As a function, @var{A}
## returns an NVARS-by-1 vector and has either exactly one input (time:
## @var{A}(t)) or exactly two inputs (time and space: @var{A}(t, X_t)).
## @item
## Variable: @var{B} An NVARS-by-NVARS matrix or a function. As a function,
## @var{B} returns an NVARS-by-NVARS matrix and has either exactly one input
## (time: @var{B}(t)) or exactly two inputs (time and space: @var{B}(t, X_t)).
## @end itemize
##
## @seealso{diffusion}
## @end deftypefn

function DriftRate = drift (A, B)

  ## Check number of arguments
  if (nargin != 2)
    print_usage();
  endif

  if (iscolumn (A) && isreal (A))
    DriftRate.A = @(t, X) A;
    DriftRate.IsAConstant = true;
  elseif (isa (A, "function_handle") && nargin (A) == 1)
    DriftRate.A = @(t, X) A(t);
    DriftRate.IsAConstant = false;
  elseif (isa (A, "function_handle") && nargin (A) == 2)
    DriftRate.A = A;
    DriftRate.IsAConstant = false;
  else
    error ("drift: A must either be a real column vector or a function of one or two arguments returning such a vector.");
  endif

  if (ismatrix (B) && issquare (B) && isreal (B) && ((! isreal (A)) || size (B, 1) == size (A, 1)) )
    DriftRate.B = @(t, X) B;
    DriftRate.IsBConstant = true;
  elseif (isa (B, "function_handle") && nargin (B) == 1)
    DriftRate.B = @(t, X) B(t);
    DriftRate.IsBConstant = false;
  elseif (isa (B, "function_handle") && nargin (B) == 2)
    DriftRate.B = B;
    DriftRate.IsBConstant = false;
  else
    error ("drift: B must either be a real square matrix of order equal to the dimension of A or a function of one or two arguments returning such a matrix.");
  endif

  DriftRate.Rate = @(t, X) reshape ( ...
                                     bsxfun ( ...
                                              @plus, ...
                                              DriftRate.A (t, X), ...
                                              DriftRate.B (t, X) * reshape (X, [size(X, 1), size(X, 3)]) ...
                                     ), ...
                                     [size(X, 1), 1, size(X, 3)] ...
                           );

  DriftRate = class (DriftRate, "drift");

endfunction

