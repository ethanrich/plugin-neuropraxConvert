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

function DiffusionRate = subsasgn (DiffusionRate, idx, value)

  if (! isa (DiffusionRate, "diffusion"))
    error ("object must be of the diffusion class but '%s' was used", class (DiffusionRate));
  elseif (! strcmp (idx(1).type, ".") || numel (idx) > 1)
    error ("incorrect syntax to reference diffusion object. Use obj.prop to access properties.");
  endif

  if (DiffusionRate.IsAlphaConstant)
    Alpha = DiffusionRate.Alpha (0., 0.);
  else
    Alpha = DiffusionRate.Alpha;
  endif

  if (DiffusionRate.IsSigmaConstant)
    Sigma = DiffusionRate.Sigma (0., 0.);
  else
    Sigma = DiffusionRate.Sigma;
  endif

  switch (idx.subs)
    case "Alpha"
      DiffusionRate = diffusion (value, Sigma);
    case "Sigma"
      DiffusionRate = diffusion (Alpha, value);
    case "Rate"
      error ("diffusion: 'Rate' is private");
    otherwise
      error ("diffusion: unknown property '%s'", idx.subs);
  endswitch

endfunction
