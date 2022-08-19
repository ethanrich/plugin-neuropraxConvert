## Copyright (C) 2015 Carnë Draug <carandraug+dev@gmail.com>
##
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; if not, see <http://www.gnu.org/licenses/>.

function display (SDE)

  NVARS = size (SDE.StartState, 1);
  NBROWNS = size (SDE.Diffusion (0, ones (NVARS, 1)), 2);

  if (isa (SDE.Correlation, "function_handle"))
    CorrelationString = func2str (SDE.Correlation);
  else
    CorrelationString = mat2str (SDE.Correlation);
  endif

  printf ("\n\
  Class SDE: Stochastic Differential Equation\n\
  -------------------------------------------\n\
   Dimensions: State = %d, Brownian = %d\n\
  -------------------------------------------\n\
    StartTime: %f\n\
   StartState: %s\n\
  Correlation: %s\n\
        Drift: %s\n\
    Diffusion: %s\n\
   Simulation: %s\n\n",
          NVARS, NBROWNS,
          SDE.StartTime, mat2str (SDE.StartState), CorrelationString,
          func2str (SDE.Drift), func2str (SDE.Diffusion),
          func2str (SDE.Simulation));

endfunction
