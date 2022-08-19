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

function v = subsref (DiffusionRate, idx)

  if (! isa (DiffusionRate, "diffusion"))
    error ("object must be of the diffusion class but '%s' was used", class (DiffusionRate));
  elseif (! strcmp (idx(1).type, ".") || numel (idx) > 1)
    error ("incorrect syntax to reference diffusion object. Use obj.prop to access properties.");
  endif

  switch (idx.subs)
    case "Alpha"
      if (DiffusionRate.IsAlphaConstant)
        v = DiffusionRate.Alpha (0., 0.);
      else
        v = DiffusionRate.Alpha;
      endif
    case "Sigma"
      if (DiffusionRate.IsSigmaConstant)
        v = DiffusionRate.Sigma (0., 0.);
      else
        v = DiffusionRate.Sigma;
      endif
    case "Rate"
      v = DiffusionRate.Rate;
    otherwise
      error ("diffusion: unknown property '%s'", idx.subs);
  endswitch

endfunction
