## Copyright (C) 1996-2015 Piotr Held
##
## This file is part of Octave.
##
## Octave is free software; you can redistribute it and/or
## modify it under the terms of the GNU General Public
## License as published by the Free Software Foundation;
## either version 3 of the License, or (at your option) any
## later version.
##
## Octave is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied
## warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
## PURPOSE.  See the GNU General Public License for more
## details.
##
## You should have received a copy of the GNU General Public
## License along with Octave; see the file COPYING.  If not,
## see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn{Function File} {@var{eigval} =} pca (@var{S})
## @deftypefnx{Function File} {[@var{eigval}, @var{eigvec}] =} pca (@var{S})
## @deftypefnx{Function File} {[@var{eigval}, @var{eigvec}, @var{ts}] =} pca (@var{S})
## @deftypefnx{Function File} {[@dots{}] =} pca (@var{S}, @var{paramName}, @var{paramValue}, @dots{})
##
## Performs a global principal component analysis (PCA). It gives the
## eigenvalues of the covariance matrix and depending on the flag @var{w}
## settings the eigenvectors, projections of the input time series.
##
## @strong{Input}
##
## @table @var
## @item S
## This function always assumes that each time series is along the longer 
## dimension of matrix @var{S}. It also assumes that every dimension 
## (counting along the shorter dimension) of @var{S} is considered a 
## component of the time series.
## @end table
##
## @strong{Parameters}
##
## @table @var
## @item m
## Defines embedding dimension. Since all of the data in @var{S} is analysed
## there is no need for setting the number of columns to be read (as is the
## case in TISEAN 'pca') [default = 1].
## @item d
## Delay must be scalar integer [default = 1].
## @item q
## Determines the properties of @var{TS}. When parameter @var{w} is set then
## @var{q} determines the projection dimension. Otherwise it determines the
## number of components written to output [default = full dimension/all
## components].
## @end table
##
## @strong {Switch}
##
## @table @var
## @item w
## If @var{w} is set then @var{TS} is a projection of the time series onto the
## first @var{q} eigenvectors (global noise reduction).
## If @var{w} is not set then @var{TS} is a transformation of the time
## series onto the eigenvector basis. The number of projection
## dimension/components printed is determined by parameter @var{q}.
## @end table
##
## @strong{Output}
##
## @table @var
## @item eigval
## The calculated eigenvalues.
## @item eigvec
## The eigenvectors. The vectors are alligned with the longer dimension of
## @var{S}.
## @item ts
## If @var{w} is set then this variable holds the projected time series
## onto the first @var{q} eigenvectors. If @var{w} is not set then @var{TS} is
## the transformed time series onto the eigenvector basis (number of
## components == parameter @var{q}).
## @end table
##
## @strong{Algorithms}
##
## The algorithms for this functions have been taken from the TISEAN package.
## @end deftypefn

## Author: Piotr Held <pjheld@gmail.com>.
## This function is based on pca of TISEAN 3.0.1
## https://github.com/heggus/Tisean"

function [eigval, eigvec, TS] = pca (S, varargin)

  if (nargin < 1)
    print_usage;
  endif

  if ((ismatrix (S) == false) || (isreal(S) == false))
    error ('Octave:invalid-input-arg', "S must be a realmatrix");
  endif

 # Define default values for pca variables
  dim            = 2;
  dimset         = 0;
  emb            = 1;
  delay          = 1;
  ldim           = 2;
  projection_set = 0;

  #### Parse the input
  p = inputParser ();
  p.FunctionName = "pca";

  isPositiveIntScalar = @(x) isreal(x) && isscalar (x) && ...
                             (x > 0) && (x-round(x) == 0);

  p.addParamValue ("m", emb, isPositiveIntScalar);
  p.addParamValue ("d", delay, isPositiveIntScalar);
  p.addParamValue ("q", ldim, isPositiveIntScalar);
  p.addSwitch ("w");

  p.parse (varargin{:});

  # Assign inputs
  emb            = p.Results.m;
  dimset         = !ismember ('m',p.UsingDefaults);
  delay          = p.Results.d;
  ldim           = p.Results.q;
  projection_set = !ismember ('q',p.UsingDefaults);
  w              = p.Results.w;

  if (w && (nargout < 3))
    error ('Octave:invalid-fun-call', "Do not set flag 'w' when less than 3 output values");
  endif;

  # Correct S to always have more rows than columns
  trnspsd = false;
  if (rows (S) < columns (S))
    S       = S.';
    trnspsd = true;
  endif

  if (columns (S) != dim)
    dim    = columns (S);
    dimset = 1;
  endif

  # Compute output for various inputs.
  switch (nargout)
    case { 0, 1, 2 }
      w = 1;
      [eigval, eigvec] = __pca__ (S, dim, emb, delay, ldim, projection_set, w);

    case 3
      # The value of 'w' is set to correspond to the 'W' flag from TISEAN in determining
      # the value of TS. Eigval and eigvec are equivalent to the lower values of 'W' from TISEAN
      # that is '-W0' and '-W1'.
      if (w)
        w = 3;
      else
        w = 2;
      endif;
      [eigval, eigvec, TS] = __pca__ (S, dim, emb, delay, ldim, projection_set, w);
      # Fix output to allign with input
      if (trnspsd)
        TS     = TS.';
      endif;
    otherwise
      error ('Octave:invalid-fun-call', "Too many output variables");
  endswitch

  # Fix the output to allign with the input
  if (trnspsd)
    eigval = eigval.';
    eigvec = eigvec.';
  endif

endfunction

%!test
%! a = (1:300).';
%! b = [zeros(100,1); ones(100,1); zeros(100,1)];
%! res = [0, 7.499917e+03; 1, 2.222222e-01];
%! assert (pca ([a,b]), res, -1e-6);

%!test
%! a = (1:300).';
%! b = sin (a / (2*pi));
%! res = [-1.000000e+00, -1.105892e-04; 1.105892e-04, -1.000000e+00];
%! [eval, evec] = pca ([a,b]);
%! assert (evec, res, -1e-6);

%!test
%! a = (1:10).';
%! b = [0; 0; 0; 0; 1; 1; 1; 0; 0; 0];
%! res = [-9.998261e-01, 1.864698e-02; -1.999652e+00, 3.729397e-02; -2.999478e+00, 5.594095e-02; -3.999305e+00, 7.458794e-02; -5.017778e+00, -9.065912e-01; -6.017604e+00, -8.879442e-01; -7.017430e+00, -8.692972e-01; -7.998609e+00, 1.491759e-01; -8.998435e+00, 1.678229e-01; -9.998261e+00, 1.864698e-01];
%! [eval, evec, ts] = pca ([a,b]);
%! assert (ts, res, -1e-6);

%!test
%! a = (1:10).';
%! b = [0; 0; 0; 1; 1; 0; 0; 1; 0; 0];
%! res = [1.000000e+00, -5.551115e-17; 2.000000e+00, -5.551115e-17; 3.000000e+00, -5.551115e-17; 4.000000e+00, 1.000000e+00; 5.000000e+00, 1.000000e+00; 6.000000e+00, -5.551115e-17; 7.000000e+00, -1.110223e-16; 8.000000e+00, 1.000000e+00; 9.000000e+00, -5.551115e-17; 1.000000e+01, -1.110223e-16];
%! [eval, evec, ts] = pca ([a,b], 'w');
%! assert (ts, res, -1e-6);

%!xtest (pca (rand(2,10)));
