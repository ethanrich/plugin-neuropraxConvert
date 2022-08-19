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
## @deftypefn{Function File} {@var{output} =} lfo_run (@var{S})
## @deftypefnx{Function File} {@var{output} =} lfo_run (@var{S}, @var{paramName}, @var{paramValue}, @dots{})
##
## This function depending on whether switch 'zeroth' is set produces either
## a local linear ansatz or a zeroth order ansatz for a possibly multivariate
## time series and iterates an artificial trajectory. The initial values for
## the trajectory are the last points of the original time series. 
## Thus it actually forecasts the time series.
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
## The embedding dimension used. It is synonymous to the second part 
## of flag '-m' from TISEAN. The first part of the TISEAN flag is omitted
## as all of the available components of @var{S} are analyzed
## [default = 1].
## @item d
## Delay used for the embedding [default = 1].
## @item L
## Number of iterations into the future, length of prediction [default = 1000].
## @item k
## Minimal number of neighbors for the fit [default = 30].
## @item r
## Neighborhood size to start with [default = 1e-3].
## @item f
## Factor to increase neighborhood size if not enough neighbors were
## found [default = 1.2].
## @end table
##
## @strong{Switch}
##
## @table @var
## @item zeroth
## Perform a zeroth order fit instead a local linear one. This is synonymous
## with flag '-0' from TISEAN.
## @end table
##
## @strong{Output}
##
## Components of the forecasted time series.
##
## @seealso{lfo_test, lfo_ar, lzo_run}
##
## @strong{Algorithms}
##
## The algorithms for this functions have been taken from the TISEAN package.
## @end deftypefn

## Author: Piotr Held <pjheld@gmail.com>.
## This function is based on lfo-run of TISEAN 3.0.1 
## https://github.com/heggus/Tisean"

function output = lfo_run (S, varargin)

  if (nargin < 1)
    print_usage;
  endif

  if ((ismatrix (S) == false) || (isreal(S) == false) || ...
       (isreal(S) == false))
    error ('Octave:invalid-input-arg', "S must be a realmatrix");
  endif

  # Default values
  embed   = 2;
  delay   = 1;
  flength = 1000;
  minn    = 30;
  eps0    = 1e-3;
  epsf    = 1.2;

  #### Parse the input
  p = inputParser ();
  p.FunctionName = "lfo_run";

  isPositiveIntScalar = @(x) isreal(x) && isscalar (x) && ...
                             (x > 0) && (x-round(x) == 0);
  isNonNegativeIntScalar = @(x) isPositiveIntScalar (x) || (x == 0);
  isPositiveScalar    = @(x) isreal(x) && isscalar (x) && (x > 0);
  isNonNegativeScalar = @(x) isPositiveScalar (x) || (x == 0);

  p.addParamValue ("m", embed, isPositiveIntScalar);
  p.addParamValue ("d", delay, isPositiveIntScalar);
  p.addParamValue ("l", flength, isPositiveIntScalar);
  p.addParamValue ("k", minn, isPositiveIntScalar);
  p.addParamValue ("r", eps0, isPositiveScalar);
  p.addParamValue ("f", epsf, isPositiveScalar);
  p.addSwitch ("zeroth");

  p.parse (varargin{:});

  # Assign inputs
  embed     = p.Results.m;
  delay     = p.Results.d;
  flength   = p.Results.l;
  minn      = p.Results.k;
  eps0      = p.Results.r;
  epsset    = !ismember ('r', p.UsingDefaults);
  epsf      = p.Results.f;
  do_zeroth = p.Results.zeroth;

  # Correct S to always have more rows than columns
  trnspsd = false;
  if (rows (S) < columns (S))
    S = S.';
    trnspsd = true;
  endif

  output = __lfo_run__ (S, embed, delay, flength, minn,
                        eps0, epsset, epsf, do_zeroth);

  if (trnspsd)
  output = output.';
  endif
endfunction

%!test
%! lfo_run_hen = [0.4178371 0.5916857;0.6124674 0.4178371;0.3080429 0.6124674;0.9938561 0.3080429;-0.3374249 0.9938561;0.7975559 -0.3374249;-0.1623264 0.7975559;0.4382906 -0.1623264;0.4370613 0.4382906;0.9818325 0.4370613;-0.3019938 0.9818325;0.8267984 -0.3019938;-0.2345942 0.8267984;0.5331624 -0.2345942;0.4509924 0.5331624];
%! res = lfo_run (henon (1000),'m',4,'d',6,'l',15);
%! assert (res, lfo_run_hen, 1e-5);

%!error <singular> lfo_run(henon(1000));
%!error <forecast failed> lfo_run(1:500,'m',1);

%% Check for neverending execution
%!error <too large> lfo_run(1:10, 'm',1);
