## Copyright (C) 2015 Parsiad Azimzadeh <parsiad.azimzadeh@gmail.com>
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

function SDE = subsasgn (SDE, idx, value)

  if (! isa (SDE, "sde"))
    error ("object must be of the sde class but '%s' was used", class (SDE));
  elseif (! strcmp (idx(1).type, ".") || numel (idx) > 1)
    error ("incorrect syntax to reference sde object. Use obj.prop to access properties.");
  endif

  switch (idx.subs)
    case "Drift"
      SDE = sde (
        value, SDE.Diffusion,
        "StartTime", SDE.StartTime,
        "StartState", SDE.StartState,
        "Correlation", SDE.Correlation,
        "Simulation", SDE.Simulation
      );
    case "Diffusion"
      SDE = sde (
        SDE.Drift, value,
        "StartTime", SDE.StartTime,
        "StartState", SDE.StartState,
        "Correlation", SDE.Correlation,
        "Simulation", SDE.Simulation
      );
    case "StartTime"
      SDE = sde (
        SDE.Drift, SDE.Diffusion,
        "StartTime", value,
        "StartState", SDE.StartState,
        "Correlation", SDE.Correlation,
        "Simulation", SDE.Simulation
      );
    case "StartState"
      SDE = sde (
        SDE.Drift, SDE.Diffusion,
        "StartTime", SDE.StartTime,
        "StartState", value,
        "Correlation", SDE.Correlation,
        "Simulation", SDE.Simulation
      );
    case "Correlation"
      SDE = sde (
        SDE.Drift, SDE.Diffusion,
        "StartTime", SDE.StartTime,
        "StartState", SDE.StartState,
        "Correlation", value,
        "Simulation", SDE.Simulation
      );
    case "Simulation"
      SDE = sde (
        SDE.Drift, SDE.Diffusion,
        "StartTime", SDE.StartTime,
        "StartState", SDE.StartState,
        "Correlation", SDE.Correlation,
        "Simulation", value
      );
    otherwise
      error ("sde: unknown property '%s'", idx.subs);
  endswitch

endfunction
