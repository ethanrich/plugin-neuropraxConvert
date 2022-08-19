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
## @deftypefn {Function File} {@var{y} =} ammod (@var{x}, @var{fc}, @var{fs})
## Creates the AM modulation of the amplitude signal @var{x} 
## with carrier frequency @var{fc}. 
##
## Inputs:
## @itemize
## @item
## @var{x}: amplitude message signal
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
## @var{y}: The AM modulation of @var{x}
## @end itemize
## Demo
## @example
## demo ammod
## @end example
## @seealso{amdemod, fmmod, fmdemod}
## @end deftypefn

function y = ammod (x, fc, fs)

  if (nargin != 3)
    print_usage ();
  endif
  
  if (fs < 2 .* fc)
    error ("ammod: fs is too small must be at least 2 * fc")
  endif

  l = length (x);
  t = 0: 1 ./ fs: (l .- 1) ./ fs;
  y = x .* cos (2 .* pi .* fc .* t);

endfunction

## Test input validation
%!error ammod ()
%!error ammod (1)
%!error ammod (1, 2)
%!error ammod (1, 2, 3, 4)

%!error <fs is too> ammod (pi/2, 100, 10)

## https://www.geeksforgeeks.org/amplitude-modulation-using-matlab/
%!demo
%! ## carrier Frequency
%! fc = 200;
%! 
%! ## sampling frequency
%! fs= 4000;
%! 
%! ## time Duration
%! t = (0 : 1 ./ fs : 1);
%! 
%! ## sine Wave with time duration of 't'
%! x = sin (2 .* pi .* t);
%! 
%! ## Amplitude Modulation
%! y = ammod (x, fc, fs);
%! 
%! plot(y);
%! title('Amplitude Modulation');
%! xlabel('Time(sec)');
%! ylabel('Amplitude');
