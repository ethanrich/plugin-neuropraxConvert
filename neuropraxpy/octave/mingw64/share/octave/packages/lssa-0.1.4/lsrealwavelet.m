## Copyright (C) 2012 Benjamin Lewis <benjf5@gmail.com>
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

##-*- texinfo -*-
## @deftypefn {Function File} {t =} lsrealwavelet( @var{time}, @var{mag},
## @var{maxfreq}, @var{coefficients}, @var{octaves}, @var{time_min},
## @var{time_max}, @var{min_window_count} )
## 
## Computes a windowed transform of the supplied (@var{time}, @var{mag}) series
## of real-valued magnitudes, applying progressively wider windows as the
## frequencies tested decline from the maximum frequency.
## 
## Currently non-functional.
##
## @seealso{lscomplexwavelet, lswaveletcoeff, lscorrcoeff}
##
## @end deftypefn


function transform = lsrealwavelet(T, X, maxfreq, ncoeff, noctave, t_min, t_max, minimum_window_number )

omegamult = 2 ^ ( - 1/ ncoeff )
omegamult_inv = 1 / omegamult

minimum_window_width = ( t_max - t_min ) / minimum_window_number;
minimum_window_radius = minimum_window_width / 2;

sigma = maxfreq * 2 ^ ( noctave ) / minimum_window_radius;
## sigma needs to be such that | t _ k - t | = minimum_window_radius implies
## that sigma * maxfrequency * 2 ^ ( - noctave ) * minimum_window_radius = 1

## for a specific other frequency, sigma * frequency * window_radius = 1 means
## window_radius = 1 / ( frequency * sigma )


o = maxfreq;

# zeta _ ( t , omega ) = sum(w(sigma omega (t_k - t )e^(-i omega (t_k - t))xi_k)
# / sum( w(sigma omega ( t_k - t ) ) );
#
# w ( t ) = { 1 - 3 | t | ^ 2 + 2 | t | ^ 3 , t in [ - 1 , 1 ] ; 0 for others }

# Now, I *think* that this transform is supposed to be applied by taking
# t as the centre of each window, while sigma should scale the time
# values inside the window to the window. I think.

transform = cell(noctave*ncoeff,1);

for iter = 1:(noctave*ncoeff)
  ## in this, win_t is the centre of the window in question
  window_min = t_min;
  ## Although that will vary depending on the window. This is just an
  ## implementation for the first window.
  current_frequency = maxfreq * 2 ^ ( - iter / ncoeff );
  current_radius = 1 / ( current_frequency * sigma );
  current_window_number = ceil( ( t_max - t_min ) / current_radius);
  
  transform{iter} = zeros(1,current_window_number);
  win_t = window_min + current_radius;
  for iter_window = 1:current_window_number
    ## the beautiful part of this code is that if parts end up falling outside the
    ## vector, it won't matter (although it's wasted computations.)
    ## I may add a trap to avoid too many wasted cycles.
    windowed_t = ((abs (T-win_t) < current_radius) .* T);
    ## this will of course involve an additional large memory allocation, at least in the short term,
    ## but it's faster to do the operation once on the time series, then multiply it by the data series.
    iota0 = sum ( cubicwgt (windowed_t ./ current_radius ) );
    zeta = sum( cubicwgt ((windowed_t - win_t) ./ current_radius) .* exp( - i * o .* windowed_t ) .* X ) / iota0;
    iota = sum( cubicwgt ((windowed_t - win_t) ./ current_radius) .* exp( - i * 2 * o .* windowed_t) .* X ) / sum ( cubicwgt( windowed_t .* 2 * o ) );
    transform{iter}(iter_window) = 2 * ( conj(zeta) * iota0 + zeta * conj(iota) ) / ( ( length ( find (windowed_t)) + iota0 ) ^ 2 - real(iota) ^ 2 - imag(iota) ^ 2 );
    window_min += 2 * current_radius;
    ## I remain hesitant about this value, since it is entirely possible necessary precision will be lost. Should I try to reduce that?
  endfor
  o *= omegamult;
endfor
  
endfunction
