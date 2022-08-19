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
## @deftypefn{Function File} {@var{output} =} c1 (@var{S})
## @deftypefnx{Function File} {@var{output} =} c1 (@var{S}, @var{paramName}, @var{paramValue}, @dots{})
##
## Computers curves for the fixed mass computation of information dimension
## (mentioned in TISEAN 3.0.1 documentation).
##
## A logarithmic range of masses between 1/N and 1 is realised by varying the
## neighbour order k as well as the subsequence length n. For a given mass
## k/n, n is chosen as small is possible as long as k is not smaller than the
## value specified by parameter @var{k} .
##
## You will probably use the auxiliary functions c2d or c2t to process the
## output further. The formula used for the Gaussian kernel correlation sum
## does not apply to the information dimension. 
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
## @item mindim
## The minimum embedding dimension [default = 1].
## @item maxdim
## The maximum embedding dimension [default = 10].
## @item d
## The delay used [default = 1].
## @item t
## Minimum time separation [default = 0].
## @item n
## The number of reference points. That number of points are selected at
## random from all time indices [default = 100].
## @item res
## Resolution, values per octave [default = 2].
## @item i
## Seed for the random numbers [use default seed].
## @item k
## Maximum number of neighbors [default = 100].
## @end table
##
## @strong{Switch}
##
## @table @var
## @item verbose
## Display information about current mass during execution.
## @end table
##
## @strong{Output}
##
## The output is a @var{maxdim} - @var{mindim} + 1 x 1 struct array with the
## following fields:
## @table @var
## @item dim
## The embedding dimension of the struct.
## @item c1
## A matrix with two collumns that contain the following data:
## @enumerate
## @item
## radius
## @item
## 'mass'
## @end enumerate
## @end table
##
## @seealso{demo c1, c2d, c2t}
##
## @strong{Algorithms}
##
## The algorithms for this functions have been taken from the TISEAN package.
## @end deftypefn

## Author: Piotr Held <pjheld@gmail.com>.
## This function is based on c1 of TISEAN 3.0.1 
## https://github.com/heggus/Tisean"

function output = c1 (S, varargin)

  if (nargin < 1)
    print_usage;
  endif

  if ((ismatrix (S) == false) || (isreal(S) == false) || ...
       (isreal(S) == false))
    error ('Octave:invalid-input-arg', "S must be a realmatrix");
  endif

  # Default values
  mindim     = 1;
  maxdim     = 10;
  delay      = 1;
  tmin       = 0;
  cmin       = 100;
  resolution = 2;
  seed       = 0;
  kmax       = 100;

  #### Parse the input
  p = inputParser ();
  p.FunctionName = "c1";

  isPositiveIntScalar    = @(x) isreal(x) && isscalar (x) && ...
                             (x > 0) && (x-round(x) == 0);
  isNonNegativeIntScalar = @(x) isPositiveIntScalar (x) || (x == 0);
  isNonNegativeScalar       = @(x) isreal(x) && isscalar (x) && (x >=0);

  p.addParamValue ("mindim", mindim, isPositiveIntScalar);
  p.addParamValue ("maxdim", maxdim, isPositiveIntScalar);
  p.addParamValue ("d", delay, isPositiveIntScalar);
  p.addParamValue ("t", tmin, isNonNegativeIntScalar);
  p.addParamValue ("n", cmin, isPositiveIntScalar);
  p.addParamValue ("res", resolution, isPositiveIntScalar);
  p.addParamValue ("i", seed, isNonNegativeScalar);
  p.addParamValue ("k", kmax, isPositiveIntScalar);
  p.addSwitch ("verbose");

  p.parse (varargin{:});

  # Assign input
  mindim     = p.Results.mindim;
  maxdim     = p.Results.maxdim;
  delay      = p.Results.d;
  tmin       = p.Results.t;
  cmin       = p.Results.n; 
  resolution = p.Results.res;
  seed       = p.Results.i;
  kmax       = p.Results.k;
  verbose    = p.Results.verbose;

  if (mindim > maxdim)
    warning ("Octave:tisean", ["Parameter 'mindim' is greater than ", ...
                               "'maxdim', setting 'mindim' = 'maxdim'"]);
    mindim = maxdim;
  endif

  # Correct S to always have more rows than columns
  trnspsd = false;
  if (rows (S) < columns (S))
    S = S.';
    trnspsd = true;
  endif

  output = __c1__ (S, mindim, maxdim, delay, tmin, cmin, resolution, seed,
                   kmax, verbose);

endfunction

%!demo
%! res   = c1 (henon (5000)(:,1), 'd', 1, 'maxdim', 6, 't',50, 'n', 500);
%! slope = c2d (res, 2);
%!
%! do_plot_c1  = @(x) semilogx (x{1}(:,1),x{1}(:,2),'g');
%! hold on
%! arrayfun (do_plot_c1, {slope.d});
%! plot ([5e-4 1],[1.2 1.2])
%! hold off
%! axis tight
%! ylim ([0 3]);
%! xlabel ("Epsilon")
%! ylabel ("Local slopes");
%! title ("Information dimension")
%!###############################################################


%% testing if it works with default parameters
%!test
%% res_c1 was generated by TISEAN 3.0.1
%! res_c1 =  [0.00204866193 0.000562021392;0.00458388403 0.00152773259;0.00732116727 0.00251880521;0.0114847319 0.00351527636;0.0178178754 0.00551304966;0.0229953099 0.00751305372;0.0337692834 0.0115151331;0.0432167873 0.0155181978;0.070036374 0.0225279164;0.0809115991 0.0315354168;0.105735436 0.045548249;0.137048692 0.0635655001;0.198512435 0.0905919373;0.249011219 0.127565667;0.336370319 0.180583045;0.417932093 0.255131334;0.533079803 0.361822665;0.760820627 0.510262668;1.17550445 0.726286411;0.00397582119 0.000562021392;0.00887203496 0.00152773259;0.0129663227 0.00251880521;0.0233632866 0.00451370422;0.0256882776 0.00551304966;0.0377443098 0.00851340499;0.0444159135 0.0115151331;0.0625304207 0.0165190343;0.0792045668 0.0225279164;0.112165064 0.0325363018;0.142160922 0.045548249;0.183529988 0.0645664856;0.247998312 0.0905919373;0.365789354 0.128554597;0.479705334 0.181571603;0.648174882 0.25644654;0.828185916 0.361822665;1.0652355 0.512893081;1.51780188 0.726286411];
%! clear __c1__
%! res = c1 (henon (1000), 'maxdim', 2);
%! res_mat = cell2mat({res.c1}.');
%% row 23 and 25 are excluded because TISEAN data was calculated using floats
%% this program uses doubles
%! good_idx = [1:22,24,26:38];
%! assert (res_mat(good_idx,:), res_c1(good_idx,:),-1e-5);
%% bad_idx are used as the idx of those that were further apart than the rest
%! bad_idx = setdiff (1:length(res_c1),good_idx);
%! assert (res_mat(bad_idx,:), res_c1(bad_idx,:),6e-3);

%% testing if works with other-than-default parameters
%!test
%! res_c1 = [0.0343293324 0.000628733949;0.0685995296 0.00170907611;0.104914345 0.00281779026;0.147767007 0.00393254356;0.187380955 0.00616745465;0.242883027 0.00840486214;0.320845127 0.0117625576;0.424331248 0.0162406135;0.5311203 0.0229629427;0.638983071 0.0319196843;0.77487731 0.0453561395;0.95007056 0.0643920898;1.13252032 0.0912670717;1.33960843 0.129390419;1.51084828 0.182906702;1.65632439 0.259117812;1.78787661 0.365813404;1.93386149 0.518235624;2.13333058 0.731626809;0.0578132086 0.000630145252;0.106152184 0.00171291234;0.163010269 0.0028241151;0.214579925 0.00394137064;0.280628532 0.00618129829;0.353775769 0.00842372701;0.448207438 0.0117889596;0.582583368 0.0162770674;0.693925321 0.0230144858;0.805182397 0.0319913328;0.948441863 0.0454579443;1.12319851 0.0645366237;1.28063464 0.0914719254;1.44319057 0.129558906;1.57120717 0.183243573;1.71812892 0.259117812;1.83539987 0.367163211;1.98069465 0.518235624;2.16835737 0.737046182;0.0653617978 0.000630145252;0.120350979 0.00171291234;0.182360902 0.0028241151;0.22783263 0.00394137064;0.300161123 0.00618129829;0.384833038 0.00842372701;0.497192621 0.0117889596;0.616096795 0.0162770674;0.750326335 0.0230144858;0.908238411 0.0331135131;1.03522205 0.0465802066;1.23226273 0.0656589493;1.37276983 0.0925942659;1.53525198 0.130750626;1.65205204 0.184261546;1.77773058 0.260474414;1.88386154 0.368523091;2.01883292 0.520948827;2.19400668 0.737046182];
%! clear __c1__
%! res = c1 (henon (1000), 'mindim', 8, 'd',2,'i',0.5,'t',50,'n',500);
%% row 1, 2, 22 are excluded because TISEAN data was calculated using floats
%% this program uses doubles
%! good_idx = [3:21,23:57];
%! assert (cell2mat({res.c1}.')(good_idx,:), res_c1(good_idx,:), 1e-5);
%% bad_idx are used as the idx of those that were further apart than the rest
%! bad_idx = setdiff (1:length(res_c1),good_idx);
%! assert (cell2mat({res.c1}.')(bad_idx,:), res_c1(bad_idx,:),-3e-3);

%% Test input validation
%% Promote warnings to error to not execute program
%!error <greater> warning("error", "Octave:tisean"); c1 ([1 2 3], 'mindim', 3, 'maxdim', 2);

