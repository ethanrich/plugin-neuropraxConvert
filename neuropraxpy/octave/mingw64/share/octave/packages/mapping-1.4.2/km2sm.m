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
## @deftypefn {Function File} {} km2sm (@var{km})
## Convert kilometers into U.S. survey miles (statute miles).
##
## @seealso{km2nm, nm2km, nm2sm, sm2km, sm2nm}
## @end deftypefn

## Author: Eugenio Gianniti <eugenio.gianniti@mail.polimi.it>

function sm = km2sm (km)
  if (nargin != 1)
    print_usage ();
  endif
  persistent ratio = unitsratio ("U.S. survey mile (statute mile)", "kilometer");
  sm = km * ratio;
endfunction

%!test
%! km = [2 3.218694437388875 4.8326 6.437388874777749];
%! sm = [1.242739898989899 2 3.002832417929293 4];
%! assert (km2sm (km), sm)
%! km = reshape (km, [2 2]);
%! sm = reshape (sm, [2 2]);
%! assert (km2sm (km), sm)

%!assert (km2sm (4.8326), 3.002832417929293)
