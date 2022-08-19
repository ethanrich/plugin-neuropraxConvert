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
## @deftypefn{Function File} {output =} xzero (@var{X1}, @var{X2})
## @deftypefnx{Function File} {output =} xzero (@var{X1}, @var{X2}, @var{paramName}, @var{paramValue}, @dots{})
##
## Takes two data sets and fits a zeroth order model of data set 1 (@var{X1})
## to predict data set 2 (@var{X2}) - cross prediction. It then computes the
## error of the model. This is done by searching for all neighbors in @var{X1}
## of the points of set @var{X2} which should be forecasted and taking as their
## images the average of the images of the neighbors. The obtained forecast
## error is normalized to the variance of data set @var{X2}.
##
## @strong{Inputs}
##
## Both @var{X1} and @var{X2} must be present. They must be realvectors
## of the same length.
##
## @strong{Parameters}
##
## @table @var
## @item m
## Embedding dimension [default = 3].
## @item d
## Delay for embedding [default = 1].
## @item n
## The number of points for which the error should be calculated 
## [default = all].
## @item k
## Minimum number of neighbors for the fit [default = 30].
## @item r
## The neighborhood size to start with [default = 1e-3].
## @item f
## Factor by which to increase the neighborhood size if not
## enough neighbors were found [default = 1.2].
## @item s
## Steps to be forecast (@code{x2(n+steps) = av(x1(i+steps)}) [default = 1].
## @end table
##
## @strong{Output}
##
## Contains value of parameter '@var{s}' lines. Each line represents the
## forecast error divided by the standard deviation of the second data set 
## (@var{X2}). This second data set is the one being forecasted.
##
## @strong{Algorithms}
##
## The algorithms for this functions have been taken from the TISEAN package.
## @end deftypefn

## Author: Piotr Held <pjheld@gmail.com>.
## This function is based on xzero of TISEAN 3.0.1
## https://github.com/heggus/Tisean"

function output = xzero (X1, X2, varargin)

  # Initial input validation
  if (nargin < 2)
    print_usage;
  endif

  if ((isvector (X1) == false) || (isreal(X1) == false))
    error ('Octave:invalid-input-arg', "X1 must be a realvector");
  endif

  if ((isvector (X2) == false) || (isreal(X2) == false))
    error ('Octave:invalid-input-arg', "X2 must be a realvector");
  endif

  if (length (X1) != length (X2))
    error ('Octave:invalid-input-arg', "X1 and X2 must be of same length");
  endif

  # Default parameters
  embdim  = 3;
  delay   = 1;
  clength = length (X1);
  minn    = 30;
  eps0    = 1e-3;
  epsf    = 1.2;
  step    = 1;

  #### Parse the input
  p = inputParser ();
  p.FunctionName = "xzero";

  isPositiveIntScalar    = @(x) isreal(x) && isscalar (x) && ...
                             (x > 0) && (x-round(x) == 0);
  isPositiveScalar     = @(x) isreal(x) && isscalar (x) && (x > 0);

  p.addParamValue ("m", embdim, isPositiveIntScalar);
  p.addParamValue ("d", delay, isPositiveIntScalar);
  p.addParamValue ("n", clength, isPositiveIntScalar);
  p.addParamValue ("k", minn, isPositiveIntScalar);
  p.addParamValue ("r", eps0, isPositiveScalar);
  p.addParamValue ("f", epsf, isPositiveScalar);
  p.addParamValue ("s", step, isPositiveIntScalar);

  p.parse (varargin{:});

  # Assign input
  embdim   = p.Results.m;
  delay    = p.Results.d;
  clength  = p.Results.n;
  minn     = p.Results.k;
  eps0     = p.Results.r;
  epsset   = !ismember ("r", p.UsingDefaults);
  epsf     = p.Results.f;
  step     = p.Results.s;

  output  = __xzero__ (X1, X2, embdim, delay, clength, minn, eps0, epsset, ...
                       epsf, step);
endfunction

%!fail ("xzero(1)");
%!fail ("xzero('a')");

%!test
%! hen = henon(2000)(:,1);
%! hen1 = hen(1:1000);
%! hen2 = hen(1001:end);
%! res_tisean = [1 0.6438699;2 0.9101371;3 0.9752469;4 0.9600329;5 0.9788585;6 0.9937851;7 1.002654;8 0.9973579;9 1.00776;10 1.008823;11 1.016724;12 1.017996;13 1.011284;14 1.005963;15 1.008479;16 1.007647;17 1.009703;18 1.018097;19 1.008374;20 1.006889];
%! out = xzero (hen1,hen2,'m',4,'d',6,'s',20);
%! assert(out, res_tisean(:,2),-1e-6);
