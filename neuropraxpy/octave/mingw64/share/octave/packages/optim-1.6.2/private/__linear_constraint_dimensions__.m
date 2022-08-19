## Copyright (C) 2010-2019 Olaf Till <i7tiol@t-online.de>
##
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; If not, see <http://www.gnu.org/licenses/>.

function f = __linear_constraint_dimensions__ (f, o)

  if (isempty (f.imc))
    f.imc = zeros (o.np, 0);
    f.ivc = zeros (0, 1);
  endif
  if (isempty (f.emc))
    f.emc = zeros (o.np, 0);
    f.evc = zeros (0, 1);
  endif
  [rm, cm] = size (f.imc);
  [rv, cv] = size (f.ivc);
  if (rm != o.np || cm != rv || cv != 1)
    error ("linear inequality constraints: wrong dimensions");
  endif
  [erm, ecm] = size (f.emc);
  [erv, ecv] = size (f.evc);
  if (erm != o.np || ecm != erv || ecv != 1)
    error ("linear equality constraints: wrong dimensions");
  endif

endfunction
