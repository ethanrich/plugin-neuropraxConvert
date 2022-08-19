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
## @deftypefn{Function File} {[@var{lyap_exp}, @var{pars}] =} lyap_spec (@var{S})
## @deftypefnx{Function File} {[@var{lyap_exp}, @var{pars}] =} lyap_spec (@var{S}, @var{paramName}, @var{paramValue}, @dots{})
##
## Estimates the spectrum of Lyapunov exponents using the
## method of Sano and Sawada.
##
## @strong{Input}
##
## @table @var
## @item S
## This function always assumes that each time series is along the longer 
## dimension of matrix @var{S}. It also assumes that every dimension 
## (counting along the shorter dimension) of @var{S} is considered a 
## component of the time series.
## @end table
##
## @strong{Parameters}
##
## @table @var
## @item m
## Embedding dimension [default = 2].
## @item d
## Currently unused, will be delay used in future.
## @item n
## Number of iterations [default = length (@var{S})].
## @item r
## Minimum neighborhood size [default = 1e-3].
## @item f
## Factor to increase the size of the neighborhood if the program didn't
## find enough neighbors [default = 1.2].
## @item k
## Number of neighbors to use (this implementation uses exactly the number of
## neighbors specified, if more are found only the @var{K} nearest are used)
## [default = 30].
## @item p
## Specify after how many iteration should the current output be 
## displayed. This is useful for data sets that can take a long time.
## Also, if the program runs longer than 10 seconds it will display the current
## state, regardless [default = calculate all of the data at once and don't
## intermediary steps].
## @end table
##
## @strong{Switch}
##
## @table @var
## @item invert
## Inverts the order of the time series. Can help finding spurious exponents.
## @end table
##
## @strong{Output}
##
## The output is alligned with the components of the input.
## @table @var
## @item lyap_exp
## Assuming an input with column vectors this part of the output will consist 
## of @code{columns (S) * m + 1} columns (the 'm' stands for the embedding
## dimension). The first column will be the iteration number and rest contain
## estimates of the Lyapunov exponents in decreasing order.
## @item pars
## This is a struct that contains the following parameters associated with
## the calculated Lyapunov exponents:
## @itemize @bullet
## @item
## rel_err - the relative error for every dimension of the input
## @item
## abs_err - the absolute error for every dimension of the input
## @item
## nsize - average neighborhood size
## @item
## nno - average number of neighbors
## @item
## ky_dim - estimated KY-Dimension
## @end itemize
## @end table
##
## @seealso{lyap_k, lyap_r}
##
## @strong{Algorithms}
##
## The algorithms for this functions have been taken from the TISEAN package.
## @end deftypefn

## Author: Piotr Held <pjheld@gmail.com>.
## This function is based on lyap_spec of TISEAN 3.0.1 
## https://github.com/heggus/Tisean"

function [lyap_exp, pars] = lyap_spec (S, varargin)

  if (nargin < 1 || nargout > 2)
    print_usage;
  endif

  if ((ismatrix (S) == false) || (isreal(S) == false) || ...
       (isreal(S) == false))
    error ('Octave:invalid-input-arg', "S must be a realmatrix");
  endif

  # Default values
  embed          = 2;
  delay          = 1;
  iterations     = length (S);
  epsmin         = 1e-3;
  epsstep        = 1.2;
  minn           = 30;
  iterator_pause = length (S);

  #### Parse the input
  p = inputParser ();
  p.FunctionName = "lyap_spec";

  isPositiveIntScalar = @(x) isreal(x) && isscalar (x) && ...
                             (x > 0) && (x-round(x) == 0);
  isPositiveScalar    = @(x) isreal(x) && isscalar (x) && (x > 0);

  p.addParamValue ("m", embed, isPositiveIntScalar);
  p.addParamValue ("d", delay, isPositiveIntScalar);
  p.addParamValue ("n", iterations, isPositiveIntScalar);
  p.addParamValue ("r", epsmin, isPositiveScalar);
  p.addParamValue ("f", epsstep, isPositiveScalar);
  p.addParamValue ("k", minn, isPositiveIntScalar);
  p.addParamValue ("p", iterator_pause, isPositiveIntScalar);
  p.addSwitch ("invert");

  p.parse (varargin{:});

  # Assign input
  embed          = p.Results.m;
#  delay           = p.Results.d;
  iterations     = p.Results.n;
  epsmin         = p.Results.r;
  epsset         = !ismember ('r', p.UsingDefaults);
  epsstep        = p.Results.f;
  minn           = p.Results.k;
  invert         = p.Results.invert;
  iterator_pause = p.Results.p;

  # Correct S to always have more rows than columns
  trnspsd = false;
  if (rows (S) < columns (S))
    S = S.';
    trnspsd = true;
  endif

  # Invert each component in the time series
  if (invert)
    S = S(rows(S):-1:1,:);
  endif

  # Input validation from old main()
  if (minn > (length (S)-delay*(embed-1)-1))
    error ('Octave:invalid-input-arg', ...
           "Your time series is not long enough to find %d neighbors!", minn);
  endif

  # Input adjustment from main()
  if (iterations >(length (S)-delay))
    if (!ismember ('n', p.UsingDefaults))
      warning ('Octave:tisean', ["Value of parameter 'n' too large, ", ...
                                 "setting 'n' = %d"], length (S) - delay);
    endif
    iterations = length (S) - delay;
  endif



  [lyap_exp, vars] = __lyap_spec__ (S, embed, iterations, epsmin, ...
                                    epsset, epsstep, minn, iterator_pause);

  calc_paused = false;
  while (isfield (vars, "count") ...
         && vars.count < (iterations - (embed-1)*delay))

    printf ("\n");
    if (trnspsd)
      lyap_exp = mat2str(lyap_exp.')
    else
      lyap_exp = mat2str(lyap_exp)
    endif
    fflush (stdout);
    calc_paused   = true;
    [lyap_exp, vars] = __lyap_spec__ (S, embed, iterations, vars.epsmin, ...
                                      epsset, epsstep, minn, iterator_pause,
                                      vars.count, ...
                                      vars.averr, vars.delta, vars.avneig,...
                                      vars.aveps);
  endwhile

  if (calc_paused)
    printf ("\n");
    fflush (stdout);
  endif

  pars = vars;

  # Correct the exponents to allign with input
  if (trnspsd)
  lyap_exp = lyap_exp.';
  endif

endfunction

%!test
%! hen = henon(1000)(:,1);
%! lyap_spec_res = [97 1.475854e+00 4.569062e-01 -4.080476e-01 -9.133782e-01];
%! res = lyap_spec (hen, 'm', 4, 'n', 100, 'k', 50, 'invert');
%! assert (res, lyap_spec_res, -1e-6);

%!shared tisean_res
%! lyap       =[97 1.724734 1.344298 0.6055269 0.1107455 -0.1679277 -0.4839892 -0.6831324 -1.279134];
%! rel_err    = [9.879479e-02 5.606372e-02];
%! abs_err    = [4.645455e-02 3.915540e-02];
%! nsize      = 7.035643e-01;
%! nno        = 50;
%! ky_dim     = 8;
%! tisean_res = {lyap, rel_err, abs_err, nsize, nno, ky_dim};

%!test
%! ik = ikeda(1000);
%! [lyap, pars] = lyap_spec (ik, 'm',4, 'n',100, 'k', 50,'invert');
%! res = {lyap, pars.rel_err, pars.abs_err, pars.nsize, pars.nno, pars.ky_dim};
%! assert (res, tisean_res, 1e-6);

%% test for matrix near singularity
%!error <singular> lyap_spec (sin((1:1000).'./360), 'm',4);

%% Testing input validation
%!error <not long> lyap_spec (1:10, 'k',10);
%% Promote warnings to error to not execute program
%!error <too large> warning("error", "Octave:tisean"); ...
%!                  lyap_spec(1:100,'n',100);
