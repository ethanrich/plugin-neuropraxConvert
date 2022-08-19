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
## @deftypefn{Function File} {[@var{dim}, @var{frac}, @var{avgsize}, @var{avgsrtsize}] =} false_nearest (@var{S})
## @deftypefnx{Function File} {@dots{} =} false_nearest (@var{S}, @var{paramName}, @var{paramValue}, @dots{})
## 
## Determines the fraction of false nearest neighbors.
##
## @strong{Input}
##
## @table @var
## @item S
## This function always assumes that each time series is along the longer dimension of matrix 
## @var{S}. It also assumes that every dimension (counting along the shorter dimension) of 
## @var{S} is considered a component of the time series. So
## @example
##
## @var{S} = [[1:1000];[5:1004]]
##
## @end example
## would be considered a 2 component, 1000 element time series. 
## @end table
##
## @strong {Parameters}
##
## @table @var
## @item minemb
## This is the flag '-m' from TISEAN. It is the minimal embedding dimensions of 
## the vectors [default = 1].
## @item maxemb
## This parameter is consistent with the second part of the flag '-M' from TISEAN. The first part of
## that flag is unnecessary as this function assumes that all components of the input data are used.
## This parameter determines the maximum embedding dimension of the vectors [default = 5].
## @item d
## The delay of the vectors [default = 1].
## @item t
## The theiler window [default = 0].
## @item f
## Ratio factor [default = 2.0].
## @end table
##
## @strong {Switches}
##
## @table @var
## @item verbose
## If this switch is selected the function will give progress reports along the way.
## @end table
##
## @strong {Outputs}
##
## @table @var
## @item dim
## This holds the dimension of the output data.
## @item frac
## The fraction of false nearest neighbors.
## @item avgsize
## The average size of the neighborhood.
## @item avgrtsize
## The average of the squared size of the neighborhood.
## @end table
##
## See also: http://www.mpipks-dresden.mpg.de/~tisean/Tisean_3.0.1/docs/docs_c/false_nearest.html
## or demo for more information.
## 
## @strong{Algorithms}
##
## The algorithms for this functions have been taken from the TISEAN package.
## @end deftypefn

## Author: Piotr Held <pjheld@gmail.com>.
## This function is based on false_nearest of TISEAN 3.0.1
## https://github.com/heggus/Tisean"

function [dim, frac, avgsize, avgrtsize] = false_nearest (S,varargin)

  if (nargin < 1)
    print_usage;
  endif

  if ((!ismatrix (S)) || (!isreal(S)))
    error ('Octave:invalid-input-arg', "S is not a realmatrix");
  endif

  # Define default values for delay variables
  minemb  = 1;
  comp    = 1;
  maxemb  = 5;
  dimset  = 0;
  delay   = 1;
  rt      = 2.0;
  theiler = 0;

  #### Parse the input
  p = inputParser ();
  p.FunctionName = "false_nearest";

  isPositiveIntScalar = @(x) isreal(x) && isscalar (x) && ...
                             (x > 0) && (x-round(x) == 0);
  isUnsignedIntScalar = @(x) isPositiveIntScalar (x) || (x == 0);
  isNumericScalar     = @(x) isreal(x) && isscalar (x);

  p.addParamValue ("minemb", minemb, isPositiveIntScalar);
  p.addParamValue ("maxemb", maxemb, isPositiveIntScalar);
  p.addParamValue ("d", delay, isPositiveIntScalar);
  p.addParamValue ("t", theiler, isUnsignedIntScalar);
  p.addParamValue ("f", rt, isNumericScalar);
  p.addSwitch ("verbose");

  p.parse (varargin{:});

  # Assign inputs
  minemb  = p.Results.minemb;
  maxemb  = p.Results.maxemb;
  dimset  = !ismember ('maxemb',p.UsingDefaults);
  delay   = p.Results.d;
  theiler = p.Results.t;
  rt      = p.Results.f;
  verbose = p.Results.verbose;

  # Correct S to always have more rows than columns
  trnspsd = false;
  if (rows (S) < columns (S))
    S = S.';
    trnspsd = true;
  endif

  # Use all columns as separate components (alter 'M' from original)
  if (columns (S) > 1)
    dimset = 1;
    comp   = columns (S);
  endif

  # Input checking from original main()
  if (maxemb*delay + 1 >= length (S))
    error ('Octave:invalid-input-arg', "Not enough points");
  endif

  [dim, frac, avgsize, avgrtsize] = ...
__false_nearest__ (S, minemb, comp, maxemb, dimset, delay, theiler, rt,verbose);

  if (trnspsd)
    dim       = dim.';
    frac      = frac.';
    avgsize   = avgsize.';
    avgrtsize = avgsrtsize.';
  endif

endfunction

%!demo
%! ikd          = ikeda (10000);
%! hen          = henon (10000);
%! hen_noise    = hen + mean (hen) * 0.01 .* (-6 + sum (rand ([size(hen), 12]), 3));
%! [dikd, fikd] = false_nearest (ikd(:,1));
%! [dhen, fhen] = false_nearest (hen(:,1));
%! [dhno, fhno] = false_nearest (hen_noise(:,1));
%! plot (dikd, fikd, '-b*', 'markersize', 15,...
%!       dhen, fhen, '-r+', 'markersize', 15,...
%!       dhno, fhno, '-gx', 'markersize', 15);
%! legend ("Ikeda", "Henon", "Noisy Henon");
%! ylim ([0, 1]);
%!###############################################################

%!fail ("false_nearest ((1:5))");
%!xtest ("false_nearest (1:100)");

%!test
%! "res was generated using 'false_nearest hen.dat' from TISEAN package";
%! res = [1, 9.248624e-01, 1.264834e-04, 2.051554e-04; 2, 3.312656e-01, 1.052529e-03, 1.494843e-03; 3, 2.923462e-01, 1.611237e-03, 2.331276e-03; 4, 2.880440e-01, 2.345412e-03, 3.454938e-03; 5, 2.695348e-01, 3.401341e-03, 5.028630e-03];
%! hen = henon (10000);
%! [d,f,a,s]  = false_nearest (hen(:,1));
%! assert ([d,f,a,s], res, 1e-6);

%!test
%!
%! res = [3, 2.923462e-01, 1.611237e-03, 2.331276e-03; 6, 2.880440e-01, 2.345412e-03, 3.454938e-03; 9, 2.695348e-01, 3.401341e-03, 5.028630e-03];
%! hen3 = henon (10000);
%! hen3 = delay (hen3(:,1),'m',3);
%! [d,f,a,s] = false_nearest (hen3, 'maxemb', 3);
%! assert ([d,f,a,s], res, 1e-6);
