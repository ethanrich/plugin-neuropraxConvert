## Copyright (C) 2014-2022 Eugenio Gianniti <eugenio.gianniti@mail.polimi.it>
##
## This program is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or (at
## your option) any later version.
##
## This program is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
## General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; see the file COPYING.  If not, see
## <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} {} km2nm (@var{km})
## Convert kilometers into nautical miles.
##
## @seealso{km2sm, nm2km, nm2sm, sm2km, sm2nm}
## @end deftypefn

## Author: Eugenio Gianniti <eugenio.gianniti@mail.polimi.it>

function nm = km2nm (km)
  if (nargin != 1)
    print_usage ();
  endif
  persistent ratio = unitsratio ("nautical mile", "kilometer");
  nm = km * ratio;
endfunction

%!test
%! km = [1.8520    3.7040    5.5560    7.4080    12.9640   14.8160];
%! nm = [1 2 3 4 7 8];
%! assert (km2nm (km), nm)
%! km = reshape (km, [1 3 2]);
%! nm = reshape (nm, [1 3 2]);
%! assert (km2nm (km), nm)

%!assert (km2nm (1.852), 1)
