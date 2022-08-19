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
## @deftypefn{Function File} {@var{output} =} lzo_run (@var{S})
## @deftypefnx{Function File} {@var{output} =} lzo_run (@var{S}, @var{paramName}, @var{paramValue}, @dots{})
##
## This program fits a locally zeroth order model to a possibly multivariate
## time series and iterates the time series into the future. The existing data
## set is extended starting with the last point in time. It is possible to add
## gaussian white dynamical noise during the iteration.
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
## Number of iterations into the future [default = 1000].
## @item k
## Minimal number of neighbors for the fit [default = 50].
## @item dnoise
## Add dynamical noise as percentage of the variance, this value is given
## in percentage. The same as flag '-%' from TISEAN [default = no noise (0)].
## @item i
## Seed for the random number generator used to add noise. If set to 0
## the time command is used to create a seed [default = 0x9074325].
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
## @item onlynearest
## If this switch is set then the program uses only the nearest @var{k}
## neighbor found. This is synonymous with flag '-K' from TISEAN.
## @end table
##
## @strong{Output}
##
## Components of the forecasted time series.
##
## @seealso{demo lzo_run, lzo_test, lzo_gm}
##
## @strong{Algorithms}
##
## The algorithms for this functions have been taken from the TISEAN package.
## @end deftypefn

## Author: Piotr Held <pjheld@gmail.com>.
## This function is based on lzo-run of TISEAN 3.0.1 
## https://github.com/heggus/Tisean"

function output = lzo_run (S, varargin)

  if (nargin < 1)
    print_usage;
  endif

  if ((ismatrix (S) == false) || (isreal(S) == false) || ...
       (isreal(S) == false))
    error ('Octave:invalid-input-arg', "S must be a realmatrix");
  endif

  # Default values
  embed    = 2;
  delay    = 1;
  flength  = 1000;
  minn     = 50;
  setsort  = false;
  seed     = 0x9074325;
  eps0     = 1e-3;
  epsset   = false;
  epsf     = 1.2;
  Q        = 0;
  setnoise = false;

  #### Parse the input
  p = inputParser ();
  p.FunctionName = "lzo_run";

  isPositiveIntScalar = @(x) isreal(x) && isscalar (x) && ...
                             (x > 0) && (x-round(x) == 0);
  isNonNegativeIntScalar = @(x) isPositiveIntScalar (x) || (x == 0);
  isPositiveScalar    = @(x) isreal(x) && isscalar (x) && (x > 0);
  isNonNegativeScalar = @(x) isPositiveScalar (x) || (x == 0);

  p.addParamValue ("m", embed, isPositiveIntScalar);
  p.addParamValue ("d", delay, isPositiveIntScalar);
  p.addParamValue ("l", flength, isPositiveIntScalar);
  p.addParamValue ("k", minn, isPositiveIntScalar);
  p.addParamValue ("i", seed, isNonNegativeIntScalar);
  p.addParamValue ("r", eps0, isPositiveScalar);
  p.addParamValue ("f", epsf, isPositiveScalar);
  p.addParamValue ("dnoise", Q, isNonNegativeScalar);
  p.addSwitch ("OnlyNearest");

  p.parse (varargin{:});

  # Assign inputs
  embed    = p.Results.m;
  delay    = p.Results.d;
  flength  = p.Results.l;
  minn     = p.Results.k;
  setsort  = p.Results.OnlyNearest;
  seed     = p.Results.i;
  eps0     = p.Results.r;
  epsset   = !ismember ('r', p.UsingDefaults);
  epsf     = p.Results.f;
  Q        = p.Results.dnoise;
  setnoise = !ismember ('dnoise', p.UsingDefaults);

  # Correct S to always have more rows than columns
  trnspsd = false;
  if (rows (S) < columns (S))
    S = S.';
    trnspsd = true;
  endif

  output = __lzo_run__ (S, embed, delay, flength, minn, setsort, seed,
                        eps0, epsset, epsf, Q, setnoise);

  if (trnspsd)
  output = output.';
  endif

endfunction

%!demo
%! idx = 1:5000;
%% sin_saw is a sinusoid multiplied by a saw function.
%! sin_saw = (5 + mod (idx, 165) ./15) .* sin (idx.* 2 * pi /32);
%! sin_saw = sin_saw.';
%% m=4, d=6 was chosen as the best fit values in demo lzo_test.
%! no_noise = lzo_run (sin_saw(1:4500), 'm',4,'d',6,'l',500);
%! noisy    = lzo_run (sin_saw(1:4500), 'm',4,'d',6, 'dnoise',10,'l',500);
%! plot (no_noise, 'r.', noisy, 'bo',sin_saw(4501:end),'g');
%! legend ("No noise",...
%!         "10% noise",...
%!         "Actual data");
%! legend ("Location", "NorthOutside", "Orientation", "Horizontal");
%! axis tight
%!###############################################################

%!shared in
%! in = [(sin ((1:10000) / (360)).'), (cos ((1:10000) / (360)).')];

%!fail("lzo_run(2)");

%!test
%% res was generated using 'lzo-run -m2,4 -d8 -f2'
%! res = [0.6081981 0.6104005 0.6125982 0.6147912 0.6169795 0.619163 0.6213417 0.6235156 0.6256847 0.627849 0.6300085 0.632163 0.6343127 0.6364575 0.6385974 0.6407324 0.6428624 0.6449875 0.6471076 0.6492227 0.6513327];
%! out = lzo_run (in, 'm', 4, 'd', 8, 'f', 2,'onlynearest');
%! assert (out(end-20:end),res,-1e-6);

%!test
%% res was generated using 'lzo-run -m2,4 -d8 -L20'
%! res = [0.4746743 -0.8801155;0.4730514 -0.8809869;0.4708026 -0.8821883;0.4685045 -0.8834088;0.4661569 -0.8846482;0.4631659 -0.8862157;0.4601181 -0.887801;0.4576502 -0.8890757;0.4551788 -0.8903435;0.4527039 -0.8916045;0.4502255 -0.8928586;0.4477436 -0.8941057;0.4452582 -0.895346;0.4427694 -0.8965794;0.4402772 -0.8978059;0.4377816 -0.8990254;0.4352827 -0.900238;0.4327803 -0.9014436;0.4302746 -0.9026423;0.4277656 -0.903834];
%! out = lzo_run (in, 'm',4,'d',8,'l',20,'onlynearest');
%! assert (out, res, -1e-6);
