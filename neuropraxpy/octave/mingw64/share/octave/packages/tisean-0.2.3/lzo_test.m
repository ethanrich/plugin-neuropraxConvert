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
## @deftypefn{Function File} {[@var{rel}, @var{ind}] =} lzo_test (@var{S})
## @deftypefnx{Function File} {[@var{rel}, @var{ind}] =} lzo_test (@var{S}, @var{paramName}, @var{paramValue}, @dots{})
##
## Estimates the average forecast error for a zeroth
## order fit from a multidimensional time series
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
## @item tdist
## Temporal distance between the reference points [default = 1].
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
## @strong{Switch}
##
## @table @var
## @item onlynearest
## If this switch is set then the program uses only the nearest @var{k}
## neighbor found. This is synonymous with flag '-K' from TISEAN.
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
## @item ind
## This is a matrix that contais the individual forecast error for each
## comonent of each reference point. This is the same as passing '-V2' 
## to TISEAN lzo-test.
## @end table
##
## @seealso{demo lzo_test, lzo_gm, lzo_run}
##
## @strong{Algorithms}
##
## The algorithms for this functions have been taken from the TISEAN package.
## @end deftypefn

## Author: Piotr Held <pjheld@gmail.com>.
## This function is based on lzo-test of TISEAN 3.0.1 
## https://github.com/heggus/Tisean"

function [rel, ind] = lzo_test (S,varargin)

  if (nargin < 1 || nargout > 2)
    print_usage;
  endif

  if ((ismatrix (S) == false) || (isreal(S) == false) || ...
       (isreal(S) == false))
    error ('Octave:invalid-input-arg', "S must be a realmatrix");
  endif

 # Default values
  embed      = 2;
  delay      = 1;
  clength    = length (S);
  clengthset = 0;
  refstep    = 1;
  minn       = 30;
  eps0       = 1e-3;
  epsset     = 0;
  epsf       = 1.2;
  step       = 1;
  causal     = step;


  #### Parse the input
  p = inputParser ();
  p.FunctionName = "lzo_test";

  isPositiveIntScalar = @(x) isreal(x) && isscalar (x) && ...
                             (x > 0) && (x-round(x) == 0);
  isPositiveScalar     = @(x) isreal(x) && isscalar (x) && (x > 0);

  p.addParamValue ("m", embed, isPositiveIntScalar);
  p.addParamValue ("d", delay, isPositiveIntScalar);
  p.addParamValue ("n", clength, isPositiveIntScalar);
  p.addParamValue ("tdist", refstep, isPositiveIntScalar);
  p.addParamValue ("k", minn, isPositiveIntScalar);
  p.addParamValue ("r", eps0, isPositiveScalar);
  p.addParamValue ("f", epsf, isPositiveScalar);
  p.addParamValue ("s", step, isPositiveIntScalar);
  p.addParamValue ("c", causal, isPositiveIntScalar);
  p.addSwitch ("OnlyNearest");

  p.parse (varargin{:});

  # Assign inputs
  embed      = p.Results.m;
  delay      = p.Results.d;
  clength    = p.Results.n;
  clengthset = !ismember ('n', p.UsingDefaults);
  refstep    = p.Results.tdist;
  minn       = p.Results.k;
  eps0       = p.Results.r;
  epsset     = !ismember ('r', p.UsingDefaults);
  epsf       = p.Results.f;
  step       = p.Results.s;
  setsort    = p.Results.OnlyNearest;

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

  # Input checking from original main()
  if ((2*step + causal) >= (length (S) - embed*delay - minn))
    error ('Octave:invalid-input-arg', ...
            "steps to forecast (parameter s) too large");
  endif

  if (nargout == 2)
    [rel, ind] = __lzo_test__ (S, embed, delay, clength, ...
                               clengthset, refstep, minn, eps0, epsset, ...
                               epsf, step, causal, setsort);
    if (trnspsd)
      ind = ind.';
    endif
  else
    rel        = __lzo_test__ (S, embed, delay, clength, ...
                               clengthset, refstep, minn, eps0, epsset, ...
                               epsf, step, causal, setsort);
  endif

  if (trnspsd)
  rel = rel.';
  endif

endfunction

%!demo
%! idx = (1:10000).';
%! # sin_saw is a sinusoid multiplied by a saw function.
%! sin_saw = (5 + mod (idx, 165) ./ 15) .* sin (idx.* 2 * pi /32);
%! steps = 250;
%! rel1  = lzo_test (sin_saw, 'm', 2, 'd', 6, 's', steps);
%! rel2  = lzo_test (sin_saw, 'm', 3, 'd', 6, 's', steps);
%! rel3  = lzo_test (sin_saw, 'm', 4, 'd', 1, 's', steps);
%! rel4  = lzo_test (sin_saw, 'm', 4, 'd', 6, 's', steps);
%! plot (rel1(:,1), rel1(:,2), 'r', ...
%!       rel2(:,1), rel2(:,2), 'g',...
%!       rel3(:,1), rel3(:,2), 'b',...
%!       rel4(:,1), rel4(:,2), 'm');
%! legend ('m = 2, d = 6', 'm = 3, d = 6','m = 4, d = 1', 'm = 4, d = 6');
%! xlabel ("Forecast time");
%! ylabel ("Relative forecast error");
%! axis tight
%!###############################################################

%!shared in
%! in = [(sin ((1:10000) / (360)).'), (cos ((1:10000) / (360)).')];

%!fail("lzo_test((1:500),'s',250)");
%!fail("lzo_test(1)");
%!xtest("lzo_test(1:100)");

%!test
%% res was generated using 'lzo-test in.dat -m2,4 -d2 -s20'
%! res = [1 0.000370023 0.0003827109;2 0.000370013 0.0003827208;3 0.0003700032 0.0003827305;4 0.0003699935 0.00038274;5 0.000369984 0.0003827494;6 0.0003699746 0.0003827587;7 0.0003699653 0.0003827679;8 0.0003699562 0.0003827769;9 0.0003699472 0.0003827858;10 0.0003699383 0.0003827946;11 0.0003699296 0.0003828032;12 0.000369921 0.0003828117;13 0.0003699125 0.0003828201;14 0.0003699042 0.0003828283;15 0.000369896 0.0003828364;16 0.0003698879 0.0003828443;17 0.00036988 0.0003828521;18 0.0003698722 0.0003828598;19 0.0003698646 0.0003828673;20 0.0003698571 0.0003828747];
%! lz = lzo_test (in, 'm', 4, 'd', 2, 's', 20);
%! assert (lz, res, -1e-6);

%!test
%% res was generated using 'lzo-test in.dat -m2,4 -d2 -s20 -n25 -V2'
%! res = [0.0003670822 -5.345778e-05;0.0003669323 -5.447724e-05;0.0003667796 -5.549629e-05;0.000366624 -5.651491e-05;0.0003664656 -5.753309e-05;0.0003663044 -5.855082e-05;0.0003661403 -5.956811e-05;0.0003659734 -6.058493e-05;0.0003658037 -6.160129e-05;0.0003656312 -6.261717e-05;0.0003654559 -6.363257e-05;0.0003652777 -6.464748e-05;0.0003650967 -6.566189e-05;0.0003649129 -6.667579e-05;0.0003647263 -6.768918e-05;0.0003645368 -6.870205e-05;0.0003643446 -6.971438e-05;0.0003641495 -7.072618e-05;0.0003639517 -7.173743e-05];
%! [rel, ind] = lzo_test (in, 'm', 4, 'd', 2, 's', 20, 'n', 25);
%! assert (ind, res, -1e-6);

