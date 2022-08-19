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
## @deftypefn{Function File} {output =} spikespec (@var{X})
## @deftypefnx{Function File} {output =} spikespec (@var{X}, @var{paramName}, @var{paramValue}, @dots{})
##
## Computes a power spectrum assuming that the data are the times of singular
## events, e.g. heart beats.
##
## These events do not need to be in ascending order. Furthermore, the input can
## be treated as inter-event intervals rather than time if switch @var{inter}
## is set.
##
## If the event times are @code{t(n), n=1,...,l} the spectrum is defined by
##
## @iftex
## @tex
## S(f) = \left ( \sum_{n=1}^{l}e^{-i 2\pi f t(n)} \right )^2
## @end tex
## @end iftex
## @ifnottex
## @example
##             l                    2
##          | ---                  |
##          | \     -i 2 pi f t(n) |
##   S(f) = |  |  e                |
##          | /                    |
##          | ---                  |
##            n=1
## @end example
## @end ifnottex
##
## that is, the signal is taken to be a sum of delta functions at @code{t(n)}.
## @code{S(f)} is computed for parameter @var{f_no} frequencies between 0
## and value of parameter @var{f}. The result is binned down to a frequency
## resolution defined by parameter @var{w}.
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
## @item f
## The maximum frequency [default = 2 * length (@var{X}) / total time].
## @item f_no
## Number of frequencies [default = @var{f} * total time / 2].
## @item w
## Frequency resolution [defualt = 0 -- return all frequencies].
## @end table
##
## @strong {Switch}
##
## @table @var
## @item inter
## Treat the input as inter-event intervals instead of the time at which the event
## occured. 
## @item verbose
## Write to standard output the value of the 'total time', number of frequencies
## used, the maximum frequency and how many frequencies are binned.
## @end table
##
## @strong{Output}
##
## The output is alligned with the input. If the input was a column vector the
## output will consist of two columns, the first holds the frequencies to which
## the spectrum was binned and the second holds the calculated spectrum value.
##
## @strong{Algorithms}
##
## The algorithms for this functions have been taken from the TISEAN package.
## @end deftypefn

## Author: Piotr Held <pjheld@gmail.com>.
## This function is based on spikespec of TISEAN 3.0.1 
## https://github.com/heggus/Tisean"

function output = spikespec (X, varargin)

  # Initial input validation
  if (nargin < 1)
    print_usage;
  endif

  # Check if X is real vector
  if ((isvector (X) == false) || (isreal (X) == false))
    error ('Octave:invalid-input-arg', "X must be a real vector");
  endif

  # Check if X has at least 2 different elements
  if (min (X) == max (X))
    error ('Octave:invalid-input-arg',
           "X must contain at least 2 differing elements");
  endif


  # Default parameters
  freq_max = 0;
  nfreq    = 0;
  freq_res = 0;

  #### Parse the input
  p = inputParser ();
  p.FunctionName = "spikespec";

  isNonNegativeIntScalar = @(x) isreal (x) && isscalar (x) && ...
                             (x >= 0) && (x-round(x) == 0);
  isNonNegativeScalar    = @(x) isreal (x) && isscalar (x) && (x >= 0);

  p.addParamValue ("f", freq_max, isNonNegativeScalar);
  p.addParamValue ("f_no", nfreq, isNonNegativeIntScalar);
  p.addParamValue ("w", freq_res, isNonNegativeScalar);
  p.addSwitch ("verbose");
  p.addSwitch ("inter");

  p.parse (varargin{:});

  # Assign inputs
  freq_max = p.Results.f;
  nfreq    = p.Results.f_no;
  freq_res = p.Results.w;
  verbose  = p.Results.verbose;
  inter    = p.Results.inter;

  # Correct X to always have more rows than columns
  trnspsd = false;
  if (rows (X) < columns (X))
    X = X.';
    trnspsd = true;
  endif

  # If the input is interval change to times
  if (inter)
    X = cumsum (X);
  endif

  X = sort (X);

  if (freq_max == 0)
    freq_max = 2 * length (X) / (X(end) - X(1));
  endif
  if (nfreq == 0)
    nfreq = floor (freq_max * (X(end) - X(1)) / 2);
  endif

  if (verbose)
    printf ("spikespec: total time covered: %f\n", X(end) - X(1));
    printf ("spikespec: computing %d up to %f\n", nfreq, freq_max);
  endif

  ibin  = floor (nfreq * freq_res / 2);
  if (ibin > 0 && verbose)
    printf ("spikespec: binning %d frequencies\n", 2 * ibin + 1);
  endif

  # idx is used to avoid a for loop
  idx    = (1+ibin:2*ibin+1:nfreq-ibin).';

  # Calculating the frequencies (accounts for binning)
  freqs = (idx .* freq_max) ./ nfreq;

  # Calculate full spectrum
  omega = 2 * pi * freq_max * ((1:nfreq) / nfreq);
  spec  = sum (cos (omega .* X)).^2 + sum (sin (omega .* X)).^2;

  # Binning the spectrum to selected frequencies
  if (ibin != 0)
    spec = sum (spec(idx+(-ibin:ibin)),2);
  endif

  # If no binning occured adjust spec shape to be column vector
  if (ibin == 0)
    spec = spec.';
  endif

  output = [freqs,spec];

  if (trnspsd)
    output = output.';
  endif

endfunction

%% Test against TISEAN output with parameters
%!test
%! TISEAN_res = [0.238095239 57287.0977;0.476190478 3542.92993;0.714285731 9849.01953;0.952380955 1308.43506;1.19047618 895.900391;1.42857146 35.2915306;1.66666663 764.487854;1.90476191 393.315033;2.14285707 3824.16162;2.38095236 270.531433;2.61904764 1956.50562;2.85714293 558.371887;3.09523821 5909.93945;3.33333325 196.033508;3.57142854 969.181091;3.80952382 2341.91284;4.04761887 718.884399;4.28571415 1607.26086;4.52380943 966.218201;4.76190472 953.328613;5.00000000 833.173096];
%! rand ("seed", 1);
%! x = zeros (2000,1);
%! for i = 2:2000
%!   x(i) = 0.7*x(i-1) +  (-6 + sum (rand ([size(1), 12]), 3));
%! endfor
%! res = spikespec (x, 'w', 0.001, 'f', 5);
%! assert (res, TISEAN_res, -1e-4);

%% Test input validation
%!error <2 differing elements> spikespec (10);
%!error <failed validation> spikespec (1:10, 'w', -0.5);
%!error <failed validation> spikespec (1:10, 'w', [1,2]);
