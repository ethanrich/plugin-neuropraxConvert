## Copyright (C) 2009-2016   Lukas F. Reichlin
##
## This file is part of LTI Syncope.
##
## LTI Syncope is free software: you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation, either version 3 of the License, or
## (at your option) any later version.
##
## LTI Syncope is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with LTI Syncope.  If not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} {} bode (@var{sys})
## @deftypefnx {Function File} {} bode (@var{sys1}, @var{sys2}, @dots{}, @var{sysN})
## @deftypefnx {Function File} {} bode (@var{sys1}, @var{sys2}, @dots{}, @var{sysN}, @var{w})
## @deftypefnx {Function File} {} bode (@var{sys1}, @var{'style1'}, @dots{}, @var{sysN}, @var{'styleN'})
## @deftypefnx {Function File} {[@var{mag}, @var{pha}, @var{w}] =} bode (@var{sys})
## @deftypefnx {Function File} {[@var{mag}, @var{pha}, @var{w}] =} bode (@var{sys}, @var{w})
## Bode diagram of frequency response.  If no output arguments are given,
## the response is printed on the screen.
##
## @strong{Inputs}
## @table @var
## @item sys
## @acronym{LTI} system.  Must be a single-input and single-output (SISO) system.
## @item w
## Optional vector of frequency values.  If @var{w} is not specified,
## it is calculated by the zeros and poles of the system.
## Alternatively, the cell @code{@{wmin, wmax@}} specifies a frequency range,
## where @var{wmin} and @var{wmax} denote minimum and maximum frequencies
## in rad/s.
## @item 'style'
## Line style and color, e.g. 'r' for a solid red line or '-.k' for a dash-dotted
## black line.  See @command{help plot} for details.
## @end table
##
## @strong{Outputs}
## @table @var
## @item mag
## Vector of magnitude.  Has length of frequency vector @var{w}.
## @item pha
## Vector of phase.  Has length of frequency vector @var{w}.
## @item w
## Vector of frequency values used.
## @end table
##
## @seealso{nichols, nyquist, sigma}
## @end deftypefn

## Author: Lukas Reichlin <lukas.reichlin@gmail.com>
## Created: November 2009
## Version: 1.0

function [mag_r, pha_r, w_r] = bode (varargin)

  if (nargin == 0)
    print_usage ();
  endif

  [H, w, sty, sys_idx] = __frequency_response__ ("bode", varargin, nargout);

  H = cellfun (@reshape, H, {[]}, {1}, "uniformoutput", false);
  mag = cellfun (@abs, H, "uniformoutput", false);
  pha = cellfun (@(H) unwrap (arg (H)) * 180 / pi, H, "uniformoutput", false);

  numsys = length (sys_idx);

## check for poles and zeroes at the origin for each of the numsys systems
  for h = 1:numsys
  # test for pure integrators  (poles at origin)
  sys1 = varargin{sys_idx(h)};
  [num,den] = tfdata (sys1,'v');
   numberofpoles = sum (roots (den) == 0);
    if (numberofpoles > 0)
       pha(h)={cell2mat(pha(h))-round(numberofpoles./4)*360};
    endif
  # test for zeroes at the origin
  numberofzeroes = sum (roots (num) == 0);
    if (numberofzeroes > 0)
      pha(h)={cell2mat(pha(h))+floor((numberofzeroes +1)./4)*360};
    endif
  endfor

  if (! nargout)

    ## get system names and create the legend
    leg = cell (1, numsys);
    for k = 1:numsys
      leg{k} = inputname (sys_idx(k));
    endfor

    ## plot
    mag_db = cellfun (@mag2db, mag, "uniformoutput", false);

    mag_args = horzcat (cellfun (@horzcat, w, mag_db, sty, "uniformoutput", false){:});
    pha_args = horzcat (cellfun (@horzcat, w, pha, sty, "uniformoutput", false){:});

    subplot (2, 1, 1)
    semilogx (mag_args{:})
    axis ("tight")
    ylim (__axis_margin__ (ylim))
    grid ("on")
    title ("Bode Diagram")
    ylabel ("Magnitude [dB]")
    legend (leg)

    subplot (2, 1, 2)
    semilogx (pha_args{:})
    axis ("tight")
    ylim (__axis_margin__ (ylim))
    grid ("on")
    xlabel ("Frequency [rad/s]")
    ylabel ("Phase [deg]")
    legend (leg)

  else

    ## no plotting, assign values to the output parameters
    mag_r = mag{1};
    pha_r = pha{1};
    w_r = w{1};

  endif

endfunction

%!demo
%! s = tf('s');
%! g = 1/(2*s^2+3*s+4);
%! bode(g);

%!test
%! s = tf('s');
%! K = 1;
%! T = 2;
%! g = K/(1+T*s);
%! [mag phas w] = bode(g);
%! mag_dB = 20*log10(mag);
%! index = find(mag_dB < -3,1);
%! w_cutoff = w(index);
%! assert (1/T, w_cutoff, eps);
