## Copyright (C) 1996-2015 Piotr Held
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
## @deftypefn{Function File} {@var{output} =} endtoend (@var{S})
## @deftypefnx{Function File} {@var{output} =} endtoend (@dots{}, 'verbose', @dots{})
## @deftypefnx{Function File} {@var{output} =} endtoend (@dots{}, @var{weigth_jump}, @dots{})
##
## Determine the effect of an end-to-end mismatch on the autocorrelation 
## structure for various sub-sequence lengths.
##
## It is important to avoid jumps and phase slips that occur when the data is
## periodically continued when making Fourier based surrogates, e.g. with 
## surrogates.
## 
## The mismatch in value is measured by:
## @iftex
## @tex
## d_{jump} = \frac{\left ( x(1) - x(N) \right )^2}{\sum\left ( x(n) 
## - \overline{x} \right )^2}
## @end tex
## @end iftex
## @ifnottex
## @example
##           /           \ 2
##           | x(1)-x(N) |
##           \           /
## d     = __________________
##  jump     __
##          \   /      _ \ 2
##           |  | x(n)-x |
##          /__ \        /
## @end example
## @end ifnottex
##
## And the phase slip by:
## @iftex
## @tex
## d_{slip} = \frac{\left ( (x(2) - x(1)) - (x(N) - x(N-1)) \right )^2}
## {\sum\left ( x(n) - \overline{x} \right )^2}
## @end tex
## @end iftex
## @ifnottex
## @example
##          /                           \ 2
##          | (x(2)-x(1))-(x(N)-x(N-1)) |
##          \                           /
## d     = _________________________________
##  slip        __
##             \   /      _ \ 2
##              |  | x(n)-x |
##             /__ \        /
## @end example
## @end ifnottex
##
## The weighted mismatch is then:
## @iftex
## @tex
## weight * d_{jump} + (1 - weight) * d_{slip}
## @end tex
## @end iftex
## @ifnottex
## @example
##       weight*d     + (1-weight)*d
##               jump               slip
## @end example
## @end ifnottex
## 
## In the multivariate case, the values are computed for each channel
## separately and then averaged.
##
## @strong{Inputs}
##
## @table @var
## @item S
## This function always assumes that each time series is along the longer
## dimension of matrix @var{S}. It also assumes that every dimension
## (counting along the shorter dimension) of @var{S} is considered a
## component of the time series.
## @item weight_jump
## The weight used [default = 0.5].
## @end table
##
## @strong {Switch}
##
## @table @var
## @item verbose
## If this switch is set the output will be displayed on the screen in
## readible format.
## @end table
##
## @strong{Output}
##
## @table @var
## @item output
## The output is a struct array that contains the following fields:
## @itemize @bullet
## @item
## length - the length of the series used in calculating the mismatch
## @item
## offset - the offset (counting from the first element) of the subseries used
## to calculate the mismatch
## @item
## lost - percent of the of the original series that was lost (not used)
## @item
## jump - the mismatch in value (given as percentage)
## @item
## slip - the phase slip (given as percentage)
## @item
## weigthed - the weigthed mismatch (given as percentage)
## @end itemize
## Each consecutive structure in this array has an increasingly lower
## weighted mismatch
## @end table
##
## @seealso{surrogates}
##
## @strong{Algorithms}
##
## The algorithms for this functions have been taken from the TISEAN package.
## @end deftypefn

## Author: Piotr Held <pjheld@gmail.com>.
## This function is based on endtoend of TISEAN 3.0.1
## https://github.com/heggus/Tisean"

function output = endtoend (S, varargin)

  if (nargin < 1 || nargin > 3)
    print_usage;
  endif

  if ((ismatrix (S) == false) || (isreal(S) == false) || ...
      (isreal(S) == false))
    error ('Octave:invalid-input-arg', "S must be a realmatrix");
  endif
  
  # Default value  
  weigth_jump = 0.5;
  verbose     = false; 

  # Parse varargin and assign weigth_jump if correct input
  is_weigth = @(x) isreal (x) && isscalar (x) && x >= 0 && x <= 1;
  if (nargin == 2)
    if (is_weigth(varargin{1}))
      weigth_jump = varargin{1};
    elseif (strcmpi (varargin{1}, "verbose"))
      verbose = true;
    else
      error ("Octave:invalid-input-arg", ["second argument must be ",...
                                          "'verbose' or number ",...
                                          "between 0 and 1"]);
    endif
  elseif (nargin == 3)
    if (is_weigth(varargin{1}) && strcmpi (varargin{2}, "verbose"))
      weigth_jump = varargin{1};
      verbose     = true;
    elseif (is_weigth (varargin{2}) && strcmpi (varargin{1}, "verbose"))
      weigth_jump = varargin{2};
      verbose     = true;
    else
      error ("Octave:invalid-input-arg", ["second and third arguments ",...
                                          "must be 'verbose' and a ",...
                                          "number between 0 and 1"]);
    endif
  endif

  # Correct S to always have more rows than columns
  trnspsd = false;
  if (rows (S) < columns (S))
    S = S.';
    trnspsd = true;
  endif

  # Assign empty values so that not to get error with short S
  length_used = {};
  offset      = {};
  lost        = {};
  jump        = {};
  slip        = {};
  weigthed    = {};

  # Loop through tune offsets to minimize jump effect
  nmaxp       = rows (S);
  etotm       = columns (S);
  original_col_S = columns (S);
S=    reshape (S, [rows(S),1,columns(S)]);

  while (nmaxp > 2)
    while (max (factor (nmaxp)) > 5)
      nmaxp -= 1;
    endwhile
    etot = original_col_S;
    for nj = 0:(rows (S) - nmaxp)
      [x,s] = mismatch (S((1:nmaxp).+nj,1,:));
      xj(1+nj) = x;
      sj(1+nj) = s;
    endfor
    [min_weighted, min_idx] = min (weigth_jump .* xj + (1 - weigth_jump) .* sj);
    if (min_weighted < etot)
      etot    = min_weighted;
      ejump   = xj(min_idx);
      eslip   = sj(min_idx);
      njump   = min_idx-1;
    endif

    # Main output creating part
    if (etot < etotm)
      etotm = etot;
      if (any (size (length_used) == 0))
        length_used = {nmaxp};
        offset      = {njump};
        lost        = {((rows (S) - nmaxp) / rows (S) * 100)}; 
        jump        = {ejump * 100};
        slip        = {eslip * 100};
        weigthed    = {etot * 100};
      else
        length_used(end+1) = nmaxp;
        offset(end+1)      = njump;
        lost(end+1)        = (rows (S) - nmaxp) / rows (S) * 100;
        jump(end+1)        = ejump * 100;
        slip(end+1)        = eslip * 100;
        weigthed(end+1)    = etot * 100;
      endif
      if (verbose)
        printf ("\n");
        printf ("length: %d, offset: %d, lost: %.1f %%\n", ...
                length_used(end){1}, offset(end){1}, lost(end){1});
        printf ("jump:     %.2f %%\n", jump(end){1});
        printf ("slip:     %.2f %%\n", slip(end){1});
        printf ("weighted: %.2f %%\n", weigthed(end){1});
      endif
    endif
    if (etot < 1e-5)
      nmaxp = 2;
    endif
    nmaxp -= 1;
  endwhile

  # If verbose is set and the output is not assigned, do not return anything
  if (verbose == false || nargout == 1)
    output = struct ("length", length_used, "offset", offset, "lost", lost, ...
                     "jump", jump, "slip", slip, "weigthed", weigthed);
  endif

endfunction

# Function for calculating jump mismatch
# For internal use only
function [xjump, sjump] = mismatch (x)

  denominator  = (rows (x) - 1) .* var (x); # <- always nonnegative values
  zero_var_idx = find (denominator == 0);
  denominator (zero_var_idx) = -1; # <- to allow inverting
  denominator                = 1./denominator;
  denominator (zero_var_idx) = 0;

  xjump = sum ((x(1,:,:) - x(end,:,:)).^2 .* denominator,3);
  sjump = sum (((x(end,:,:) - x(end-1,:,:)) - (x(2,:,:) - x(1,:,:))) .^ 2 
               .* denominator,3);
endfunction

%% Test output against TISEAN output
%!test
%! in = [1, 2, 3, 4, 5, 6, 7, 5, 4, 3, 10];
%! endtoend_res_length   = {10,9};
%! endtoend_res_offset   = {0, 1};
%! endtoend_res_lost     = {9.1, 18.2};
%! endtoend_res_jump     = {13.3333340, 5};
%! endtoend_res_slip     = {13.3333340, 20};
%! endtoend_res_weigthed = {13.3333340, 12.5};
%! res = endtoend (in);
%! assert ({res.length}, endtoend_res_length);
%! assert ({res.offset}, endtoend_res_offset);
%! assert ({res.lost}, endtoend_res_lost, 0.1);
%! assert ({res.jump}, endtoend_res_jump, 1e-6);
%! assert ({res.slip}, endtoend_res_slip, 1e-6);
%! assert ({res.weigthed}, endtoend_res_weigthed, 1e-6);

%% Test if weigth input works as in TISEAN
%!test
%! in = [1, 2, 3, 4, 5, 6, 7, 5, 4, 3, 10];
%! endtoend_res_weigthed = {13.3333340, 8.75000095, 7.20720673};
%! res = endtoend (in, 0.75);
%! assert ({res.weigthed}, endtoend_res_weigthed, 1e-6);

%% Test multivariate case against TISEAN
%!test
%! in = [1 2;2 3;3 5;4 5;5 4;6 6;7 7;5 8;4 8;3 8;10 12];
%! e2e_res_length   = {10,8};
%! e2e_res_offset   = {0, 2};
%! e2e_res_lost     = {9.1, 27.3};
%! e2e_res_jump     = {98.2389908, 50.3496513};
%! e2e_res_slip     = {15.6918240, 28.8288269};
%! e2e_res_weigthed = {56.9654121, 39.5892372};
%! res = endtoend (in);
%! assert ({res.length}, e2e_res_length);
%! assert ({res.offset}, e2e_res_offset);
%! assert ({res.lost}, e2e_res_lost, 0.1);
%! assert ({res.jump}, e2e_res_jump, 1e-5);
%! assert ({res.slip}, e2e_res_slip, 1e-5);
%! assert ({res.weigthed}, e2e_res_weigthed, 1e-5);

%% Test if input is properly parsed
%!error <must be> endtoend (1:10,2);
%!error <must be 'verbose'> endtoend (1:10,'verb');
%!error <Invalid call to endtoend> endtoend (1,2,3,4);
%!error <second and third> endtoend (1:10, 0.5, 0.5);
