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

function display (DriftRate)

  if (DriftRate.IsAConstant)
    AString = mat2str (DriftRate.A (0., 0.));
  else
    AString = func2str (DriftRate.A);
  endif

  if (DriftRate.IsBConstant)
    BString = mat2str (DriftRate.B (0., 0.));
  else
    BString = func2str (DriftRate.B);
  endif

  printf ("\n\
  Class DRIFT: Drift Rate Specification\n\
  -------------------------------------\n\
     Rate: %s\n\
        A: %s\n\
        B: %s\n\n",
          func2str (DriftRate.Rate), AString, BString);

endfunction
