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

function DriftRate = subsasgn (DriftRate, idx, value)

  if (! isa (DriftRate, "drift"))
    error ("object must be of the drift class but '%s' was used", class (DriftRate));
  elseif (! strcmp (idx(1).type, ".") || numel (idx) > 1)
    error ("incorrect syntax to reference drift object. Use obj.prop to access properties.");
  endif

  if (DriftRate.IsAConstant)
    A = DriftRate.A (0., 0.);
  else
    A = DriftRate.A;
  endif

  if (DriftRate.IsBConstant)
    B = DriftRate.B (0., 0.);
  else
    B = DriftRate.B;
  endif

  switch (idx.subs)
    case "A"
      DriftRate = drift (value, B);
    case "B"
      DriftRate = drift (A, value);
    case "Rate"
      error ("drift: 'Rate' is private");
    otherwise
      error ("drift: unknown property '%s'", idx.subs);
  endswitch

endfunction
