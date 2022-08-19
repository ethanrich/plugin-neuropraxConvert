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
## @deftypefn{Function File} {@var{output} =} timerev (@var{S})
## @deftypefnx{Function File} {@var{output} =} timerev (@var{S}, @var{delay})
##
## Calculates time reversal assymetry statistic.
##
## Accomplishes this using the following equation applied to each component
## separately:
##
## @iftex
## @tex
## $$\frac{\sum (y_n-y_{n-d})^3}{\sum (y_n-y_{n-d})^2}$$
## @end tex
## @end iftex
## @ifnottex
## @example
##                 3
##  sum (y  - y   ) 
##        n    n-d
## ------------------
##                 2
##  sum (y  - y   )  
##        n    n-d
## @end example
## @end ifnottex
##
## @strong{Input}
##
## @table @var
## @item S
## This function always assumes that each time series is along the longer 
## dimension of matrix @var{S}. It also assumes that every dimension 
## (counting along the shorter dimension) of @var{S} is considered a 
## component of the time series.
## @item delay
## The delay for the statistic ('d' in the equation above) [default = 1].
## @end table
##
## @strong{Output}
##
## The output is the calculated time reversal asymmetry statistic. It is calculated
## for each component separately and is alligned with the components, so if the
## input's components were columns vectors the output will be a row vector and
## vice versa.
##
## @strong{Algorithms}
##
## The algorithms for this functions have been taken from the TISEAN package.
## @end deftypefn

## Author: Piotr Held <pjheld@gmail.com>.
## This function is based on timerev of TISEAN 3.0.1
## https://github.com/heggus/Tisean"

function output = timerev (S, delay);

  # Input validation
  if (nargin != 1 && nargin != 2)
    print_usage;
  endif

  if ((!ismatrix (S)) || (!isreal(S)))
    error ('Octave:invalid-input-arg', "S is not a realmatrix");
  endif

  # If no delay was given assign 1
  if (nargin == 1)
    delay = 1;
  endif

  # Verify delay is a positive integer
  isPositiveInteger = @(x) isreal(x) && isscalar (x) && (x > 0) ...
                           && (x-round(x) == 0);
  if (!isPositiveInteger(delay))
    error ("Octave:invalid-input-arg", "delay must be a positive integer");
  endif

  # Verify the input series 'S' is at least as long as 'delay + 1'
  if (delay >= length (S))
    error ("Octave:invalid-input-arg", ["the length of the input series must ",...
                                        "be at least as long as 'delay + 1'"]);
  endif

  # Correct S to always have more rows than columns
  trnspsd = false;
  if (rows (S) < columns (S))
    S = S.';
    trnspsd = true;
  endif

  # Calculate output
  idx    = delay+1:rows(S);
  t2     = sum ((S(idx,:) - S(idx-delay,:)).^2);
  t3     = sum ((S(idx,:) - S(idx-delay,:)).^3);
  output = t3./t2;

  # Transpose output if input components were row vectors and not column vectors
  if (trnspsd)
    output = output.';
  endif

endfunction

%% Test output against TISEAN program 'timerev'
%!assert (timerev (henon (1000)(:,1),4),0.313235879,-1e-6)
%!assert (timerev (henon (1000), 4), [0.313235879, 0.312556326], -1e-6)
%!assert (timerev (henon(1000).', 4), [0.313235879; 0.312556326], -1e-6)

%% Testing input validation
%!error <positive> timerev (1, 0);
%!error <long> timerev ([1 2], 2);

%% Test if default values load properly
%!assert (timerev (henon (100)), timerev (henon (100),1))
