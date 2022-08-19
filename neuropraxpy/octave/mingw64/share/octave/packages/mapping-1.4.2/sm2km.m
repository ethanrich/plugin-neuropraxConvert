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
## @deftypefn {Function File} {} sm2km (@var{sm})
## Convert U.S. survey miles (statute miles) into kilometers.
##
## @seealso{km2nm, km2sm, nm2km, nm2sm, sm2nm}
## @end deftypefn

## Author: Eugenio Gianniti <eugenio.gianniti@mail.polimi.it>

function km = sm2km (sm)
  if (nargin != 1)
    print_usage ();
  endif
  persistent ratio = unitsratio ("kilometer", "U.S. survey mile (statute mile)");
  km = sm * ratio;
endfunction

%!test
%! km = [2 6336 4.8326 6.437388874777749];
%! sm = [1.242739898989899 3937 3.002832417929293 4];
%! assert (sm2km (sm), km)
%! km = reshape (km, [1 2 2]);
%! sm = reshape (sm, [1 2 2]);
%! assert (sm2km (sm), km)

%!assert (sm2km (3937), 6336)
