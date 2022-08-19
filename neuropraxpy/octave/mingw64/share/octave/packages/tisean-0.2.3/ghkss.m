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
## @deftypefn{Function File} {@var{output} =} ghkss (@var{S})
## @deftypefnx{Function File} {@var{output} =} ghkss (@var{S}, @var{paramName}, @var{paramValue}, @dots{})
##
## Multivariate noise reduction using the GHKSS algorithm.
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
## as all of the available components of @var{S} are analyzed.
## [default = 1].
## @item d
## The delay for the embedding [default = 1].
## @item q
## Dimension of the manifold to project to [default = 2].
## @item k
## Minimal number of neighbours [default = 50].
## @item r
## Minimal size of neighbourhood [default = 1/1000].
## @item i
## Number of iterations [default = 1].
## @end table
##
## @strong {Switches}
##
## @table @var
## @item euclidean
## When this switch is selected the function will use the euclidean metric 
## instead of the tricky one.
## @item verbose
## If this switch is selected the function will give progress reports 
## along the way. Those include the average correction, trend and how many
## points were corrected for which epsilon.
## @end table
##
## @strong {Output}
##
## The @var{output} contains the cleaned time series. The output is of the
## same size as the input.
##
## @strong{Algorithms}
##
## The algorithms for this functions have been taken from the TISEAN package.
## @end deftypefn

## Author: Piotr Held <pjheld@gmail.com>.
## This function is based on ghkss of TISEAN 3.0.1
## https://github.com/heggus/Tisean"

function output = ghkss (S, varargin)

  if (nargin < 1)
    print_usage;
  endif

  if ((!ismatrix (S)) || (!isreal(S)))
    error ('Octave:invalid-input-arg', "S is not a realmatrix");
  endif

  # Define default values
  embed      = 5;
  comp       = 1;
  delay      = 1;
  qdim       = 2;
  minn       = 50;
  mineps     = 1./1000.;
  eps_set    = 0;
  iterations = 1;
  euclidean  = 0;
  verbose    = 0;

  #### Parse the input
  p = inputParser ();
  p.FunctionName = "ghkss";

  isPositiveIntScalar = @(x) isreal(x) && isscalar (x) && ...
                             (x > 0) && (x-round(x) == 0);
  isPositiveScalar     = @(x) isreal(x) && isscalar (x) && (x > 0);

  p.addParamValue ("m", embed, isPositiveIntScalar);
  p.addParamValue ("d", delay, isPositiveIntScalar);
  p.addParamValue ("q", qdim, isPositiveIntScalar);
  p.addParamValue ("k", minn, isPositiveIntScalar);
  p.addParamValue ("r", mineps, isPositiveScalar);
  p.addParamValue ("i", iterations, isPositiveIntScalar);
  p.addSwitch ("euclidean");
  p.addSwitch ("verbose");

  p.parse (varargin{:});

  # Assign inputs
  embed      = p.Results.m;
  delay      = p.Results.d;
  qdim       = p.Results.q;
  minn       = p.Results.k;
  mineps     = p.Results.r;
  eps_set    = !ismember ('r', p.UsingDefaults);
  iterations = p.Results.i;
  euclidean  = p.Results.euclidean;
  verbose    = p.Results.verbose;

  # Correct S to always have more rows than columns
  trnspsd = false;
  if (rows (S) < columns (S))
    S = S.';
    trnspsd = true;
  endif

  # Use all columns as separate components (alter 'm' from original)
  if (columns (S) > 1)
    comp   = columns (S);
  endif

  # Input checking from original main()
  if (rows (S) < minn) 
    error ('Octave::invalid-input-arg', ...
           "With %lu data you will never find %u neighbors.",rows(S),minn);
  endif

  output = __ghkss__ (S, embed, comp, delay, qdim, minn, mineps, eps_set, ...
                      iterations, euclidean, verbose);

  if (trnspsd)
  output = output.';
  endif

endfunction

%!demo
%! hen    = henon (10000);
%! # The following line is equvalent to 'addnoise -v0.02 hen' from TISEAN
%! hen    = hen + std (hen) * 0.02 .* (-6 + sum (rand ([size(hen), 12]), 3));
%! hendel = delay (hen(:,1));
%! hengk = ghkss (hen(:,1),'m',7,'q',2,'r',0.05,'k',20,'i',2);
%! hengk = delay (hengk);
%!
%! subplot (2,3,1)
%! plot (hendel(:,1), hendel(:,2), 'b.','markersize', 3);
%! title ("Noisy data");
%! pbaspect ([1 1 1]);
%! axis tight
%! axis off
%!
%! subplot (2,3,4)
%! plot (hengk(:,1), hengk(:,2),'r.','markersize', 3);
%! title ("Clean data");
%! pbaspect ([1 1 1]);
%! axis tight
%! axis off
%!
%! subplot (2,3,[2 3 5 6])
%! plot (hendel(:,1), hendel(:,2), 'b.','markersize', 3,...
%!       hengk(:,1), hengk(:,2),'r.','markersize', 3);
%! legend ("Noisy", "Clean");
%! title ("Superimposed data");
%! axis tight

%!###############################################################

%!fail ("ghkss (1:10,'k',11)");
%!fail ("ghkss (rand(50,1))");
%!xtest ("ghkss (rand(50))");

%!test
%! "res was created running 'ghkss -k5' from TISEAN on 'in'";
%! in = [1.103556129288296; 1.242752956263521; 1.083069768858902; 1.075266648105394; 1.400623241697165; 1.037690499824349; 1.461415094264967; 1.295560284337681; 1.116149954336578; 1.323253666984052];
%! res = [1.103556e+00; 1.237084e+00; 1.192734e+00; 1.150288e+00; 1.360435e+00; 1.048788e+00; 1.337826e+00; 1.228952e+00; 1.156421e+00; 1.323254e+00];
%! cln = ghkss (in, 'k', 5);
%! assert (cln, res, 1e-6);
