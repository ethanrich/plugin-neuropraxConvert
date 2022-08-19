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
## @deftypefn{Function File} {[@var{pars}, @var{forecast}] =} rbf (@var{X})
## @deftypefnx{Function File} {[@var{pars}, @var{forecast}] =} rbf (@var{X}, @var{paramName}, @var{paramValue}, @dots{})
##
## Models the data making a polynomial ansatz.
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
## Order of the polynomial [default = 2].
## @item n
## Number of points for the fit. The other points are used to estimate
## the out of sample error [default = length (@var{X})].
## @item l
## The length of the predicted series [default = 0].
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
## free - contains the number of free parameters of the fit
## @item
## norm - contains the norm used for the fit
## @item
## coeffs - contains the coefficients used for the fit
## @item
## err - err(1) is the in sample error, and err(2) is the out of sample error
## (if it exists)
## @end itemize
## @item forecast
## Contains the forecasted points. It's length is equal to the value of
## parameter @var{l}
## @end table
##
## @seealso{demo polynom}
##
## @strong{Algorithms}
##
## The algorithms for this functions have been taken from the TISEAN package.
## @end deftypefn

## Author: Piotr Held <pjheld@gmail.com>.
## This function is based on polynom of TISEAN 3.0.1
## https://github.com/heggus/Tisean"

function [pars, forecast] = polynom (X, varargin)

  # Initial input validation
  if (nargin < 1 || nargout > 2)
    print_usage;
  endif

  if ((isvector (X) == false) || (isreal(X) == false))
    error ('Octave:invalid-input-arg', "X must be a realvector");
  endif

  # Default parameters
  embdim   = 2;
  delay    = 1;
  degree   = 2;
  insample = length (X);
  clength  = 0;

  #### Parse the input
  p = inputParser ();
  p.FunctionName = "polynom";

  isPositiveIntScalar    = @(x) isreal(x) && isscalar (x) && ...
                             (x > 0) && (x-round(x) == 0);
  isNonNegativeIntScalar = @(x) isPositiveIntScalar (x) || (length (x) == 1 ...
                                                            &&(x == 0));

  p.addParamValue ("m", embdim, isPositiveIntScalar);
  p.addParamValue ("d", delay, isPositiveIntScalar);
  p.addParamValue ("p", degree, isPositiveIntScalar);
  p.addParamValue ("n", insample, isPositiveIntScalar);
  p.addParamValue ("l", clength, isNonNegativeIntScalar);

  p.parse (varargin{:});

  # Assign inputs
  embdim   = p.Results.m;
  delay    = p.Results.d;
  degree   = p.Results.p;
  insample = p.Results.n;
  clength  = p.Results.l;

  # Input corrections from main ()
  if (insample > length (X))
    warning ('Octave:tisean', "Parameter 'n' was too large, it has been \
reduced to: %d", length (X));
    insample = length (X);
  endif

  # Correct X to always have more rows than columns
  trnspsd = false;
  if (rows (X) < columns (X))
    X = X.';
    trnspsd = true;
  endif

  [free_par, fit_norm, coeffs, sample_err, forecast] = ...
    __polynom__ (X, embdim, delay, degree, insample, clength);

  if (trnspsd)
    free_par   = free_par.';
    fit_norm   = fit_norm.';
    coeffs     = coeffs.';
    sample_err = sample_err.';
    forecast   = forecast.';
  endif

  pars = struct ("free",free_par, "norm",fit_norm,"coeffs",coeffs, ...
                 "err", sample_err);
endfunction

%!demo
%! idx = (1:2500).';
%! # sin_saw is a sinusoid multiplied by a saw function
%! sin_saw = (5 + mod (idx, 165) ./15) .* sin (idx.* 2 * pi /32);
%!
%! forc_no = 170; %Number of forecasted points
%! [p,forecast]  = polynom (sin_saw(1:end-forc_no), 'm', 2, 'd', 6, 'p', 4,
%!                          'n',length(idx)-forc_no, 'l',forc_no);
%!
%! plot (idx(end-forc_no+1:end), sin_saw(end-forc_no+1:end),'b',...
%!       idx(end-forc_no+1:end), forecast,'r.')
%! legend ('Actual Data', 'Forecasted Data')
%! axis tight
%!###############################################################

%!shared tisean_res
%! free_par   = 15;
%! fit_norm   = 7.288850e-01;
%! coeffs = [0 0 0 0 1.069020e+00;0 0 0 1 1.148981e-02;0 0 0 2 8.774236e-03;0 0 1 0 2.917788e-02;0 0 1 1 -2.070487e-02;0 0 2 0 2.716510e-02;0 1 0 0 -1.946794e-01;0 1 0 1 2.836742e-02;0 1 1 0 2.224498e-02;0 2 0 0 6.323062e-03;1 0 0 0 -1.384873e-01;1 0 0 1 9.227327e-03;1 0 1 0 -1.296314e-02;1 1 0 0 1.344875e-01;2 0 0 0 -1.325876e+00];
%! sample_err = [1.736542e-01;1.811800e-01];
%! forecast = [5.943424e-01; 4.346730e-01; 8.785541e-01; -3.759484e-02; 9.668226e-01; -2.578617e-01; 9.175962e-01; -1.684470e-01; 1.092976e+00; -6.234285e-01; 7.463370e-01; 2.116272e-01; 1.016354e+00; -4.107574e-01; 1.056590e+00];
%! tisean_res = {free_par, fit_norm, coeffs, sample_err, forecast};

%!test
%! hen = henon (1000);
%! hen = hen(:,1);
%! [pars,forc] = polynom (hen, 'm',4,'d',4,'p',2,'n',800,'l',15);
%! assert ({pars.free, pars.norm,pars.coeffs,pars.err,forc}, ...
%!         tisean_res, -1e-6);

%% Check if by default the cast does not take place
%!test
%! [p,f] = polynom(henon(100)(:,1));
%! assert (f, []);

%% Check for matrix singularity error
%!error <singular> polynom (1:10);

%% ensure input correction warnings are called
%% they are promoted to errors so that the program does not do computation
%!error <too large> warning("error","Octave:tisean"); polynom (1:10, 'n',11);
