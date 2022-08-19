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
## @deftypefn{Function File} {output =} spikeauto (@var{X}, @var{bin}, @var{bintot})
## @deftypefnx{Function File} {output =} spikeauto (@dots{}, '@var{inter}')
##
## Computes the binned autocorrelation function of a series of event times.
##
## The data is assumed to represent a sum of delta functions centered at the
## times given. The autocorrelation function is then a double sum of delta
## functions which must be binned to be representable. Therfore, you have to
## choose the duration of a single bin (with argument @var{bin}) and the maximum
## time lag (argument @var{bintot}) considered.
##
## @strong{Inputs}
##
## @table @var
## @item S
## This function always assumes that each time series is along the longer 
## dimension of matrix @var{S}. It also assumes that every dimension 
## (counting along the shorter dimension) of @var{S} is considered a 
## component of the time series.
## @item bin
## The duration of a single bin.
## @item bintot
## The maximum lag considered.
## @end table
##
## @strong{Switch}
##
## @table @var
## @item inter
## Treat the input as inter-event intervals instead of the time at which the event
## occured. 
## @end table
##
## @strong{Output}
##
## The output is alligned with the input. If the input was a column vector the
## output will consist of two columns, the first holds information about which
## bin did the autocorellation fit into, and the second the number of
## autocorellations that fit into that bin.
##
## @strong{Algorithms}
##
## The algorithms for this functions have been taken from the TISEAN package.
## @end deftypefn

## Author: Piotr Held <pjheld@gmail.com>.
## This function is based on spikeauto of TISEAN 3.0.1 
## https://github.com/heggus/Tisean"

function output = spikeauto (X, bin, totbin, varargin)

  # Initial input validation
  if (nargin < 3 || nargin > 4)
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

  inter = false;

  if (nargin == 4)
    if (strcmpi (varargin{1}, "inter"))
      inter = true;
    else
      error ('Octave:invalid-input-arg', "additional parameter is not 'inter'");
    endif
  endif

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

  # Number of bins
  nbin = floor (totbin / bin) + 1;

  # The oct file is used for optimization (using a for loop in Octave is about 100
  # times slower and not using the for loop uses a lot of memory,
  # e.g. when lenght (X) == 2000 it uses 500 MB).
  ihist = __spikeauto__ (X, bin, nbin);

  idx = (1:nbin).';
  idx = (idx - 0.5) .* bin;

  output = [idx, ihist];

  if (trnspsd)
    output = output.';
  endif

endfunction

%% Test against TISEAN output
%!test
%! spikeauto_res = [0.25 403965;0.75 376230;1.25 331311;1.75 274509;2.25 209767;2.75 153597;3.25 104075;3.75 65683;4.25 39030;4.75 21812;5.25 10745;5.75 5090;6.25 2064;6.75 792;7.25 245;7.75 70;8.25 14;8.75 1;9.25 0;9.75 0;10.25 0];
%! rand ("seed", 1);
%! x = zeros (2000,1);
%! for i = 2:2000
%!   x(i) = 0.7*x(i-1) +  (-6 + sum (rand ([size(1), 12]), 3));
%! endfor
%! res = spikeauto (x, 0.5, 10);
%! assert (res, spikeauto_res, 1);

%% Testing input validation
%!error <Invalid call> spikeauto (1)
%!error <2 differing elements> spikeauto (ones (10,1), 1,3);
%!error <vector> spikeauto ([(1:10);(1:10)],1,2);
