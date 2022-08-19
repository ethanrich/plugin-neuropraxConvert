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
## @deftypefn{Function File} {@var{output} =} lzo_gm (@var{S})
## @deftypefnx{Function File} {@var{output} =} lzo_gm (@var{S}, @var{paramName}, @var{paramValue}, @dots{})
##
## This program makes a local linear ansatz and estimates the one step
## prediction error of the model. The difference to lfo-test is that it does
## it as a function of the neighborhood size.
## The name "lzo_ar" means 'local first order -> AR-model'.
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
## @item i
## For how many points should the error be calculated [default = 
## length (@var{S})].
## @item rlow
## The neighborhood size to start with [default = 1e-3].
## @item rhigh
## The neighborhood size to end with [default = 1].
## @item f
## Factor to increase neighborhood size if not enough neighbors were
## found [default = 1.2].
## @item s
## Steps to be forecast @code{x(n+s) = f(x(n))} [default = 1].
## @item c
## Width of causality window [default = value of parameter @var{s}]
## @end table
##
## @strong{Output}
##
## The output is alligned with the input. If the components of the 
## input(@var{S}) were column vectors then the number of columns of the
## output is 4 + number of components of @var{S}. In this case the output
## will have the following values in each row:
## @itemize @bullet
## @item
## Neighborhood size (units of data)
## @item
## Relative forecast error ((forecast error)/(variance of data))
## @item
## Relative forecast error for the individual components of the input,
## this will take as many columns as the input has
## @item
## Fraction of points for which neighbors were found for this neighborhood size
## @item
## Average number of neighbors found per point
## @end itemize
##
## @seealso{demo lfo_ar, lfo_test, lfo_run}
##
## @strong{Algorithms}
##
## The algorithms for this functions have been taken from the TISEAN package.
## @end deftypefn

## Author: Piotr Held <pjheld@gmail.com>.
## This function is based on lfo-ar of TISEAN 3.0.1
## https://github.com/heggus/Tisean"

function output = lfo_ar (S, varargin)

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
  clength = length (S);
  eps0    = 1e-3;
  eps0set = false;
  eps1    = 1;
  eps1set = false;
  epsf    = 1.2;
  step    = 1;
  causal  = step;

#### Parse the input
  p = inputParser ();
  p.FunctionName = "lfo_ar";

  isPositiveIntScalar = @(x) isreal(x) && isscalar (x) && ...
                             (x > 0) && (x-round(x) == 0);
  isPositiveScalar     = @(x) isreal(x) && isscalar (x) && (x > 0);

  p.addParamValue ("m", embed, isPositiveIntScalar);
  p.addParamValue ("d", delay, isPositiveIntScalar);
  p.addParamValue ("i", clength, isPositiveIntScalar);
  p.addParamValue ("rlow", eps0, isPositiveScalar);
  p.addParamValue ("rhigh", eps1, isPositiveScalar);
  p.addParamValue ("f", epsf, isPositiveScalar);
  p.addParamValue ("s", step, isPositiveIntScalar);
  p.addParamValue ("c", causal, isPositiveIntScalar);
  p.addSwitch ("verbose");

  p.parse (varargin{:});

  # Assign inputs
  embed   = p.Results.m;
  delay   = p.Results.d;
  clength = p.Results.i;
  eps0    = p.Results.rlow;
  eps0set = !ismember ('rlow', p.UsingDefaults);
  eps1    = p.Results.rhigh;
  eps1set = !ismember ('rhigh', p.UsingDefaults);
  epsf    = p.Results.f;
  step    = p.Results.s;
  verbose = p.Results.verbose;

  # If causal is not set the default is the value of parameter 's'
  if (ismember ('c', p.UsingDefaults))
    causal = step;
  else
    causal = p.Results.c;
  endif

  # Correct S to always have more rows than columns
  trnspsd = false;
  if (rows (S) < columns (S))
    S = S.';
    trnspsd = true;
  endif

  output = __lfo_ar__ (S, embed, delay, clength, eps0, eps0set, ...
                       eps1, eps1set, epsf, step, causal, verbose);

  if (trnspsd)
  output = output.';
  endif
endfunction

%!demo
%! verbose = yes_or_no ("Would you like this to be run verbose? (it may take\
%!  a while to complete)\n");
%!
%! ar4 = arma_rnd([0.3,0.3,-0.3,0.3],[],0.1,1000,100);
%! if (verbose)
%!   res_hen     = lfo_ar (henon(5000)(:,1),'m',4,'d',6,'verbose');
%!   res_ikeda   = lfo_ar (ikeda(5000)(:,1), 'm',4, 'd', 3, 'verbose');
%!   res_ar      = lfo_ar(ar4,'m',4,'d',1,'verbose');
%! else
%!   res_hen     = lfo_ar (henon(5000)(:,1),'m',4,'d',6);
%!   res_ikeda   = lfo_ar (ikeda(5000)(:,1), 'm',4, 'd', 3);
%!   res_ar      = lfo_ar(ar4,'m',3,'d',1);
%! endif
%!
%! semilogx (res_hen(:,1), res_hen(:,2),'-g',...
%!           res_ikeda(:,1), res_ikeda(:,2),'-b',...
%!           res_ar(:,1), res_ar(:,2),'-r')
%! ylim([0 1]);
%! legend ('Henon', 'Ikeda','AR(4)')
%! xlabel ("Neighborhood Radius (size)")
%! ylabel ("Normalized error")
%!###############################################################

%!fail("lfo_ar(2)");

%!test
%! hen = henon (1000);
%! lfo_ar_res = [0.7282938 1.131588 1.062527 1.200649 0.009562842 21.57143;0.8739526 1.137836 1.142633 1.133039 0.1270492 25.23656;1.048743 1.165663 1.163948 1.167378 0.4043716 34.79054;1.258492 1.106056 1.085286 1.126825 0.681694 51.45491;1.51019 1.089661 1.087304 1.092017 0.9262295 80.66667;1.812228 1.031237 1.015163 1.047312 1 149.6667;2.174674 1.010981 0.9995845 1.022378 1 247.6708;2.609608 1.004337 0.9968726 1.011801 1 305.3975];
%! res = lfo_ar (hen, 'm',4,'d',6,'s',250);
%! assert (res, lfo_ar_res, 1e-4);

%% check for near singular matrix
%!shared in
%! in = [(sin ((1:800) / (180)).'), (cos ((1:800) / (180)).')];
%!error <singular> lfo_ar(in, 'm', 4, 'd',6, 's',250);
