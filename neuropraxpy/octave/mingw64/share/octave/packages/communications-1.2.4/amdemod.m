## Copyright (C) 2021 The Octave Project Developers
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
## @deftypefn {Function File} {@var{m} =} amdemod (@var{s}, @var{fc}, @var{fs})
## Creates the AM demodulation of the signal @var{s} 
## sampled at frequency @var{fs} with carrier frequency @var{fc}.
##
## Inputs:
## @itemize
## @item
## @var{s}: AM modulated signal
## 
## @item
## @var{fc}: carrier frequency
##
## @item
## @var{fs}: sampling frequency
## @end itemize
## 
## Output:
## @itemize
## @item
## @var{m}: AM demodulation of the signal
## @end itemize
##
## Demo
## @example
## demo amdemod
## @end example
## @seealso{ammod, fmmod, fmdemod}
## @end deftypefn

function m = amdemod (s, fc, fs)

  if (nargin != 3)
    print_usage ();
  endif

  if (fs < 2 .* fc)
    error ("amdemod: fs is too small must be at least 2 * fc")
  endif

  l = length (s);
  t = 0: 1 ./ fs: (l .- 1) ./ fs;
  
  e = s .* cos (2 .* pi .* fc .* t);
  [b a] = butter (5, fc .* 2 ./ fs);
  m = filtfilt (b, a, e) .* 2;

endfunction

## Test input validation
%!error amdemod ()
%!error amdemod (1)
%!error amdemod (1, 2)
%!error amdemod (1, 2, 3, 4)

%!error <fs is too> amdemod (pi/2, 100, 10)

## https://stackoverflow.com/questions/21902462/amplitude-modulation-using-builtin-octave-functions
%!demo
%! #Parameters
%! Fs = 44100;
%! T  = 1;
%! Fc = 15000;
%! Fm = 10;

%! #Low-pass filter design
%! [num,den] = butter(10,1.2*Fc/Fs); 

%! #Signals
%! t = 0:1/Fs:T;
%! x = cos(2*pi*Fm*t);
%! y = ammod(x,Fc,Fs);
%! z = amdemod(y,Fc,Fs);

%! #Plot
%! figure('Name','AM Modulation');
%! subplot(3,1,1); plot(t,x); title('Modulating signal');
%! subplot(3,1,2); plot(t,y); title('Modulated signal');
%! subplot(3,1,3); plot(t,z); title('Demodulated signal');