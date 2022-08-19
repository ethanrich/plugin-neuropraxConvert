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
## @deftypefn{Function File} {[@var{olens}, @var{orbit_data}, @var{acc}, @var{stab}] =} upo (@var{X}, @var{m})
## @deftypefnx{Function File} {@dots{} =} upo (@var{X}, @var{m}, @var{paramName}, @var{paramValue}, @dots{})
##
## Locates unstable periodic points.
##
## Note: This function provides a wrapper for the original upo from TISEAN. The 
## documentation to TISEAN states that upo has not been tested thoroughly
## and therefore might contain errors. Since this function only provides
## a wrapper for the TISEAN upo any such errors will be inherited. For
## more information consult the TISEAN documentation:
## http://www.mpipks-dresden.mpg.de/~tisean/Tisean_3.0.1/docs/docs_f/upo.html
##
## @strong{Inputs}
##
## @table @var
## @item X
## Must be realvector. If it is a row vector then the output will 
## be row vectors as well. Maximum length is 1e6. This constraint existed in
## the TISEAN program and therefore it is inherited. This should not 
## be a problem as this program takes 9 seconds for a 10000 element long
## noisy henon series. 
## @item m
## Embedding dimension. Must be scalar positive integer.
## @end table
## 
## @strong{Parameters}
##
## Either @var{r} or @var{v} must be set and at least one must be
## different from zero.
## @table @var
## @item r
## Absolute kernel bandwidth. Must be a scalar.
## @item v
## Same as fraction of standard deviation.
## @item mtp
## Minimum separation of trial points 
## [default = value of 'r' OR std(data) * value of 'v'].
## @item mdo
## Minimum separation of distinct orbits 
## [default = value of 'r' OR std(data) * value of 'v'].
## @item s
## Initial separation for stability
## [default = value of 'r' OR std(data) * value of 'v'].
## @item a
## Maximum error of orbit to be plotted [default = all plotted].
## @item p
## Period of orbit [default = 1].
## @item n
## Number of trials [default = numel (@var{X})].
## @end table
##
## @strong{Outputs}
##
## @table @var
## @item olens
## A vector that contains the period lengths (sizes) for each orbit.
## @item orbit_data
## A vector that contains all of the orbit data. To find data for the 
## n-the orbit you need to:
## @example
##
## nth_orbit_data = orbit_data(sum(olens(1:n-1)).+(1:olens(n)));
##
## @end example
## @item acc
## A vector that contains the accuracy of each orbit.
## @item stab
## A vector that contains the stability of each orbit.
## @end table
## Note that 
##
## @code{length (olens) == length (acc) == length (stab) #== number of orbits}.
##
## @seealso{demo upo, upoembed}
##
## @strong{Algorithms}
##
## The algorithms for this functions have been taken from the TISEAN package.
## @end deftypefn

## Author: Piotr Held <pjheld@gmail.com>.
## This function is based on upo of TISEAN 3.0.1
## https://github.com/heggus/Tisean"

function [olens, orbit_data, acc, stab] = upo (X,m,varargin)

  # Initial input validation
  if (nargin < 2)
    print_usage;
  endif

  if ((isvector (X) == false) || (isreal(X) == false))
    error ('Octave:invalid-input-arg', "X must be a realvector");
  endif

  # Checking if the input is too long for
  # the underlying fortran program
  if (length (X) > 1e6)
    error ('Octave:invalid-input-arg', ...
           "X cannot contain more than 1e6 elements");
  endif

  isPositiveIntScalar = @(x) isreal(x) && isscalar (x) && ...
                             (x > 0) && (x-round(x) == 0);
  if (isPositiveIntScalar(m) == false)
    error ('Octave:invalid-input-arg', ["m must be a scalar positive ",...
                                        "integer value"]);
  endif

  # Load defaults
  eps  = 0;
  frac = 0;
  teq  = -1;
  tdis = -1;
  h    = -1;
  tacc = -1;
  iper = 1;
  icen = length (X);

  #### Parse the input
  p = inputParser ();
  p.FunctionName = "upo";

  isNumericScalar = @(x) isreal(x) && isscalar (x);

  p.addParamValue ("r", eps, isNumericScalar);
  p.addParamValue ("v", frac, isNumericScalar);
  p.addParamValue ("mtp", teq, isNumericScalar);
  p.addParamValue ("mdo", tdis, isNumericScalar);
  p.addParamValue ("s", h, isNumericScalar);
  p.addParamValue ("a", tacc, isNumericScalar);
  p.addParamValue ("p", iper, isPositiveIntScalar);
  p.addParamValue ("n", icen, isPositiveIntScalar);

  p.parse (varargin{:});

  # Assign inputs
  eps  = p.Results.r;
  frac = p.Results.v;
  teq  = p.Results.mtp;
  tdis = p.Results.mdo;
  h    = p.Results.s;
  tacc = p.Results.a;
  iper = p.Results.p;
  icen = p.Results.n;

  # Input validation
  if (ismember ('r',p.UsingDefaults) && ismember ('v', p.UsingDefaults))
    error ('Octave:invalid-input-arg', "Either parameter 'r' or 'v' \
must be set");
  endif

  if ((eps == 0) && (frac == 0))
    error ('Octave:invalid-input-arg', "Either parameter 'r' or 'v' \
must be different from zero");
  endif

  # Correct X to always have more rows than columns
  trnspsd = false;
  if (rows (X) < columns (X))
    X = X.';
    trnspsd = true;
  endif

  [olens, orbit_data, acc, stab] = ...
    __upo__ (X, m, eps, frac, teq, tdis, h, tacc, iper, icen);

  orbit_no      = olens(1);
  data_no       = orbit_data(1);

  olens(1)      = [];
  orbit_data(1) = [];
  acc(1)        = [];
  stab(1)       = [];

  olens         = resize (olens,[orbit_no,1]);
  orbit_data    = resize (orbit_data,[data_no,1]);
  acc           = resize (acc,[orbit_no,1]);
  stab          = resize (stab,[orbit_no,1]);

  if (trnspsd)
    olens      = olens.';
    orbit_data = orbit_data.';
    acc        = acc.';
    stab       = stab.';
  endif

endfunction


%!demo
%! hen    = henon (1000);
%! # The following line is equvalent to 'addnoise -v0.1 hen' from TISEAN
%! hen    = hen + std (hen) * 0.1 .* (-6 + sum (rand ([size(hen), 12]), 3));
%! hendel = delay (hen(:,1));
%! [olens, odata] = upo(hen(:,1), 2, 'p',6,'v',0.1, 'n', 100);
%! up    = upoembed (olens, odata, 1);
%! plot (hendel(:,1), hendel(:,2), 'r.', 'markersize',2, ...
%!       up{4}(:,1), up{4}(:,2),'gx','markersize',20,'linewidth',1, ...
%!       up{3}(:,1), up{3}(:,2),'b+','markersize',20,'linewidth',1, ...
%!       up{2}(:,1), up{2}(:,2),'ms','markersize',20,'linewidth',1, ...
%!       up{1}(:,1), up{1}(:,2),'ws','markerfacecolor', 'c', 'markersize',20);
%! legend ('Noisy Henon', 'Fixed Point','Period 2', 'Period 6', 'Period 6');
%! axis tight
%!###############################################################

%!fail("upo((1:10),2,'r',0,'v',0)");
%!fail("upo((1:10),2)");
%!fail("upo(1:10)");
%!fail("upo(zeros(1e6+1,1),2)");

%!test
%! hen       = henon (1000);
%! res_lens  = [6;6;2;1];
%! res_odata = [0.476636350; 0.790967643; 0.223789170; 1.14927197; -0.771639466; 0.450597405; 0.310742706; 1.01709056; -0.403215200; 1.06800783; -0.734883010; 0.569545567; 0.975725055; -0.495307118; 0.640587449];
%! res_acc   = [5.09480287E-07 ; 7.82842960E-07; 5.84763768E-07; 5.19621267E-07];
%! res_stab  = [12.6414680; 10.4631128; 2.43191552; 1.63386893];
%! [l,d,a,s] = upo(hen(:,1),2,'p',6,'v',0.1,'n',100); 
%! assert ({l,d},{res_lens,res_odata},-1e-5);


