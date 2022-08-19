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
## @deftypefn{Function File} {[@var{rel}, @var{ind}] =} lfo_test (@var{S})
## @deftypefnx{Function File} {[@var{rel}, @var{ind}] =} lfo_test (@var{S}, @var{paramName}, @var{paramValue}, @dots{})
##
## Makes a local linear ansatz and estimates the one step prediction error of
## the model. It allows to determine the optimal set of parameters for the
## program lfo-run, which iterates the local linear model to get a clean
## trajectory. The given forecast error is normalized to the variance of
## the data.
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
## @strong {Parameters}
##
## @table @var
## @item m
## The embedding dimension used. It is synonymous to the second part 
## of flag '-m' from TISEAN. The first part of the TISEAN flag is omitted
## as all of the available components of @var{S} are analyzed
## [default = 1].
## @item d
## Delay used for the embedding [default = 1].
## @item n
## Sets for how many points the error should be calculated [default is 
## for all of the points].
## @item k
## Minimum number of neighbors for the fit [default = 30].
## @item r
## Size of neighbourhood to start with [default = 1/1000].
## @item f
## Factor to increase the neighbourhood size if not enough
## naighbors were found [default = 1.2].
## @item s
## Steps to be forecast @code{x(n+s) = f(x(n))} [default = 1].
## @item c
## Width of causality window [default = value of parameter '@var{s}'].
## @end table
##
## @strong{Outputs}
##
## @table @var
## @item rel
## This is a matrix of length equal to the parameter '@var{s}'. It contains
## the relative forecast error. The first column (row depending on the input)
## contains the steps forecasted. Relative means that the forecast error
## is divided by the standard deviation of the vector component.
## Note: This does output is different than that of lzo_test. Here it gives 
## relative forecast error for each component globally, not for each
## forecasted datapoint of each component.
## @item ind
## This is a matrix that contais the individual forecast error for each
## comonent of each reference point. This is the same as passing '-V2' 
## to TISEAN lfo-test.
## @end table
##
## @seealso{lfo_ar, lfo_run}
##
## @strong{Algorithms}
##
## The algorithms for this functions have been taken from the TISEAN package.
## @end deftypefn

## Author: Piotr Held <pjheld@gmail.com>.
## This function is based on lfo-test of TISEAN 3.0.1 
## https://github.com/heggus/Tisean"

function [rel, ind] = lfo_test (S,varargin)

  if (nargin < 1 || nargout > 2)
    print_usage;
  endif

  if ((ismatrix (S) == false) || (isreal(S) == false) || ...
       (isreal(S) == false))
    error ('Octave:invalid-input-arg', "S must be a realmatrix");
  endif

  # Default values
  embed   = 2;
  delay   = 1;
  clength = length (S);
  minn    = 30;
  eps0    = 1e-3;
  epsf    = 1.2;
  step    = 1;
  causal  = step;

  #### Parse the input
  p = inputParser ();
  p.FunctionName = "lfo_test";

  isPositiveIntScalar = @(x) isreal(x) && isscalar (x) && ...
                             (x > 0) && (x-round(x) == 0);
  isPositiveScalar     = @(x) isreal(x) && isscalar (x) && (x > 0);

  p.addParamValue ("m", embed, isPositiveIntScalar);
  p.addParamValue ("d", delay, isPositiveIntScalar);
  p.addParamValue ("n", clength, isPositiveIntScalar);
  p.addParamValue ("k", minn, isPositiveIntScalar);
  p.addParamValue ("r", eps0, isPositiveScalar);
  p.addParamValue ("f", epsf, isPositiveScalar);
  p.addParamValue ("s", step, isPositiveIntScalar);
  p.addParamValue ("c", causal, isPositiveIntScalar);

  p.parse (varargin{:});

  # Assign inputs
  embed     = p.Results.m;
  delay     = p.Results.d;
  clength   = p.Results.n;
  minn      = p.Results.k;
  eps0      = p.Results.r;
  epsset    = !ismember ('r',p.UsingDefaults);
  epsf      = p.Results.f;
  step      = p.Results.s;

  # From lzo-test main()
  if (ismember ('c', p.UsingDefaults))
    causal    = step;
  else
    causal    = p.Results.c;
  endif

  # Correct S to always have more rows than columns
  trnspsd = false;
  if (rows (S) < columns (S))
    S = S.';
    trnspsd = true;
  endif

  # Input validation
  # Ensure there is no segmentation fault in the program
  if (clength < step)
    error ('Octave:invalid-input-arg', ...
           "The number of points for which to calculate error (parameter 'n')\
is larger than steps to be forecast (parameter 's')");
  endif

  # Checks if the data is not too short
  if ((length (S)-(embed-1)*delay) < minn)
    error ('Octave:invalid-input-arg', ...
           'Data set is too short to find enough neighbors for the fit');
  endif

  if (nargout == 2)
    [rel, ind] = __lfo_test__ (S, embed, delay, clength, ...
                               minn, eps0, epsset, ...
                               epsf, step, causal);
    if (trnspsd)
      ind = ind.';
    endif
  else
    rel        = __lfo_test__ (S, embed, delay, clength, ...
                               minn, eps0, epsset, ...
                               epsf, step, causal);
  endif

  if (trnspsd)
  rel = rel.';
  endif

endfunction

%!fail("lfo_test((1:30))");
%!fail("lfo_test(henon(100),'s',26,'n',25)");

%!shared rel

%!test
%! lfo_test_res = [-0.6092615 5.677122e-16;-0.08420277 -5.393266e-15;-0.2244035 4.257841e-15;-0.1662528 1.305738e-14;-0.3345843 1.135424e-15;0.3102795 -3.775286e-14;0.0515371 1.951511e-15;-0.6680323 3.264345e-15;-0.1297309 2.838561e-16;-0.1440459 1.135424e-15;-0.01528415 -1.135424e-15];
%! [rel, ind] = lfo_test(henon(1000), 'm',4, 'd', 6, 'n', 30);
%! assert (ind, lfo_test_res,1e-7)

%!assert (rel, [4.438417e-01; 1.686444e-14], 1e-7);

%% check for near singular matrix
%!shared in
%! in = [(sin ((1:800) / (180)).'), (cos ((1:800) / (180)).')];
%!error <singular> lfo_test(in, 'm', 4, 'd',6, 's',250);

%% Check for neverending execution
%!error <too large> lfo_test(1:500, 's',250);
