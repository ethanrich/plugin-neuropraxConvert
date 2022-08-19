## Copyright (C) 2012 Ben Lewis <benjf5@gmail.com>
##
## This software is free software; you can redistribute it and/or modify it under
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
##
## @deftypefn {Function File} {@var{t} =} lscomplexwavelet (@var{time},
##@var{mag}, @var{maxfreq}, @var{numcoeff}, @var{numoctave}, @var{min_time},
##@var{max_time}, @var{step_time}, @var{sigma}
##
##
## @end deftypefn

function transform = lscomplexwavelet( T, X, omegamax, ncoeff, noctave, tmin, tmax, tstep, sigma = 0.05)

  ## This function applies a wavelet version of the lscomplex transform; the
  ## transform is applied for each of multiple windows centred on different time
  ## values, depending on how many windows are required, since the number of
  ## windows required for each frequency decreases as the size of the windows
  ## increases.  A higher frequency requires a smaller window to accurately
  ## capture its details, while a low frequency requires a larger window to
  ## accomodate its commensurately slower rate of change.  For each window, the
  ## time series is weighted against the cubicwgt function, whose shape is near
  ## coincident with the Hanning window; unlike the Hanning window, however, the
  ## cubicwgt window does not involve trigonometric functions—thus it is faster
  ## to apply to large sets.  (Well, testing on my system suggests that for very
  ## large data sets it actually slows down as it needs to allocate more
  ## memory.  In this instance, a loop may be more effective than a vectorized
  ## function; more study is needed.)  After the window is found, the transform
  ## is taken at the given frequency, wherein each term is also multiplied by
  ## the value of the window at its position in the time series. This reduces
  ## the size of the time series under consideration and improves the local
  ## accuracy of the transform to the frequency in question.
  ##
  ## My problem with the code as it stands is, it doesn't have a good way of
  ## determining the window size. Sigma is currently up to the user, and sigma
  ## determines the window width (but that might be best.) Moreover, the method
  ## of windowing involved (from the source code provided with the paper,
  ## Mathias, A. et. al. "Algorithms for Spectral Analysis of Irregularly
  ## Sampled Time Series". Journal of Statistical Software, vol. 11 issue 2, May
  ## 2004.) does not seem to always cover all values in the data set, and makes
  ## me suspicious of its ability to accurately transform a data set.
  ##
   
  transform = cell(noctave*ncoeff,1);
  
  for octave_iter = 1:noctave
    ## In fastnu.c, winrad is set as π/(sigma*omegaoct); I suppose this is
    ## ... feasible, although it will need to be noted that if sigma is set too
    ## large, the windows will exclude data. I can work with that.
    ##
    ## An additional consideration is that 
    
    for coeff_iter = 1:ncoeff
      
      ## in this, win_t is the centre of the window in question
      ## Although that will vary depending on the window. This is just an
      ## implementation for the first window.
      
      current_iteration = (octave_iter-1)*ncoeff+coeff_iter;
      window_radius = pi / ( sigma * omegamax * ( 2 ^ ( current_iteration - 1 ) ) );
      window_count = 2 * ceil ( ( tmax - tmin ) / window_radius ) - 1;
      omega = current_frequency = omegamax * 2 ^ ( - octave_iter*coeff_iter / ncoeff );
      
      
      
      transform{current_iteration}=zeros(1,window_count);

      ## win_t is the centre of the current window.
      win_t = tmin + window_radius;
      for iter_window = 1:window_count
        ## Computes the transform as stated in the paper for each given frequency.
        zeta = sum ( cubicwgt ( sigma .* omega .* ( T - win_t ) ) .* exp ( -i .* omega .* ( T - win_t ) ) .* X ) / sum ( cubicwgt ( sigma .* omega .* ( T - win_t ) ) .* exp ( -i .* omega .* ( T - win_t ) ) );
        transform{current_iteration}(iter_window) = zeta;
        window_min += window_radius ;
      endfor
    endfor
  
  endfor

endfunction

