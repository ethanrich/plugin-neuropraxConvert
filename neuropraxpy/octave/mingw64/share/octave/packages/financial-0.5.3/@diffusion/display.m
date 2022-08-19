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

function display (DiffusionRate)

  if (DiffusionRate.IsAlphaConstant)
    AlphaString = mat2str (DiffusionRate.Alpha (0., 0.));
  else
    AlphaString = func2str (DiffusionRate.Alpha);
  endif

  if (DiffusionRate.IsSigmaConstant)
    SigmaString = mat2str (DiffusionRate.Sigma (0., 0.));
  else
    SigmaString = func2str (DiffusionRate.Sigma);
  endif

  printf ("\n\
  Class DIFFUSION: Diffusion Rate Specification\n\
  ---------------------------------------------\n\
     Rate: %s\n\
    Alpha: %s\n\
    Sigma: %s\n\n",
          func2str (DiffusionRate.Rate), AlphaString, SigmaString);

endfunction
