## Copyright (C) 2021 The Octave Project Developers
## Copyright (C) 2015 Francisco Albani
## Copyright (C) 2007 Sylvain Pelissier <sylvain.pelissier@gmail.com>
##
## This program is free software; you can redistribute it and/or modify it under
## the terms of the GNU General Public License as published by the Free Software
## Foundation; either version 3 of the License, or (at your option) any later
## version.
##
## This program is distributed in the hope that it will be useful, but WITHOUT
## ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
## FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
## details.
##
## You should have received a copy of the GNU General Public License along with
## this program; if not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} {@var{s} =} fmmod (@var{m}, @var{fc}, @var{fs}, @var{freqdev})
## Creates the FM modulation @var{s} of the message signal @var{m} with carrier frequency @var{fc}.
## 
## Inputs:
## @itemize
## @item 
## @var{m}: sinusoidal message signal
##
## @item
## @var{fc}: carrier frequency
##
## @item
## @var{fs}: sampling frequency
##
## @item
## @var{freqdev}: maximum absolute frequency deviation, assuming @var{m} is in [-1:1].
## @end itemize
##
## Output:
## @itemize
## @var{s}: The FM modulation of @var{m}
## @end itemize
##
## Demo
## @example
## demo fmmod
## @end example
## @seealso{ammod, fmdemod, amdemod}
## @end deftypefn

function s = fmmod (m, fc, fs, freqdev)

  if (nargin < 4)
    print_usage ();
  endif

  l = length (m);
  t = 0: 1 ./ fs: (l .- 1) ./ fs;
  int_m = cumsum (m) ./ fs;

  s = cos (2 .* pi .* fc .* t .+ 2 .* pi .* freqdev .* int_m);

endfunction

## Test input validation
%!error fmmod ()
%!error fmmod (1)
%!error fmmod (1, 2)

## From https://www.geeksforgeeks.org/frequency-modulation-fm-using-matlab/
%!demo
%! ## Sampling Frequency
%! fs = 400;
%!
%! ## Carrier Frequency
%! fc = 200;
%!
%! ## Time Duration
%! time = (0: 1 ./ fs:0.2)';
%!
%! ## Create two sinusoidal signals with frequencies 30 Hz and 60 Hz
%! x = sin (2 .* pi .* 30 .* time) .+ 2 .* sin (2 .* pi .* 60 .* time);  
%!
%! ## Frequency Deviation
%! fDev = 50;
%!
%! ## Frequency modulate x
%! y = fmmod (x, fc, fs, fDev);
%!
%! ## plotting
%! plot (time, x, 'r', time, y, 'b--')
%! xlabel ('Time (s)')
%! ylabel ('Amplitude')
%! legend ('Original Signal','Modulated Signal')