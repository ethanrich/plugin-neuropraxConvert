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
## @deftypefn {Function File} {@var{m} =} fmdemod (@var{s}, @var{fc}, @var{fs})
## Creates the FM demodulation of the signal @var{s} 
## sampled at frequency @var{fs} with carrier frequency @var{fc}.
##
## Inputs:
## @itemize
## @item 
## @var{s}: FM modulated signal
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
## @var{m}: FM demodulation of the signal
## @end itemize
##
## @seealso{ammod, amdemod, fmmod}
## @end deftypefn

function m = fmdemod (s, fc, fs)

  if (nargin != 3)
    print_usage ();
  endif
  
  if (fs < 2 .* fc)
    error ("fmdemod: fs is too small must be at least 2 * fc")
  endif

  ds = diff (s);
  m = amdemod (abs (ds), fc, fs);

endfunction

%% Test input validation
%!error fmdemod ()
%!error fmdemod (1)
%!error fmdemod (1, 2)
%!error fmdemod (1, 2, 3, 4)

%!error <fs is too> fmdemod (pi/2, 100, 10)
