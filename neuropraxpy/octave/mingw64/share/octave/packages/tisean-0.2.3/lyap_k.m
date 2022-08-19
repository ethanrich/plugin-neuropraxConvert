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
## @deftypefn{Function File} {@var{output} =} lyap_k (@var{X})
## @deftypefnx{Function File} {@var{output} =} lyap_k (@var{X}, @var{paramName}, @var{paramValue}, @dots{})
##
## Estimates the maximum Lyapunov exponent using the algorithm described by 
## Kantz on the TISEAN reference page:
##
## http://www.mpipks-dresden.mpg.de/~tisean/Tisean_3.0.1/docs/chaospaper/citation.html
##
## @strong{Input}
##
## @table @var
## @item X
## Must be realvector.
## @end table
##
## @strong{Parameters}
##
## @table @var
## @item mmax
## Maximum embedding dimension to use [default = 2].
## @item mmin
## Minimum embedding dimension to use [default = 2].
## @item d
## Delay used [default = 1].
## @item rlow
## Minimum length scale to search neighbors [default = 1e-3].
## @item rhigh
## Maximum length scale to search neighbors [default = 1e-2].
## @item ecount
## Number of length scales to use [default = 5].
## @item n
## Reference points to use [all].
## @item s
## Number of iterations in time [default = 50].
## @item t
## 'theiler window' [default = 0].
## @end table
##
## @strong{Switch}
##
## @table @var
## @item verbose
## Prints information about the current length scale at runtime.
## @end table
##
## @strong{Output}
##
## The output is a struct array of size:
##
## @code{'ecount' x ('mmax' - 'mmin' + 1)}
##
## It has the following fields:
## @itemize @bullet
## @item
## @code{eps} - holds the epsilon for the exponent
## @item
## @code{dim} - holds the embedding dimension used in exponent
## @item
## @code{exp} - contains the exponent data. It consists of 3 columns:
## @enumerate
## @item
## The number of the iteration
## @item
## The logarithm of the stretching factor (the slope is the Laypunov exponent
## if it is a straight line)
## @item
## The number of points for which a neighborhood with enough points was found
## @end enumerate
## @end itemize
##
## @seealso{demo lyap_k, lyap_r, lyap_spec}
##
## @strong{Algorithms}
##
## The algorithms for this functions have been taken from the TISEAN package.
## @end deftypefn

## Author: Piotr Held <pjheld@gmail.com>.
## This function is based on lyap_k of TISEAN 3.0.1 
## https://github.com/heggus/Tisean"

function output = lyap_k (X, varargin)

  # Initial input validation
  if (nargin < 1)
    print_usage;
  endif

  if ((isvector (X) == false) || (isreal(X) == false))
    error ('Octave:invalid-input-arg', "X must be a realvector");
  endif

  # Default parameters
  maxdim    = 2;
  mindim    = 2;
  delay     = 1;
  epsmin    = 1e-3;
  epsmax    = 1e-2;
  epscount  = 5;
  reference = length (X);
  maxiter   = 50;
  window    = 0;

  #### Parse the input
  p = inputParser ();
  p.FunctionName = "lyap_k";

  isPositiveIntScalar    = @(x) isreal(x) && isscalar (x) && ...
                             (x > 0) && (x-round(x) == 0);
  isNonNegativeIntScalar = @(x) isPositiveIntScalar (x) || (length (x) == 1 ...
                                                            &&(x == 0));
  isPositiveScalar       = @(x) isreal(x) && isscalar (x) && (x > 0);

  p.addParamValue ("mmax", maxdim, isPositiveIntScalar);
  p.addParamValue ("mmin", mindim, isPositiveIntScalar);
  p.addParamValue ("d", delay, isPositiveIntScalar);
  p.addParamValue ("rlow", epsmin, isPositiveScalar);
  p.addParamValue ("rhigh", epsmax, isPositiveScalar);
  p.addParamValue ("ecount", epscount, isPositiveIntScalar);
  p.addParamValue ("n", reference, isPositiveIntScalar);
  p.addParamValue ("s", maxiter, isPositiveIntScalar);
  p.addParamValue ("t", window, isNonNegativeIntScalar);
  p.addSwitch ("verbose");

  p.parse (varargin{:});

  # Assign inputs
  maxdim    = p.Results.mmax;
  mindim    = p.Results.mmin;
  delay     = p.Results.d;
  epsmin    = p.Results.rlow;
  eps0set   = !ismember ('rlow', p.UsingDefaults);
  epsmax    = p.Results.rhigh;
  eps1set   = !ismember ('rhigh', p.UsingDefaults);
  epscount  = p.Results.ecount;
  reference = p.Results.n;
  maxiter   = p.Results.s;
  window    = p.Results.t;
  verbose   = p.Results.verbose;

  # Input validation

  # Check if rlow isn't bigger than rhigh
  if (epsmin >= epsmax)
    warning ('Octave:tisean', "Parameter 'rlow' is greater than 'rhigh', \
setting 'rlow = rhigh'");
    epsmax=epsmin;
    epscount=1;
  endif

  # Check if 'n' isn't too large
  if (reference > (length (X)-maxiter-(maxdim-1)*delay))

    # If it was set too large display warning
    if (!ismember ('n', p.UsingDefaults))
      warning ('Octave:tisean', "Parameter 'n' was too large, setting to \
maximum possible value");
    endif

    reference=length (X)-maxiter-(maxdim-1)*delay;
  endif

  # Check if there are enough points for these parameters
  if ((maxiter+(maxdim-1)*delay) >= length(X))
    error ('Octave:invalid-input-arg',"Too few points to handle these \
parameters");
  endif

  # Ensure maxdim and mindim are correct
  if (maxdim < 2)
    warning ('Octave:tisean', "Parameter 'mmax' was too small, setting \
'mmax' = 2");
    maxdim=2;
  endif
  if (mindim < 2)
    warning ('Octave:tisean', "Parameter 'mmin' was too small, setting \
'mmin' = 2");
    mindim=2;
  endif
  if (mindim > maxdim)
    warning ('Octave:tisean', "Parameter 'mmin' was larger than 'mmax', \
setting 'mmin' = 'mmax'");
    maxdim=mindim;
  endif

  # Correct X to always have more rows than columns
  trnspsd = false;
  if (rows (X) < columns (X))
    X = X.';
    trnspsd = true;
  endif

  output = __lyap_k__ (X, maxdim, mindim, delay, epsmin, eps0set,...
                       epsmax, eps1set, epscount, reference, maxiter, ...
                       window, verbose);

endfunction
%!demo
%! idx    = (1:2500).';
%! in     = sin (idx./360) + cos (idx ./ 180);
%! mmax   = 20;
%! res    = lyap_k (in, 'mmin',2,'mmax',mmax,'d',6,'s',400,'t',500);
%!
%! cla reset
%! hold on
%! for j=2:mmax
%!   plot (res(1,j-1).exp(:,1),res(1,j-1).exp(:,2),'r');
%! endfor
%! axis tight
%! xlabel ("t [flow samples]");
%! ylabel ("S(eps, embed, t)");
%! hold off
%!###############################################################


%!test
%! ts_res1 = [0 -5.548344 2;1 -4.643023 2;2 -4.5687 2;3 -3.663079 2;4 -3.285737 2;5 -2.364073 2;6 -2.347838 2;7 -1.435444 2;8 -1.174444 2;9 -0.4689464 2;10 -0.9246688 2];
%! ts_res2 = [0 -4.973845 9;1 -4.375238 9;2 -3.783095 9;3 -3.068363 9;4 -2.88801 9;5 -2.361605 9;6 -2.047413 9;7 -1.579871 9;8 -0.9320268 9;9 -0.8645631 9;10 -1.412792 9];
%! hen = henon (1000)(:,1);
%! res = lyap_k (hen, 'mmin',4,'mmax',4,'d',6,'s',10,'t',100);
%! assert({res(4).exp, res(5).exp}, {ts_res1, ts_res2},-1e-6);

%% Check input validation
%% Warnings are promoted to errors to prevent program execution
%!error <greater> warning("error", "Octave:tisean"); lyap_k (1:100,'rlow',2);
%!error <too large> warning("error", "Octave:tisean"); lyap_k (1:100,'n',100);
%!error <few points> lyap_k (1:100,'s',100);
%!error <too small> warning("error", "Octave:tisean"); lyap_k (1:100,'mmin',1);
%!error <larger> warning("error", "Octave:tisean"); lyap_k (1:100,'mmin',3);
%!error <too small> warning("error", "Octave:tisean"); lyap_k (1:100,'mmax',1);
