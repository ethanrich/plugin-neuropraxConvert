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
## @deftypefn{Function File} {[@var{values}, @var{pars}] =} d2 (@var{S})
## @deftypefnx{Function File} {[@var{values}, @var{pars}] =} d2 (@var{S}, @var{paramName}, @var{paramValue}, @dots{})
##
## This program estimates the correlation sum, the correlation dimension and
## the correlation entropy of a given, possibly multivariate, data set. It uses
## the box assisted search algorithm and is quite fast as long as one is not
## interested in large length scales. All length scales are computed
## simultaneously and the current center and epsilon are written every 2 min
## (real time, not cpu time) or every set number of center value increases.
## It is possible to set a maximum number of pairs. If this number is
## reached for a given length scale, the length scale will no longer be treated
## for the rest of the estimate.
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
## @item t
## Theiler window [default = 0].
## @item rlow
## Minimum length scale [default = 1e-3].
## @item rhigh
## Maximum length scale [default = 1].
## @item eps_no
## Number of length scale values [default = 100].
## @item n
## Maximum number of pairs to be used (value 0 means all possible pairs)
## [default = 1000].
## @item p
## This parameter determines after how many iterations (center points)
## should the program pause and write out how many center points have been
## treated so far and the current epsilon. If @var{plot_corr} or
## @var{plot_slopes} or @var{plot_entrop} is set then during the pause a plot
## of the current state of @var{c2}, @var{d2} or @var{h2} (respectively)
## is produced. Regardless of the value of this parameter the program will
## pause every two minutes [default = only pause every 2 minutes].
## @end table
##
## @strong{Switches}
##
## @table @var
## @item normalized
## When this switch is set the program uses data normalized to [0,1] for all
## components.
## @item plot_corr
## If this switch is set then whenever the execution is paused (the frequency
## can be set with parameter @var{p}) the most recent correlation sums are
## plotted. The color used for them is blue.
## @item plot_slopes
## Same as @var{plot_corr} except the plotted values are the local slopes.
## They are plotted in red.
## @item plot_entrop
## Same as @var{plot_corr} except the correlation entropies are plotted.
## They are plotted in green.
## @end table
##
## @strong{Output}
##
## @table @var
## @item values
## This is a struct array that contains the following fields:
## @itemize @bullet
## @item
## dim - the dimension of the data
## @item
## c2 - the first column is the epsilon and the second the correlation sums for
## a particular embedding dimension
## @item
## d2 - the first column is the epsilon and the second the local slopes of
## the logarithm of the corrlation sum
## @item
## h2 - the first column is the epsilon and the second the correlation
## entropies
## @end itemize
## @item pars
## This is a struct. It contains the following fields:
## @itemize @bullet
## @item
## treated - the number of center points treated
## @item
## eps - the maximum epsilon used
## @end itemize
## @end table
##
## @seealso{demo d2, av_d2, c2t, c2g}
##
## @strong{Algorithms}
##
## The algorithms for this functions have been taken from the TISEAN package.
## @end deftypefn

## Author: Piotr Held <pjheld@gmail.com>.
## This function is based on d2 of TISEAN 3.0.1 
## https://github.com/heggus/Tisean"

function [values, pars] = d2 (S, varargin)

  if (nargin < 1 || nargout > 2)
    print_usage;
  endif

  if ((ismatrix (S) == false) || (isreal(S) == false) || ...
       (isreal(S) == false))
    error ('Octave:invalid-input-arg', "S must be a realmatrix");
  endif

  # Default values
  embed          = 10;
  delay          = 1;
  mindist        = 0;
  epsmin         = 1e-3;
  epsmax         = 1.0;
  howoften       = 100;
  maxfound       = 1000;
  iterator_pause = length (S);

  #### Parse the input
  p = inputParser ();
  p.FunctionName = "d2";

  isPositiveIntScalar    = @(x) isreal(x) && isscalar (x) && ...
                             (x > 0) && (x-round(x) == 0);
  isNonNegativeIntScalar = @(x) isPositiveIntScalar (x) || (x == 0);
  isPositiveScalar       = @(x) isreal(x) && isscalar (x) && (x > 0);

  p.addParamValue ("m", embed, isPositiveIntScalar);
  p.addParamValue ("d", delay, isPositiveIntScalar);
  p.addParamValue ("t", mindist, isNonNegativeIntScalar);
  p.addParamValue ("rlow", epsmin, isPositiveScalar);
  p.addParamValue ("rhigh", epsmax, isPositiveScalar);
  p.addParamValue ("eps_no", howoften, isPositiveIntScalar);
  p.addParamValue ("n", maxfound, isNonNegativeIntScalar);
  p.addParamValue ("p", iterator_pause, isPositiveIntScalar);
  p.addSwitch ("normalized");
  p.addSwitch ("plot_corr");
  p.addSwitch ("plot_slopes");
  p.addSwitch ("plot_entrop");

  p.parse (varargin{:});

  # Assign inputs
  embed          = p.Results.m;
  delay          = p.Results.d;
  mindist        = p.Results.t;
  epsmin         = p.Results.rlow;
  eps_min_set    = !ismember ("rlow", p.UsingDefaults);
  epsmax         = p.Results.rhigh;
  eps_max_set    = !ismember ("rhigh", p.UsingDefaults);
  howoften       = p.Results.eps_no;
  maxfound       = p.Results.n;
  rescale_set    = p.Results.normalized;
  iterator_pause = p.Results.p;
  plot_corr      = p.Results.plot_corr;
  plot_slopes    = p.Results.plot_slopes;
  plot_entrop    = p.Results.plot_entrop;

  # Input validation
  # Check if the delay and embedding dimensions are too large
  if ((length (S)-(embed-1)*delay) <= 0)
    error ("Octave:invalid-input-arg","Embedding dimension and delay are too \
large, the delay vector would be longer than the whole series.");
  endif

  # Check if rlow is smaller than rhigh
  if (epsmin >= epsmax)
    warning ("Octave:tisean", "'rlow' is greater or equal to 'rhigh'");
  endif

  # Correct S to always have more rows than columns
  trnspsd = false;
  if (rows (S) < columns (S))
    S = S.';
    trnspsd = true;
  endif

  [values, vars] = __d2__ (S, embed, delay, mindist, epsmin, eps_min_set,
                           epsmax, eps_max_set, howoften, maxfound,
                           rescale_set,iterator_pause);

  # Pause calculations and if flags are set, plot current state of the output.
  calc_paused = false;
  while (isfield (vars, "counter") ...
         && vars.counter < (length (S) - (embed-1)*delay))

    calc_paused   = true;

    printf ("\n");
    treated = vars.treated
    epsilon = vars.eps
    fflush (stdout);

    figure_no = 1;
    if (plot_corr)
      h             = figure (figure_no);
      figure_no    += 1;
      do_plot_corr  = @(x) loglog (x{1}(:,1),x{1}(:,2),'b');
      clf (h)
      hold on
      arrayfun (do_plot_corr, {values.c2});
      hold off
      xlabel ("Epsilon")
      ylabel ("Correlation sums")
      drawnow ()
    endif
    if (plot_slopes)
      h             = figure (figure_no);
      figure_no    += 1;
      do_plot_slope = @(x) semilogx (x{1}(:,1),x{1}(:,2),'r');
      clf (h)
      hold on
      arrayfun (do_plot_slope, {values.d2});
      hold off
      xlabel ("Epsilon")
      ylabel ("Local slopes")
      drawnow ()
    endif
    if (plot_entrop)
      h               =figure (figure_no);
      figure_no      += 1;
      do_plot_entrop  = @(x) semilogx (x{1}(:,1),x{1}(:,2),'g');
      clf (h)
      hold on
      arrayfun (do_plot_entrop, {values.h2});
      hold off
      xlabel ("Epsilon")
      ylabel ("Correlation entropies");
      drawnow ()
    endif

    # Continue on with computation
    [values, vars] = __d2__ (S, embed, delay, mindist, vars.EPSMIN,
                             eps_min_set, vars.EPSMAX, eps_max_set, howoften,
                             maxfound, rescale_set, iterator_pause,
                             vars.counter, vars.found, vars.norm, vars.boxc1,
                             vars.box, vars.list, vars.listc1, vars.imin,
                             vars.EPSMAX1);
  endwhile

  if (calc_paused)
    printf ("\n");
    fflush (stdout);
  endif

  pars = vars;

endfunction

%!demo
%! vals = d2 (henon (1000), 'd', 1, 'm', 5, 't',50);
%! 
%! subplot (2,3,1)
%! do_plot_corr  = @(x) loglog (x{1}(:,1),x{1}(:,2),'b');
%! hold on
%! arrayfun (do_plot_corr, {vals.c2});
%! hold off
%! axis tight
%! xlabel ("Epsilon")
%! ylabel ("Correlation sums")
%! title ("c2");
%!
%! subplot (2,3,4)
%! do_plot_entrop  = @(x) semilogx (x{1}(:,1),x{1}(:,2),'g');
%! hold on
%! arrayfun (do_plot_entrop, {vals.h2});
%! hold off
%! axis tight
%! xlabel ("Epsilon")
%! ylabel ("Correlation entropies");
%! title ("h2")
%!
%! subplot (2,3,[2 3 5 6])
%! do_plot_slope = @(x) semilogx (x{1}(:,1),x{1}(:,2),'r');
%! hold on
%! arrayfun (do_plot_slope, {vals.d2});
%! hold off
%! axis tight
%! xlabel ("Epsilon")
%! ylabel ("Local slopes")
%! title ("d2");
%!###############################################################

%!shared res, pars
%! [res, pars] = d2 (henon (100)(:,1),'m',2,'eps_no',20,'t',50);

%!test
%! res_d2_stat = [98 1.777433e+00];
%! assert ([pars.treated pars.eps], res_d2_stat, -1e-6);

%% test d2 field of output
%!test
%! res_d2_d2 = [1.777433 0.30648;1.235659 0.5606802;0.859021 0.7008824;0.5971852 0.8064865;0.4151589 0.9044852;0.2886154 0.9689651;0.2006434 0.8540874;0.1394858 0.8112826;0.09696954 0.8935407;0.06741253 0.9143867;0.0468647 0.856615;0.03258 0.8627251;0.02264938 1.503286;0.01574569 1.447036;0.01094629 0.7216412;0.007609782 0.6137634;0.005290265 1.29276;0.003677754 1.405042;1.777433 0.645521;1.235659 1.002253;0.859021 1.056272;0.5971852 1.026064;0.4151589 1.402018;0.2886154 1.565816;0.2006434 0.6950658;0.1394858 1.238292;0.09696954 0.9580286;0.06741253 1.75781;0.0468647 1.043798;0.03258 2.628165;0.02264938 1.405042;0.01574569 1.115245];
%! assert (cell2mat({res.d2}.'), res_d2_d2, -1e-6);

%% test h2 field of output
%!test
%! res_d2_h2 = [2.556748 -0;1.777433 0.1114257;1.235659 0.31527;0.859021 0.5700871;0.5971852 0.8632982;0.4151589 1.192138;0.2886154 1.544421;0.2006434 1.854938;0.1394858 2.149893;0.09696954 2.474754;0.06741253 2.807194;0.0468647 3.11863;0.03258 3.432288;0.02264938 3.978832;0.01574569 4.504925;0.01094629 4.767289;0.007609782 4.990433;0.005290265 5.460436;0.003677754 5.971262;2.556748 0;1.777433 0.1232638;1.235659 0.2838046;0.859021 0.4130123;0.5971852 0.4928431;0.4151589 0.6737291;0.2886154 0.890724;0.2006434 0.8329091;0.1394858 0.9881553;0.09696954 1.011601;0.06741253 1.318241;0.0468647 1.386294;0.03258 2.028148;0.02264938 1.99243;0.01574569 1.871802];
%! assert (cell2mat({res.h2}.'), res_d2_h2, -1e-6);

%% test c2 field of output
%!test
%! res_d2_c2 =  [2.556748 1;1.777433 0.8945578;1.235659 0.7295918;0.859021 0.5654762;0.5971852 0.4217687;0.4151589 0.3035714;0.2886154 0.2134354;0.2006434 0.1564626;0.1394858 0.1164966;0.09696954 0.08418367;0.06741253 0.06037415;0.0468647 0.04421769;0.03258 0.03231293;0.02264938 0.01870748;0.01574569 0.01105442;0.01094629 0.008503401;0.007609782 0.006802721;0.005290265 0.004251701;0.003677754 0.00255102;0.002556748 0;2.556748 1;1.777433 0.7908163;1.235659 0.5493197;0.859021 0.3741497;0.5971852 0.2576531;0.4151589 0.1547619;0.2886154 0.08758503;0.2006434 0.06802721;0.1394858 0.04336735;0.09696954 0.03061224;0.06741253 0.01615646;0.0468647 0.01105442;0.03258 0.004251701;0.02264938 0.00255102;0.01574569 0.00170068;0.01094629 0;0.007609782 0;0.005290265 0;0.003677754 0;0.002556748 0];
%! assert (cell2mat({res.c2}.'), res_d2_c2, -1e-6);

%% Test input validation
%!error <too large> d2 (1:5);
%% Promote warnings to error to not execute program
%!error <greater> warning("error", "Octave:tisean"); ...
%!                d2 (henon (1000), 'rlow', 4, 'rhigh', 1);
