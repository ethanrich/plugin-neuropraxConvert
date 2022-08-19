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
## @deftypefn{Function File} {@var{output} =} lyap_r (@var{X})
## @deftypefnx{Function File} {@var{output} =} lyap_r (@var{X}, @var{paramName}, @var{paramValue}, @dots{})
##
## Estimates the largest Lyapunov exponent of a given scalar data set using
## the algorithm described by Resentein et al. on the TISEAN refernce page:
##
## http://www.mpipks-dresden.mpg.de/~tisean/Tisean_3.0.1/docs/chaospaper/citation.html
##
## @strong{Input}
##
## @table @var
## @item X
## Must be realvector. The output will be alligned with the input.
## @end table
##
## @strong{Parameters}
##
## @table @var
## @item m
## Embedding dimension to use [default = 2].
## @item d
## Delay used [default = 1].
## @item t
## Window around the reference point which should be omitted [default = 0].
## @item r
## Minimum length scale for the neighborhood search [default = 1e-3].
## @item s
## Number of iterations in time [default = 10].
## @end table
##
## @strong{Switch}
##
## @table @var
## @item verbose
## Gives information about the current epsilon while performing computation.
## @end table
##
## @strong{Output}
##
## Alligned with input. If input was a column vector than output contains two
## columns. The first contains the iteration number and
## the second contains the logarithm of the stretching factor for that
## iteration.
##
## @seealso{demo lyap_r, lyap_k, lyap_spec}
##
## @strong{Algorithms}
##
## The algorithms for this functions have been taken from the TISEAN package.
## @end deftypefn

## Author: Piotr Held <pjheld@gmail.com>.
## This function is based on lyap_r of TISEAN 3.0.1 
## https://github.com/heggus/Tisean"

function output = lyap_r (X, varargin)

  # Initial input validation
  if (nargin < 1)
    print_usage;
  endif

  if ((isvector (X) == false) || (isreal(X) == false))
    error ('Octave:invalid-input-arg', "X must be a realvector");
  endif

  # Default parameters
  embdim  = 2;
  delay   = 1;
  mindist = 0;
  eps0    = 1e-3;
  steps   = 10;

  #### Parse the input
  p = inputParser ();
  p.FunctionName = "lyap_r";

  isPositiveIntScalar    = @(x) isreal(x) && isscalar (x) && ...
                             (x > 0) && (x-round(x) == 0);
  isNonNegativeIntScalar = @(x) isPositiveIntScalar (x) || (length (x) == 1 ...
                                                            &&(x == 0));
  isPositiveScalar       = @(x) isreal(x) && isscalar (x) && (x > 0);

  p.addParamValue ("m", embdim, isPositiveIntScalar);
  p.addParamValue ("d", delay, isPositiveIntScalar);
  p.addParamValue ("t", mindist, isNonNegativeIntScalar);
  p.addParamValue ("r", eps0, isPositiveScalar);
  p.addParamValue ("s", steps, isPositiveIntScalar);
  p.addSwitch ("verbose");

  p.parse (varargin{:});

  # Assign inputs
  embdim  = p.Results.m;
  delay   = p.Results.d;
  mindist = p.Results.t;
  eps0    = p.Results.r;
  epsset  = !ismember ('r', p.UsingDefaults);
  steps   = p.Results.s;
  verbose = p.Results.verbose;

  # Correct X to always have more rows than columns
  trnspsd = false;
  if (rows (X) < columns (X))
    X = X.';
    trnspsd = true;
  endif

  output = __lyap_r__ (X, embdim, delay, mindist, eps0, epsset, steps,...
                       verbose);

  if (trnspsd)
    output = output.';
  endif

endfunction

%!demo
%! idx = (1:2500).';
%! in = sin (idx ./ 360) + cos (idx ./ 180);
%! mmax = 15;
%!
%! cla reset
%! hold on
%! for i=2:mmax
%!   res = lyap_r (in, 'm', i, 'd', 6, 's',400,'t',200);
%!   plot (res(:,1),res(:,2),'r');
%! endfor
%! axis tight
%! xlabel ("t [flow samples]");
%! ylabel ("S(eps, embed, t)");
%! hold off
%!###############################################################


%!test
%! lyap_r_res =  [0 -2.983802;1 -2.980538;2 -2.962341;3 -2.931719;4 -2.891934;5 -2.846183;6 -2.797121;7 -2.74671;8 -2.69629;9 -2.646711;10 -2.598477];
%! in = sin((1:1000).'./360);
%! res = lyap_r (in, 'm',4 ,'d',6,'s',10,'t',100);
%! assert (res, lyap_r_res, -1e-6);

%% Check if transposed output works correctly
%!test
%! res1 = lyap_r(1:100);
%! res2 = lyap_r((1:100).');
%! assert(res1.',res2);

%!error <ranges> lyap_r (1)
%% Check if program does not run forever
%!error <too large> lyap_r (1:12)
