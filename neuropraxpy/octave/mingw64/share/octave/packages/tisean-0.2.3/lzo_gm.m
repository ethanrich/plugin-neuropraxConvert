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
## Estimates the average forecast error for a local
## constant (zeroth order) fit as a function of the neighborhood size.
## The name "lzo_gm" means 'local zeroth order -> global mean'.
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
## @strong {Output}
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
## @seealso{lzo_test, lzo_run}
##
## @strong{Algorithms}
##
## The algorithms for this functions have been taken from the TISEAN package.
## @end deftypefn

## Author: Piotr Held <pjheld@gmail.com>.
## This function is based on lzo-gm of TISEAN 3.0.1
## https://github.com/heggus/Tisean"

function output = lzo_gm (S, varargin)

  if (nargin < 1)
    print_usage;
  endif

  if ((ismatrix (S) == false) || (isreal(S) == false) || ...
       (isreal(S) == false))
    error ('Octave:invalid-input-arg', "S must be a realmatrix");
  endif

  # Default values
  embed     = 2;
  delay     = 1;
  clength   = length (S);
  eps0      = 1e-3;
  eps0set   = 0;
  eps1      = 1.0;
  eps1set   = 0;
  epsf      = 1.2; 
  step      = 1;
  causal    = step;

  #### Parse the input
  p = inputParser ();
  p.FunctionName = "lzo_gm";

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


  output = __lzo_gm__ (S, embed, delay, clength, eps0, eps0set, ...
                       eps1, eps1set, epsf, step, causal);

  if (trnspsd)
  output = output.';
  endif


endfunction


%!test
%! res = lzo_gm((1:500),'s',250);
%! assert (isempty (res));

%!fail("lzo_test(2)");

%!test
%! in = [(sin ((1:800) / (360)).'), (cos ((1:800) / (360)).')];
%! lzo_gm_res = [0.3177514 5.832589 8.960147 2.70503 0.202346 23.71739;0.3813016 0.9768847 1.309398 0.6443708 0.6334311 52.70833;0.4575619 0.7291856 0.9129027 0.5454685 0.7580645 88.4236;0.5490743 0.6127415 0.6892565 0.5362266 0.872434 128.6151;0.6588892 0.6677921 0.7556775 0.5799066 1 168.2273;0.790667 0.7833726 0.8609434 0.7058018 1 230.3416;0.9488005 0.9280836 0.9918559 0.8643113 1 299.7463;1.138561 1.091321 1.125727 1.056915 1 374.4912;1.366273 1.242503 1.237341 1.247664 1 443.8138;1.639527 1.332956 1.320074 1.345837 1 481.3798;1.967433 1.332956 1.320074 1.345837 1 481.3798;2.360919 1.332956 1.320074 1.345837 1 481.3798];
%! res = lzo_gm (in, 'm', 4, 'd', 6, 's', 100, 'rhigh', 2);
%! assert (res, lzo_gm_res, -1e-6);
