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
## @deftypefn  {Function File} {[@var{Paths}, @var{Times}, @var{Z}] =} simulate (@var{SDE}, @dots{})
## Simulates a stochastic differential equation (SDE).
##
## @itemize
## @item
## Variable: @var{SDE} An sde object.
## @end itemize
##
## This method passes any additional arguments to the simulation routine
## specified by the sde object.
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
## Below is an example simulating a two-dimensional process driven by two
## correlated Wiener processes:
##
## @example
## Asset1Price  = 100.; Asset2Price  = 90.  ;
## Volatility1  = 0.2 ; Volatility2  = 0.3  ;
## Dividends1   = 0.  ; Dividends2   = 0.005;
## RiskFreeRate = 0.04;
## Correlation  = 0.5;
## ExpiryTime   = 1.;
##
## Drift     = drift ([0;0], [RiskFreeRate-Dividends1 0;0 RiskFreeRate-Dividends2]);
## Diffusion = diffusion ([1;1], [Volatility1 0;0 Volatility2]);
##
## M = 1000; # Number of simulations
## N = 10;   # Number of timesteps
##
## SDE = sde (Drift, Diffusion, "StartState", [Asset1Price;Asset2Price], ...
##            "Correlation", [1 Correlation;Correlation 1]);
## [Paths, ~, ~] = simulate (SDE, 1, "DeltaTime", ExpiryTime, ...
##                           "NTRIALS", M, "NSTEPS", N);
## @end example
##
## @seealso{@@sde/simByEuler}
## @end deftypefn

function [Paths, Times, Z] = simulate (SDE, varargin)

  if (nargin < 1)
    print_usage();
  endif

  if (! isa (SDE, "sde"))
    error("simulate: first argument must be an sde object");
  endif

  [Paths, Times, Z] = SDE.Simulation (SDE, varargin{:});

endfunction

## Test input validation
%!error simulate ()
%!error simulate (1)
