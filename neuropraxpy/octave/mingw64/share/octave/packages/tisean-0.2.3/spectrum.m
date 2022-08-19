## Copyright (C) 2015 Piotr Held
## Copyright (C) 2015 Juan Pablo Carbajal
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
## @deftypefn{Function File} {[@var{freqs}, @var{spec}] =} spectrum (@var{X})
## @deftypefnx{Function File} {[@var{freqs}, @var{spec}] =} spectrum (@var{X}, @var{paramName}, @var{paramValue}, @dots{})
##
## Produce delay vectors
##
## @strong{Input}
##
## @table @var
## @item X
## Must be realvector. The spectrum will be performed on it.
## @end table
##
## @strong{Parameters}
##
## @table @var
## @item f
## Frequency sampling rate in Hz [default = 1]
## @item w
## Frequency resolution in Hz [default = f / length (@var{X})]
## @end table
##
## @strong{Output}
##
## @table @var
## @item freqs
## The frequencies for the spectrum of vector @var{X}
## @item spec
## The spectrum of the input vector @var{X}
## @end table
##
## @strong{Example of Usage}
##
## @example
##
## spectrum (data_vector, 'f', 10, 'w', 0.001)
##
## @end example
##
## @strong{Algorithms}
##
## The algorithms for this functions have been taken from the TISEAN package.
## @end deftypefn

## Author: Piotr Held <pjheld@gmail.com>.
## This function is based on spectrum of TISEAN 3.0.1
## https://github.com/heggus/Tisean"

function [freqs, spec] = spectrum (X, varargin)

  if (nargin < 1)
    print_usage;
  endif

  if ((isvector (X) == false) || (isreal(X) == false))
    error ('Octave:invalid-input-arg', "X must be a realvector");
  endif

  # Load defaults
  n = length (X);
  if (isprime (n) && (n > 5))
    n      = n-1;
    X(end) = [];
    warning ("Octave:tisean",...
      "The length of 'X' was a prime number.\nUsing the next lowest: %d\n", n);
  endif

  f = 1;
  w = f / n;

  #### Parse input
  p = inputParser ();
  p.FunctionName = "spectrum";

  isPositiveRealScalar = @(x) isreal(x) && isscalar (x) && (x > 0);

  p.addParamValue ("f", f, isPositiveRealScalar);
  p.addParamValue ("w", w, isPositiveRealScalar);

  p.parse (varargin{:});

  f = p.Results.f;
  w = p.Results.w;

  # Create indexes
  half_n    = floor (n / 2) + 1;
  half_step = floor (n * w / (2 * f));
  step      = 2 * half_step + 1;
  idx       = 1:step:half_n;
  npoints   = length (idx);

  # Create the spectrum values

  spec  = abs (fft (X) / n).^2;
  id    = kron ((1:npoints-1).', ones (step,1));
  spec  = [spec(1), accumarray(id,spec(2:idx(end))).'];

  # Create the frequencies
  idx     = (2 + half_step):step:half_n;
  freqs   = [0 idx-1] / n * f;

  if (rows (X) > columns (X))
    spec  = spec.';
    freqs = freqs.';
  endif

endfunction

%!test
%! a=1:5;
%! spec = [9, 0.723606944, 0.276393265];
%! freq = [0, 0.200000003, 0.400000006];
%! [res_f, res_s] = spectrum (a);
%! assert ([res_f;res_s], [freq;spec], 1e-6)

%!test
%! a=1:5;
%! spec = [9, 0.723606944, 0.276393265];
%! freq = [0, 2.0, 4.0];
%! [res_f, res_s] = spectrum (a, 'f', 10);
%! assert ([res_f;res_s], [freq;spec], 1e-6)

%!test
%! a=[zeros(10,1); ones(10,1); zeros(10,1)];
%! spec = [0.111111119; 0.105779007; 5.33209695E-03];
%! freq = [0; 0.133333340; 0.366666675];
%! [res_f, res_s] = spectrum (a, 'w', 0.2);
%! assert ([res_f;res_s], [freq;spec], 1e-6)

%!test
%! a=[zeros(10,1); ones(10,1); zeros(10,1)];
%! spec = [0.111111119; 9.55472291E-02; 8.37056525E-03; 3.37015605E-03; 2.10963469E-03; 1.71352283E-03];
%! freq = [0; 0.666666687; 1.66666663; 2.66666675; 3.66666675; 4.66666651];
%! [res_f, res_s] = spectrum (a, 'w', 0.8, 'f', 10);
%! assert ([res_f;res_s], [freq;spec], 1e-6)

%!test
%! a=[zeros(4,1);ones(4,1);zeros(3,1)];
%! spec = [0.160000011; 9.47213769E-02; 9.99999978E-03; 5.27864136E-03; 1.00000026E-02; 0.00000000];
%! freq = [0; 0.400000006; 0.800000012; 1.20000005; 1.60000002;  2.00000000];
%! warning ("off", "Octave:tisean", "local");
%! [res_f, res_s] = spectrum (a, 'f', 4);
%! assert ([res_f,res_s], [freq,spec], 1e-6)
