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

function v = subsref (DriftRate, idx)

  if (! isa (DriftRate, "drift"))
    error ("object must be of the drift class but '%s' was used", class (DriftRate));
  elseif (! strcmp (idx(1).type, ".") || numel (idx) > 1)
    error ("incorrect syntax to reference drift object. Use obj.prop to access properties.");
  endif

  switch (idx.subs)
    case "A"
      if (DriftRate.IsAConstant)
        v = DriftRate.A (0., 0.);
      else
        v = DriftRate.A;
      endif
    case "B"
      if (DriftRate.IsBConstant)
        v = DriftRate.B (0., 0.);
      else
        v = DriftRate.B;
      endif
    case "Rate"
      v = DriftRate.Rate;
    otherwise
      error ("drift: unknown property '%s'", idx.subs);
  endswitch

endfunction
