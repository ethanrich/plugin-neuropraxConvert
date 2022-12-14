## Copyright (C) 2006 Peter V. Lanspeary <pvl@mecheng.adelaide.edu.au>
##
## This program is free software: you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation, either version 3 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; see the file COPYING. If not, see
## <https://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} {[psd,f_out] =} pyulear(x,poles,freq,Fs,range,method,plot_type)
## Calculates a Yule-Walker autoregressive (all-pole) model of the data "x"
## and computes the power spectrum of the model.
##
## This is a wrapper for functions "aryule" and "ar_psd" which perform the
## argument checking.
##
## See "help aryule" and "help ar_psd" for further details.
##
## ARGUMENTS:
##
##     All but the first two arguments are optional and may be empty.
## @table @asis
##   @item x
##     [vector] sampled data
##
##   @item poles
##     [integer scalar] required number of poles of the AR model
##
##   @item freq
##     [real vector] frequencies at which power spectral density
##           is calculated
##
##     [integer scalar] number of uniformly distributed frequency
##           values at which spectral density is calculated.
##           [default=256]
##
##   @item Fs
##     [real scalar] sampling frequency (Hertz) [default=1]
## @end table
##
## CONTROL-STRING ARGUMENTS -- each of these arguments is a character string.
##
##   Control-string arguments can be in any order after the other arguments.
##
## @table @asis
##   @item range
##     'half',  'onesided' : frequency range of the spectrum is
##           from zero up to but not including sample_f/2.  Power
##           from negative frequencies is added to the positive
##           side of the spectrum.
##
##     'whole', 'twosided' : frequency range of the spectrum is
##           -sample_f/2 to sample_f/2, with negative frequencies
##           stored in "wrap around" order after the positive
##           frequencies; e.g. frequencies for a 10-point 'twosided'
##           spectrum are 0 0.1 0.2 0.3 0.4 0.5 -0.4 -0.3 -0.2 -0.1
##
##      'shift', 'centerdc' : same as 'whole' but with the first half
##           of the spectrum swapped with second half to put the
##           zero-frequency value in the middle. (See "help
##           fftshift". If "freq" is vector, 'shift' is ignored.
##
##      If model coefficients "ar_coeffs" are real, the default
##      range is 'half', otherwise default range is 'whole'.
##
##   @item method
##      'fft':  use FFT to calculate power spectrum.
##
##      'poly': calculate power spectrum as a polynomial of 1/z
##           N.B. this argument is ignored if the "freq" argument is a
##           vector.  The default is 'poly' unless the "freq"
##           argument is an integer power of 2.
##
## @item plot_type 
##    'plot', 'semilogx', 'semilogy', 'loglog', 'squared' or 'db':
##           specifies the type of plot.  The default is 'plot', which
##           means linear-linear axes. 'squared' is the same as 'plot'.
##           'dB' plots "10*log10(psd)".  This argument is ignored and a
##           spectrum is not plotted if the caller requires a returned
##           value.
## @end table
##
## RETURNED VALUES:
##
##     If return values are not required by the caller, the spectrum
##     is plotted and nothing is returned.
##
## @table @asis
##   @item psd
##   [real vector] power-spectrum estimate
##   @item f_out
##   [real vector] frequency values
## @end table
##
## HINTS
##
##   This function is a wrapper for aryule and ar_psd.
##
##   See "help aryule", "help ar_psd".
## @end deftypefn

function [psd,f_out]=pyulear(x,poles,varargin)

  ##
  if ( nargin<2 )
    error( 'pburg: need at least 2 args. Use "help pburg"' );
  endif
  ##
  [ar_coeffs,residual,k]=aryule(x,poles);
  if ( nargout==0 )
    ar_psd(ar_coeffs,residual,varargin{:});
  elseif ( nargout==1 )
    psd = ar_psd(ar_coeffs,residual,varargin{:});
  elseif ( nargout>=2 )
    [psd,f_out] = ar_psd(ar_coeffs,residual,varargin{:});
  endif

endfunction

%!demo
%! a = [1.0 -1.6216505 1.1102795 -0.4621741 0.2075552 -0.018756746];
%! Fs = 25;
%! n = 16384;
%! signal = detrend (filter (0.70181, a, rand (1, n)));
%! % frequency shift by modulating with exp(j.omega.t)
%! skewed = signal .* exp (2*pi*i*2/Fs*[1:n]);
%! hold on;
%! pyulear (signal, 3, [], Fs);
%! pyulear (signal, 4, [], Fs, "whole");
%! pyulear (signal, 5, 128, Fs, "shift", "semilogy");
%! pyulear (skewed, 7, 128, Fs, "shift", "semilogy");
%! user_freq = [-0.2:0.02:0.2]*Fs;
%! pyulear (skewed, 7, user_freq, Fs, "semilogy");
%! hold off;
