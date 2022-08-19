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
## @deftypefn {Function File} {} nm2km (@var{nm})
## Convert nautical miles into kilometers.
##
## @seealso{km2nm, km2sm, nm2sm, sm2km, sm2nm}
## @end deftypefn

## Author: Eugenio Gianniti <eugenio.gianniti@mail.polimi.it>

function km = nm2km (nm)
  if (nargin != 1)
    print_usage ();
  endif
  persistent ratio = unitsratio ("kilometer", "nautical mile");
  km = nm * ratio;
endfunction

%!test
%! km = [10 13.000002880000002 14.9999962 17.000008 19 31.000072400000004];
%! nm = [5.399568034557235 7.01944 8.09935 9.179269978401727 10.259179265658746 16.7387];
%! assert (nm2km (nm), km)
%! km = reshape (km, [3 2 1]);
%! nm = reshape (nm, [3 2 1]);
%! assert (nm2km (nm), km)

%!assert (nm2km (8.09935), 14.9999962)
