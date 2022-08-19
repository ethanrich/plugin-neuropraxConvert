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
## @deftypefn  {Function File} {[@var{Paths}, @var{Times}, @var{Z}] =} simByEuler (@var{SDE}, @var{Periods}, @var{OptionName}, @var{OptionValue}, @dots{})
## Simulates a stochastic differential equation (SDE) using Euler timestepping.
##
## @itemize
## @item
## Variable: @var{SDE} An sde object.
## @item
## Variable: @var{Periods} Number of simulation periods.
## @end itemize
##
## A list of options recognized by simByEuler are given below:
## @itemize
## @item NTRIALS - Number of sample paths to use in simulation.
##                 If unspecified, the default is 1.
## @item DeltaTime - Scalar or NPERIODS-dimensional vector of timesteps.
##                   If unspecified, the default is 1.
## @item NSTEPS - Number of intervals to subdivide each period in.
##                If unspecified, the default is 1.
## @item Antithetic - Logical flag specifying if antithetic variates, a
##                    variance reduction technique, should be used.
##                    This value is ignored when Z is specified (see below).
##                    If unspecified, the default is false.
## @item Z - (NPERIODS * NSTEPS)-by-NBROWNS-by-NTRIALS three-dimensional array
##           of random samples to use in the simulation.
##           Alternatively, a function returning an NBROWNS-dimensional column
##           vector can be specified, with inputs:
## @itemize
## @item A real-valued observation time t;
## @item An NVARS-dimensional state vector X_t.
## @end itemize
## @item StorePaths - Logical flag specifying whether or not to store sample
##                    paths.
##                    If false, @var{Paths} is returned as an empty matrix.
##                    If unspecified, the default is true.
## @item Processes - Function or cell-array of functions specifying state
##                   adjustments of the form X_t = P(t, X_t-) at the end of
##                   each period (X_t- is the limit of X_s as s goes to from the
##                   right).
##                   If a single function is specified, it is applied to the end
##                   of each period.
##                   If a cell-array is specified, the functions are all applied
##                   at the end of each period in the order that they appear.
##                   If unspecified, no adjustments are made at the end of
##                   periods.
## @item Broadcast - Logical flag specifying whether or not to use broadcasting
##                   to speed up computation.
##                   If false, broadcasting is disabled.
##                   If unspecified, the default is true.
## @end itemize
##
## The outputs are described below:
## @itemize
## @item
## Variable: @var{Paths} (NPERIODS + 1)-by-NVARS-by-NTRIALS array consisting of
## the simulated paths.
## @item
## Variable: @var{Times} (NPERIODS + 1)-dimensional column vector of observation
## corresponding to the paths.
## @item
## Variable: @var{Z} (NPERIODS * NSTEPS)-by-NBROWNS-by-NTRIALS array of variates
## used to generate the process.
## @end itemize
##
## The method will attempt to use a fast broadcasting implementation whenever
## possible. This is possible when the following requirements are met:
## @itemize
## @item The methods Drift(t, X) (resp. Diffusion(t, X)) of the @var{SDE} object
##       return an NVARS-by-1-by-NTRIALS (resp. NVARS-by-NBROWNS-by-NTRIALS)
##       array when X is an NVARS-by-1-by-NTRIALS array.
## @item If the user specifies Z as a function Z(t, X), it returns an
##       NBROWNS-by-NTRIALS matrix when X is an NVARS-by-1-by-NTRIALS array.
## @item If the user specifies Processes, each function P(t, X) returns an
##       NVARS-by-1-NTRIALS array when X is an NVARS-by-1-by-NTRIALS array.
## @end itemize
## If any of the above conditions are violated, the fast broadcasting
## implementation is not used.
##
## An example is provided in the documentation of @@sde/simulate.
##
## @seealso{sde, @@sde/simulate}
## @end deftypefn

function [Paths, Times, Z] = simByEuler (SDE, Periods, varargin)

  ## Check number of arguments
  if (nargin < 2)
    print_usage();
  elseif (mod (nargin, 2) == 1)
    error ("simByEuler: optional arguments must be specified in key-value pairs");
  elseif (! isa (SDE, "sde"))
    error ("simByEuler: first argument must be an sde object");
  elseif (! (isscalar (Periods) && Periods > 0 && floor (Periods) == Periods))
    error ("simByEuler: Periods must be a positive integer");
  endif

  ## Default values
  NPERIODS = Periods;
  NTRIALS = 1;
  NSTEPS = 1;
  DeltaTime = ones (NPERIODS, 1);
  Antithetic = false;
  StorePaths = true;
  Processes = @(t, X) X;
  Broadcast = true;

  ## Parse options
  ConstantZ = true;
  UserSpecifiedZ = false;
  ProcessesIsCell = false;
  for i = 1:length(varargin)/2
    key = varargin{2*i-1};
    value = varargin{2*i};
    if (! (ischar (key) && isvector (key)))
      error ("simByEuler: key must be a string");
    endif
    switch (key)
      case "NTRIALS"
        if (! (isscalar (value) && value > 0 && floor (value) == value))
          error ("simByEuler: NTRIALS must be a positive integer");
        endif
        NTRIALS = value;
      case "DeltaTime"
        if (! (isreal (value) && (min (value > 0))))
          error ("simByEuler: DeltaTime must consist only of positive real numbers");
        endif
        if (isscalar (value))
          DeltaTime = ones (NPERIODS, 1) * value;
        elseif (isvector (value) && length (value) == NPERIODS)
          DeltaTime = value;
        else
          error ("simByEuler: DeltaTime must be a scalar or column vector of dimension equal to the specified number of periods");
        endif
      case "NSTEPS"
        if (! (isscalar (value) && value > 0 && floor (value) == value))
          error ("simByEuler: NSTEPS must be a positive integer");
        endif
        NSTEPS = value;
      case "Antithetic"
        if (! (isscalar (value) && islogical (value)))
          error ("simByEuler: Antithetic must be a scalar logical true or false");
        endif
        Antithetic = value;
      case "Z"
        ConstantZ = ! isa (value, "function_handle");
        if (! (! ConstantZ || (isreal (value) && length (size (value)) == 3)))
          error ("simByEuler: Z must be a three-dimensional array of real numbers or a function handle");
        endif
        Z = value;
        UserSpecifiedZ = true;
      case "StorePaths"
        if (! (isscalar (value) && islogical (value)))
          error ("simByEuler: StorePaths must be a scalar logical true or false");
        endif
        StorePaths = value;
      case "Processes"
        ProcessesIsCell = iscell (value);
        if (ProcessesIsCell)
          for j = 1:length (value)
            f = value{j};
            if (! isa (f, "function_handle"))
              error ("simByEuler: if specifying Processes as cell-array, each element must be a function handle");
            endif
          endfor
        elseif (! isa (value, "function_handle"))
          error ("simByEuler: Processes must be a function handle or cell-array of function handles.");
        endif
        Processes = value;
      case "Broadcast"
        if (! (isscalar (value) && islogical (value)))
          error ("simByEuler: Broadcast must be a scalar logical true or false");
        endif
        Broadcast = value;
      otherwise
        error ("simByEuler: unrecognized option %s", key);
    endswitch
  endfor

  ## Infer the size of NVARS and NBROWNS
  NVARS = size (SDE.StartState, 1);
  NBROWNS = size (SDE.Diffusion (0, ones (NVARS, 1)), 2);

  ## Error checking
  if (StorePaths)
    Paths = zeros (NPERIODS + 1, NVARS, NTRIALS);
  else
    Paths = zeros (0, 0, 0);
  endif

  ## Perform Cholesky factorization exactly once if possible
  ConstantCorrelation = false;
  if (! isa (SDE.Correlation, "function_handle"))
    L = chol (SDE.Correlation, "lower");
    ConstantCorrelation = true;
  endif

  ## Generate random samples
  if (UserSpecifiedZ)
    if (Antithetic)
      warning("simByEuler: Antithetic specified with Z; ignoring Antithetic");
    endif
  else
    ## Antithetic sampling
    if (Antithetic)
      ## Make sure NTRIALS is even
      NTRIALS += mod (NTRIALS, 2);
      tmp = randn (NPERIODS * NSTEPS, NBROWNS, NTRIALS / 2);
      Z(:, :, 1:2:NTRIALS) = tmp;
      Z(:, :, 2:2:NTRIALS) = -tmp;
    else
      Z = randn (NPERIODS * NSTEPS, NBROWNS, NTRIALS);
    endif
  endif

  ## Vector of times
  Times = zeros (NPERIODS + 1, 1);
  Times(1) = SDE.StartTime;
  for p = 1:NPERIODS
    Times(p+1) = Times(p) + DeltaTime(p);
  endfor

  ## Make StartState NVARS-by-NTRIALS matrix
  if (isscalar (SDE.StartState))
    StartState = ones (NVARS, NTRIALS) * SDE.StartState;
  elseif (iscolumn (SDE.StartState))
    StartState = zeros (NVARS, NTRIALS);
    for i = 1:NTRIALS
      StartState(:, i) = SDE.StartState;
    endfor
  else
    StartState = SDE.StartState;
  endif

  StateDimensions = [NVARS, 1, NTRIALS];
  BrownDimensions = [NVARS, NBROWNS, NTRIALS];
  TrialDimensions = [NBROWNS, NTRIALS];

  ## Check to see if we can use the fast broadcasting implementation
  X = zeros (StateDimensions);

  BroadcastDrift = true;
  try
    BroadcastDrift = isequal (size (SDE.Drift (0., X)), StateDimensions);
  catch exception
    BroadcastDrift = false;
  end_try_catch
  if (! BroadcastDrift && NTRIALS > 1)
    warning ("simByEuler: SDE.Drift cannot be used with fast broadcasting implementation");
  endif

  BroadcastDiffusion = true;
  try
    BroadcastDiffusion = isequal (size (SDE.Diffusion (0., X)), BrownDimensions);
  catch exception
    BroadcastDiffusion = false;
  end_try_catch
  if (! BroadcastDiffusion && NTRIALS > 1)
    warning ("simByEuler: SDE.Diffusion cannot be used with fast broadcasting implementation");
  endif

  BroadcastZ = true;
  try
    if (! ConstantZ)
      BroadcastZ = isequal (size (Z (0., X)), TrialDimensions);
    endif
  catch exception
    BroadcastZ = false;
  end_try_catch
  if (! BroadcastZ && NTRIALS > 1)
    warning ("simByEuler: Z cannot be used with fast broadcasting implementation");
  endif

  BroadcastProcesses = true;
  try
    if (ProcessesIsCell)
      for j = 1:length (Processes)
        f = Processes{j};
        if (! isequal (size (f (0., X)), StateDimensions))
          BroadcastProcesses = false;
        endif
      endfor
    else
      if (! isequal (size (Processes (0., X)), StateDimensions))
        BroadcastProcesses = false;
      endif
    endif
  catch exception
    BroadcastProcesses = false;
  end_try_catch
  if (! BroadcastProcesses && NTRIALS > 1)
    warning ("simByEuler: Processes cannot be used with fast broadcasting implementation");
  endif

  Broadcast = Broadcast && BroadcastDrift && BroadcastDiffusion && BroadcastZ && BroadcastProcesses;

  if (! Broadcast && NTRIALS > 1)
    warning ("simByEuler: fast broadcasting disabled; may be slow");
  endif

  if (Broadcast)
    NOUTER = 1;
  else
    NOUTER = NTRIALS;
  endif

  if (StorePaths)
    Paths(1, :, :) = StartState;
  endif

  for i = 1:NOUTER

    if (Broadcast)
      X = reshape (StartState, StateDimensions);
    else
      X = StartState(:, i);
    endif

    t = SDE.StartTime;

    for p = 1:NPERIODS

      dt = DeltaTime(p);
      subdt = dt/NSTEPS;
      sqrt_subdt = sqrt (subdt);

      if (Broadcast)

        for n = 1:NSTEPS

          tnow = t + subdt * (n-1);

          if (! ConstantCorrelation)
            L = chol (SDE.Correlation (tnow), "lower");
          endif

          if (! ConstantZ)
            phi = Z (tnow, X);
          else
            phi = reshape (Z((p-1)*NSTEPS + n, :, :), TrialDimensions);
          endif

          ## Fast matrix-vector multiply over multiple slices
          v0 = sum (bsxfun (@times, L * sqrt_subdt, permute (phi, [3, 1, 2])), 2);
          v1 = reshape (v0, TrialDimensions);
          v2 = sum (bsxfun (@times, SDE.Diffusion (tnow, X), permute (v1,  [3, 1, 2])), 2);

          X += SDE.Drift (tnow, X) * subdt + v2;

        endfor

      else

        for n = 1:NSTEPS

          tnow = t + subdt * (n-1);

          if (! ConstantCorrelation)
            L = chol (SDE.Correlation (tnow), "lower");
          endif

          if (! ConstantZ)
            phi = Z (tnow, X);
          else
            phi = reshape (Z((p-1)*NSTEPS + n, :, i), [NBROWNS, 1]);
          endif

          X += SDE.Drift (tnow, X) * subdt ...
               + SDE.Diffusion (tnow, X) * (L * phi) * sqrt_subdt;

        endfor

      endif

      t = Times(p+1);
      if (ProcessesIsCell)
        for j = 1:length (Processes)
          f = Processes{j};
          X = f (t, X);
        endfor
      else
        X = Processes (t, X);
      endif

      if (StorePaths)
        if (Broadcast)
          Paths(p+1, :, :) = X(:, 1, :);
        else
          Paths(p+1, :, i) = X;
        endif
      endif

    endfor

  endfor

endfunction

## Basket call test
%!test
%! Asset1Price = 40.; Asset2Price = 40.; Strike = 40.; RiskFreeRate = 0.05; Volatility1 = 0.5; Volatility2 = 0.5; ExpiryTime = 0.25; Correlation = 0.3;
%! Simulations = 1e5; Timesteps = 10;
%! Drift     = drift ([0.;0.], [RiskFreeRate 0.;0. RiskFreeRate]);
%! Diffusion = diffusion ([1.;1.], [Volatility1 0.;0. Volatility2]);
%! SDE = sde (Drift, Diffusion, "StartState", [Asset1Price;Asset2Price], "Correlation", [1 Correlation;Correlation 1]);
%! [Paths, ~, ~] = simulate (SDE, 1, "DeltaTime", ExpiryTime, "NTRIALS", Simulations, "NSTEPS", Timesteps, "Antithetic", true);
%! BasketCallApproximate = exp (-RiskFreeRate * ExpiryTime) * mean (max (max (Paths(end, :, :)) - Strike, 0.));
%! BasketCall = 6.8477; ## Computed using formula from Stulz (1982)
%! assert (BasketCallApproximate, BasketCall, 1e-1);

## Confidence interval and options pricing tests
%!test
%! AssetPrice = 100.; RiskFreeRate = 0.04; Dividends = 0.01; Volatility = 0.2; ExpiryTime = 1.;
%! Simulations = 1e6; Timesteps = 10;
%! Drift = drift (0., RiskFreeRate - Dividends);
%! Diffusion = diffusion (1., Volatility);
%! SDE = sde (Drift, Diffusion, "StartState", AssetPrice);
%! [Paths, ~, ~] = simByEuler (SDE, 1, "DeltaTime", ExpiryTime, "NTRIALS", Simulations, "NSTEPS", Timesteps, "Antithetic", true);
%! AssetExpiryMean = AssetPrice * exp ((RiskFreeRate - Dividends) * ExpiryTime);
%! AssetExpiryMeanApproximate = mean (Paths(end, 1, :));
%! AssetExpiryVariance = AssetPrice * AssetPrice * exp (2 * (RiskFreeRate - Dividends) * ExpiryTime) * (exp (Volatility * Volatility * ExpiryTime) - 1);
%! ConfidenceInterval = 0.01;
%! tol = norminv(1 - ConfidenceInterval/2) * sqrt (AssetExpiryVariance / Simulations);
%! assert (AssetExpiryMeanApproximate, AssetExpiryMean, tol)
%! Strike = 100.;
%! CallApproximate = exp (-RiskFreeRate * ExpiryTime) * mean (max (Paths(end, 1, :) - Strike, 0.));
%! [Call, ~] = blsprice (AssetPrice, Strike, RiskFreeRate, ExpiryTime, Volatility, Dividends);
%! assert (CallApproximate, Call, 1e-1);

## Test input validation
%!error simByEuler()
%!error simByEuler(1)
%!error simByEuler("invalid type", 1)
