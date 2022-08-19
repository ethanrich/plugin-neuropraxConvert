## Copyright (C) 2015 Parsiad Azimzadeh <parsiad.azimzadeh@gmail.com>
##
## This program is free software; you can redistribute it and/or modify it under
## the terms of the GNU Lesser General Public License as published by the Free
## Software Foundation; either version 3 of the License, or (at your option) any
## later version.
##
## This program is distributed in the hope that it will be useful, but WITHOUT
## ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
## FITNESS FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License
## for more details.
##
## You should have received a copy of the GNU Lesser General Public License
## along with this program; if not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn  {Function File} {@var{SDE} =} sde (@var{DriftRate}, @var{DiffusionRate})
## @deftypefnx {Function File} {@var{SDE} =} sde (@var{DriftRate}, @var{DiffusionRate}, @var{OptionName}, @var{OptionValue}, @dots{})
## Creates an object to represent a stochastic differential equation (SDE).
##
## @center dX_t = @var{DriftRate}(t, X_t)dt + @var{DiffusionRate}(t, X_t)dW_t.
##
## @itemize
## @item (X_t) is an NVARS-dimensional process;
## @item (W_t) is an NBROWNS-dimensional Wiener process.
## @end itemize
##
## @itemize
## @item
## Variable: @var{DriftRate} A drift object or function that returns an
## NVARS-by-1 vector.
## @item
## Variable: @var{DiffusionRate} A diffusion object or function that returns an
## NVARS-by-NBROWNS matrix.
## @end itemize
##
## A list of options recognized by sde are given below:
## @itemize
## @item StartTime - Time of the first observation. If unspecified, the default
##                   is 0.
## @item StartState - Scalar, NVARS-dimensional column vector, or
##                    NVARS-by-NTRIALS matrix of initial values of the state
##                    variables.
##                    If unspecified, X_0 is taken to be a vector of ones.
## @item Correlation - NBROWNS-by-NBROWNS real symmetric positive definite
##                     matrix specifying correlations between Wiener processes.
##                     For nonconstant correlation, a function of time returning
##                     an NBROWNS-by-NBROWNS matrix can be specified.
##                     If unspecified, the identity matrix is used.
## @item Simulation - Function handle pointing to simulation method.
##                    If unspecified, simByEuler is used.
## @end itemize
##
## @seealso{drift, diffusion}
## @end deftypefn

function SDE = sde (DriftRate, DiffusionRate, varargin)

  ## Check number of arguments
  if (nargin < 2)
    print_usage();
  elseif (mod (nargin, 2) == 1)
    error ("sde: optional arguments must be specified in key-value pairs");
  endif

  ## Default parameters
  SDE.StartTime = 0.;
  SDE.Simulation = @simByEuler;

  if (isa (DriftRate, "drift"))
    SDE.Drift = DriftRate.Rate;
  elseif (isa (DriftRate, "function_handle") && nargin (DriftRate) == 2)
    SDE.Drift = DriftRate;
  else
    error ("sde: DRIFTRATE must be an object of the drift class or a function with two inputs");
  endif

  if (isa (DiffusionRate, "diffusion"))
    SDE.Diffusion = DiffusionRate.Rate;
  elseif (isa (DiffusionRate, "function_handle") && nargin (DiffusionRate) == 2)
    SDE.Diffusion = DiffusionRate;
  else
    error ("sde: DIFFUSIONRATE must be an object of the drift class or a function with two inputs");
  endif

  ## Parse options
  UserSpecifiedStartState = false;
  UserSpecifiedCorrelation = false;
  for i = 1:length(varargin)/2
    key = varargin{2*i-1};
    value = varargin{2*i};
    if (! (ischar (key) && isvector (key)))
      error ("sde: key must be a string");
    endif
    switch (key)
      case "StartTime"
        if (! (isscalar (value) && isreal (value)))
          error ("sde: StartTime must be a real scalar");
        endif
        SDE.StartTime = value;
      case "StartState"
        if ((! isreal (value)) || isempty (value))
          error ("sde: StartState must be a real scalar, vector, or matrix (nonempty)");
        endif
        SDE.StartState = value;
        UserSpecifiedStartState = true;
      case "Correlation"
        if (! (isa (value, "function_handle") || (isreal (value) && issymmetric (value) && isdefinite (value))))
          error ("sde: Correlation must be a real symmetric positive definite matrix or a function of time that returns such a matrix");
        endif
        SDE.Correlation = value;
        UserSpecifiedCorrelation = true;
      case "Simulation"
        if (! isa (value, "function_handle"))
          error ("sde: Simulate must be a function handle");
        endif
        SDE.Simulation = value;
      otherwise
        error ("sde: unrecognized option %s", key);
    endswitch
  endfor

  ## Infer default StartState if unspecified
  if (! UserSpecifiedStartState)
    Resolved = false;

    if (isa (DriftRate, "drift"))
      Resolved = true;
      if (isnumeric (DriftRate.A))
        SDE.StartState = ones (rows (DriftRate.A), 1);
      elseif (isnumeric (DriftRate.B))
        SDE.StartState = ones (rows (DriftRate.B), 1);
      else
        Resolved = false;
      endif
    endif

    if ((! Resolved) && isa (DiffusionRate, "diffusion"))
      Resolved = true;
      if (isnumeric (DiffusionRate.Alpha))
        SDE.StartState = ones (rows (DiffusionRate.Alpha), 1);
      elseif (isnumeric (DiffusionRate.Sigma))
        SDE.StartState = ones (rows (DiffusionRate.Sigma), 1);
      else
        Resolved = false;
      endif
    endif

    if (! Resolved)
      error ("sde: cannot resolve NVARS; you must specify the StartState option explicitly");
    endif
  endif

  ## Use the default correlation matrix
  if (! UserSpecifiedCorrelation)
    ## Infer the size of NVARS and NBROWNS
    NVARS = size (SDE.StartState, 1);
    NBROWNS = size (SDE.Diffusion (0, ones (NVARS, 1)), 2);
    SDE.Correlation = eye (NBROWNS, NBROWNS);
  endif

  SDE = class (SDE, "sde");

endfunction

## Test input validation
%!error sde ()
%!error sde (1)
%!error sde (1, 2)
%!error sde (1, 2, "OptionName")
