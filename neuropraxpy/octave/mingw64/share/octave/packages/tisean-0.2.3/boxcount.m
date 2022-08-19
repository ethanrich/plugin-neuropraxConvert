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
## @deftypefn{Function File} {@var{output} =} boxcount (@var{S})
## @deftypefnx{Function File} {@var{output} =} boxcount (@var{S}, @var{paramName}, @var{paramValue}, @dots{})
##
## Estimates the Renyi entropy of Qth order using a partition of the phase
## space instead of using the Grassberger-Procaccia scheme.
##
## The program also can handle multivariate data, so that the phase space is
## build of the components of the time series plus a temporal embedding, if
## desired. Also, note that the memory requirement does not increase
## exponentially like 1/epsilon^M but only like M*(length of series). So it can
## also be used for small epsilon and large M.
## No finite sample corrections are implemented so far.
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
## The maximum embedding dimension [default = 10].
## @item d
## The delay used [default = 1].
## @item q
## Order of the entropy [default = 2.0].
## @item rlow
## Minimum length scale [default = 1e-3].
## @item rhigh
## Maximum length scale [default = 1].
## @item eps_no
## Number of length scale values [default = 20].
## @end table
##
## @strong{Output}
##
## The output is alligned with the input. If the input components where column
## vectors then the output is a 
## maximum-embedding-dimension x number-of-components struct array with the
## following fields:
## @table @var
## @item dim
## Holds the embedding dimension of the struct.
## @item entropy
## The entropy output. Contains three columns which hold:
## @enumerate
## @item
## epsilon
## @item
## Qth order entropy (Hq (dimension,epsilon))
## @item
## Qth order differential entropy 
## (Hq (dimension,epsilon) - Hq (dimension-1,epsilon))
## @end enumerate
## @end table
##
## @seealso{demo boxcount, d2, c1}
##
## @strong{Algorithms}
##
## The algorithms for this functions have been taken from the TISEAN package.
## @end deftypefn

## Author: Piotr Held <pjheld@gmail.com>.
## This function is based on boxcount of TISEAN 3.0.1 
## https://github.com/heggus/Tisean"

function output = boxcount (S, varargin)

  if (nargin < 1)
    print_usage;
  endif

  if ((ismatrix (S) == false) || (isreal(S) == false) || ...
       (isreal(S) == false))
    error ('Octave:invalid-input-arg', "S must be a realmatrix");
  endif

  # Default values
  maxembed = 10;
  delay    = 1;
  Q        = 2;
  epsmin   = 1e-3;
  epsmax   = 1;
  epscount = 20;

  #### Parse the input
  p = inputParser ();
  p.FunctionName = "d2";

  isPositiveIntScalar    = @(x) isreal(x) && isscalar (x) && ...
                             (x > 0) && (x-round(x) == 0);
  isPositiveScalar       = @(x) isreal(x) && isscalar (x) && (x > 0);

  p.addParamValue ("m", maxembed, isPositiveIntScalar);
  p.addParamValue ("d", delay, isPositiveIntScalar);
  p.addParamValue ("q", Q, isPositiveScalar);
  p.addParamValue ("rlow", epsmin, isPositiveScalar);
  p.addParamValue ("rhigh", epsmax, isPositiveScalar);
  p.addParamValue ("eps_no", epscount, isPositiveIntScalar);

  p.parse (varargin{:});

  # Assign inputs
  maxembed  = p.Results.m;
  delay     = p.Results.d;
  Q         = p.Results.q;
  epsmin    = p.Results.rlow;
  epsminset = !ismember ('rlow', p.UsingDefaults);
  epsmax    = p.Results.rhigh;
  epsmaxset = !ismember ('rhigh', p.UsingDefaults);
  epscount  = p.Results.eps_no;

  if (epsmin >= epsmax)
    error ("Octave:invalid-input-arg", ["'rlow' cannot be greater or equal "...
                                        "to 'rhigh'"]);
  endif

  # Correct S to always have more rows than columns
  trnspsd = false;
  if (rows (S) < columns (S))
    S = S.';
    trnspsd = true;
  endif

  output = __boxcount__ (S, maxembed, delay, Q, epsmin, epsminset, epsmax, ...
                         epsmaxset, epscount);

  if (trnspsd)
    output = output.';
  endif

endfunction

%!demo
%! res = boxcount (henon (1000),'m',5);
%!
%! do_plot_entrop = @(x) semilogx (x{1}(:,1),x{1}(:,3),'g');
%! hold on
%! # Show only for first component
%! arrayfun (do_plot_entrop, {res(:,1).entropy});
%! hold off
%! axis tight
%! xlabel ("Epsilon")
%! ylabel ("Differential Entropies");
%! title ("Entropies")
%!###############################################################

%!shared boxcount_res
%! boxcount_res = [2.556748 -0 -0;0.4546613 1.486674 1.486674;0.08085148 3.235789 3.235789;0.01437765 4.783408 4.783408;0.002556748 6.040018 6.040018;2.556748 -0 0;0.4546613 2.362885 0.8762114;0.08085148 4.498971 1.263182;0.01437765 6.037491 1.254084;0.002556748 6.728119 0.6881009;2.556748 -0 0;0.4546613 3.101632 0.7387475;0.08085148 5.287536 0.7885657;0.01437765 6.427517 0.3900256;0.002556748 6.843597 0.1154786;2.556748 -0 0;0.4546613 3.41436 0.3127275;0.08085148 5.496185 0.2086484;0.01437765 6.504975 0.07745806;0.002556748 6.858778 0.01518056];

%!test
%! res = boxcount (henon (1000), 'm', 2, 'd', 2, 'eps_no', 5);
%! assert (cell2mat (vec (reshape ({res.entropy}, size (res)).')),
%!         boxcount_res, -1e-6);

%% Check if transposition executes properly
%!test
%! res = boxcount (henon (1000).', 'm', 2, 'd', 2, 'eps_no', 5);
%! assert (cell2mat (vec (reshape ({res.entropy}, size (res).'))),
%!         boxcount_res, -1e-6);

%% check input validation
%!error <greater> boxcount (henon (100), 'rlow',4,'rhigh',1);
%!error <equal> boxcount (henon (100), 'rlow',1,'rhigh',1);
