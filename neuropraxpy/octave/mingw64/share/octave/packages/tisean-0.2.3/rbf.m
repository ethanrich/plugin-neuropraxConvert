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
## @deftypefn{Function File} {[@var{par}, @var{forecast}] =} rbf (@var{X})
## @deftypefnx{Function File} {[@var{par}, @var{forecast}] =} rbf (@var{X}, @var{paramName}, @var{paramValue}, @dots{})
##
## This program models the data using a radial basis function (rbf) ansatz.
## The basis functions used are gaussians, with center points chosen to be data
## from the time series. If the 'DriftOff' switch is not set, a kind of
## Coulomb force is applied to them to let them drift a bit in order to
## distribute them more uniformly. The variance of the gaussians is set to the
## average distance between the centers.
## This program either tests the ansatz by calculating the average forecast
## error of the model, or makes a i-step prediction using the -L flag,
## additionally. The ansatz made is:
##
## @iftex
## @tex
## $$ x_{n+1} = a_0 + SUM a_{i}f_{i}(x_{n})$$
## @end tex
## @end iftex
## @ifnottex
## @example
## x_n+1 = a_0 SUM a_i * f_i(x_n)
## @end example
## @end ifnottex
##
## where x_n is the nth delay vector and f_i is a gaussian centered at the ith
## center point.
##
## @strong{Input}
##
## @table @var
## @item X
## Must be realvector. The output will be alligned with the input.
## @end table
##
## @strong{Parameters}
##
## @table @var
## @item m
## The embedding dimension. Synonymous with flag '-m' from TISEAN
## [default = 2].
## @item d
## Delay used for embedding [default = 1].
## @item p
## Number of centers [default = 10].
## @item s
## Steps to forecast (for the forecast error) [default = 1].
## @item n
## Number of points for the fit. The other points are used to estimate the
## out of sample error [default = length (@var{X})].
## @item l
## Determines the length of the predicted series [default = 0].
## @end table
##
## @strong{Switch}
##
## @table @var
## @item DriftOff
## Deactivates the drift (Coulomb force), which is otherwise on.
## @end table
##
## @strong{Output}
##
## @table @var
## @item pars
## This structure contains parameters used for the fit. It has the following
## fields:
## @itemize @bullet
## @item
## centers - contains coordinates of the center points
## @item
## var - variance used for the gaussians
## @item
## coeffs - contains the coefficients (weights) of the basis functions used
## for the model
## @item
## err - err(1) is the in sample error, and err(2) is the out of sample error
## (if it exists)
## @end itemize
## @item forecast
## Contains the forecasted points. It's length is equal to the value of
## parameter @var{l}
## @end table
##
## @strong{Algorithms}
##
## The algorithms for this functions have been taken from the TISEAN package.
## @end deftypefn

## Author: Piotr Held <pjheld@gmail.com>.
## This function is based on rbf of TISEAN 3.0.1
## https://github.com/heggus/Tisean"

function [pars, forecast] = rbf (X, varargin)

  # Initial input validation
  if (nargin < 1 || nargout > 2)
    print_usage;
  endif

  if ((isvector (X) == false) || (isreal(X) == false))
    error ('Octave:invalid-input-arg', "X must be a realvector");
  endif

  # Checking if the data isn't too short
  if (length (X) < 2)
    error ('Octave:invalid-input-arg', "X must have more elements than 1");
  endif

  # Default parameters
  embdim     = 2;
  delay      = 1;
  center_par = 10;
  step       = 1;
  insample   = length (X);
  clength    = 1000;

  #### Parse the input
  p = inputParser ();
  p.FunctionName = "rbf";

  isPositiveIntScalar = @(x) isreal(x) && isscalar (x) && ...
                             (x > 0) && (x-round(x) == 0);
  isPositiveScalar     = @(x) isreal(x) && isscalar (x) && (x > 0);

  p.addParamValue ("m", embdim, isPositiveIntScalar);
  p.addParamValue ("d", delay, isPositiveIntScalar);
  p.addParamValue ("p", center_par, isPositiveIntScalar);
  p.addParamValue ("s", step, isPositiveIntScalar);
  p.addParamValue ("n", insample, isPositiveIntScalar);
  p.addParamValue ("l", clength, isPositiveIntScalar);
  p.addSwitch ("DriftOff");

  p.parse (varargin{:});

  # Assign inputs
  embdim     = p.Results.m;
  delay      = p.Results.d;
  center_par = p.Results.p;
  step       = p.Results.s;
  insample   = p.Results.n;
  clength    = p.Results.l;
  makecast   = !ismember ('l',p.UsingDefaults);
  setdrift   = !p.Results.DriftOff;

  #Input corrections from main ()
  if (makecast)
    if (!ismember ('s', p.UsingDefaults))
      warning ('Octave:tisean', "Making forecast therefore value of parameter \
's' is now 1");
    endif
    step=1;
  endif

  if (insample > length (X))
    warning ('Octave:tisean', "Parameter 'n' was too large, it has been \
reduced to: %d", length (X));
    insample = length (X);
  endif

  if (center_par > length (X))
    warning ('Octave:tisean', "Parameter 'p' was too large, it has been \
reduced to: %d", length (X));
    center_par = length (X);
  endif

  # Correct X to always have more rows than columns
  trnspsd = false;
  if (rows (X) < columns (X))
    X = X.';
    trnspsd = true;
  endif

  ## If not enough outputs were specified
  if ((nargout < 2) && makecast)
    warning ('Octave:tisean', "Only one output was specified, no place to \ return forecasted points");
    makecast = false; 
  endif

  [centers, variance, coeffs, sample_err, forecast] = ...
    __rbf__ (X, embdim, delay, center_par, step, insample, clength, ...
             makecast, setdrift);

  if (trnspsd)
    centers    = centers.';
    variance   = variance.';
    coeffs     = coeffs.';
    sample_err = sample_err.';
    forecast   = forecast.';
  endif

  pars = struct ("centers", centers, "var", variance, "coeffs", coeffs,...
                "err", sample_err);

endfunction

%!demo
%! # sin_saw is a sinusoid multiplied by a saw function
%! idx = (1:2500).';
%! sin_saw = (5 + mod (idx, 165) ./15) .* sin (idx.* 2 * pi /32);
%!
%! forc_no = 170; #Number of forecasted points
%! [p,forecast]  = rbf (sin_saw(1:end-forc_no), 'm', 2, 'd', 6, 'p',12,...
%!                          'n',length(idx)-forc_no, 'l',forc_no);
%! plot (idx(end-forc_no+1:end), sin_saw(end-forc_no+1:end),'b',...
%!       idx(end-forc_no+1:end), forecast,'r.')
%! legend ('Actual Data', 'Forecasted Data')
%! legend ('Location','NorthWest')
%! axis tight
%!###############################################################

%% tisean_res values have been generated using
%% 'rbf hen1000.dat -m4 -d6 -n500 -L15'
%!shared tisean_res
%! centers   = [-4.320358e-01 -2.908398e-01 -9.039490e-01 9.768052e-01;6.979680e-01 9.502747e-01 -6.343287e-02 -8.834032e-02;-1.162171e-01 5.679579e-01 4.271632e-01 1.268386e-01;9.102671e-01 1.503345e+00 -4.783169e-01 5.498855e-01;-1.351572e+00 3.702876e-01 1.988522e-01 3.312123e-01;4.702139e-01 1.362105e+00 -2.625473e-01 1.226374e+00;1.150574e+00 7.697759e-01 8.992073e-01 -5.873108e-01;1.353985e+00 -6.395022e-03 -6.807937e-01 1.425706e+00;-7.949164e-01 1.161663e+00 1.300960e+00 -1.008006e+00;2.563368e-01 1.852738e-01 -1.137004e+00 7.576612e-01];
%! variance  = 1.085525e+00;
%! coeffs = [1.183600e-01;1.374653e+00;-8.147723e-01;3.951915e+00;-7.316014e-01;-4.226517e+00;7.865977e-01;-1.715572e+00;-2.992770e+00;7.985524e-01;9.965155e-01];
%! sam_error = [5.846869e-01;6.037938e-01];
%! forecast  = [2.975456e-01;7.949214e-01;-1.790842e-02;1.276656e+00;-6.040927e-01;6.557837e-01;1.390711e-02;1.067956e+00;-5.644539e-01;4.157955e-01;3.995851e-01;5.708989e-01;8.507144e-01;-1.989717e-01;1.216499e+00];
%! tisean_res = {centers, variance, coeffs, sam_error, forecast};

%!test
%! hen = henon (1000);
%! hen = hen(:,1);
%! [par, forecast] = rbf (hen,'m',4, 'd', 6, 'n',500,'l',15);
%! res = {par.centers, par.var, par.coeffs, par.err, forecast};
%! assert (res, tisean_res, -1e-6);

%% test if the program returns empty matrix when not told to cast
%!test
%! [p,f] = rbf(henon(100)(:,1));
%! assert(f,[]);

%% test if singular matrixes are found
%!error <singular> rbf(1:10);

%% ensure input correction warnings are called
%% they are promoted to errors so that the program does not do computation
%!error <forecast> warning("error","Octave:tisean"); [p,f] =rbf (1:10,...
%!                                                              's',2,'l',3);
%!error <too large> warning("error","Octave:tisean"); rbf (1:10, 'p',11);
%!error <too large> warning("error","Octave:tisean"); rbf (1:10, 'n',11);
%!error <one output> warning("error","Octave:tisean"); rbf (1:10, 'l',11);
