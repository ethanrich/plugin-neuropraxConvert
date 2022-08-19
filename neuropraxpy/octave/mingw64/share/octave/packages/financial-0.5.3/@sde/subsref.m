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

function v = subsref (SDE, idx)

  if (! isa (SDE, "sde"))
    error ("object must be of the sde class but '%s' was used", class (SDE));
  elseif (! strcmp (idx(1).type, ".") || numel (idx) > 1)
    error ("incorrect syntax to reference sde object. Use obj.prop to access properties.");
  endif

  switch (idx.subs)
    case "Drift",       v = SDE.Drift;
    case "Diffusion",   v = SDE.Diffusion;
    case "StartTime",   v = SDE.StartTime;
    case "StartState",  v = SDE.StartState;
    case "Correlation", v = SDE.Correlation;
    case "Simulation",  v = SDE.Simulation;
    otherwise
      error ("sde: unknown property '%s'", idx.subs);
  endswitch

endfunction
