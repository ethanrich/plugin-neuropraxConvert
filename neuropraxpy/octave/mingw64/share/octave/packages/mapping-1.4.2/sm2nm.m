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
## @deftypefn {Function File} {} sm2nm (@var{sm})
## Convert U.S. survey miles (statute miles) into nautical miles.
##
## @seealso{km2nm, km2sm, nm2km, nm2sm, sm2km}
## @end deftypefn

## Author: Eugenio Gianniti <eugenio.gianniti@mail.polimi.it>

function nm = sm2nm (sm)
  if (nargin != 1)
    print_usage ();
  endif
  persistent ratio = unitsratio ("nautical mile", "U.S. survey mile (statute mile)");
  nm = sm * ratio;
endfunction

%!test
%! nm = [50.292 100.584 25.146 10058.4];
%! sm = [57.875 115.75 28.9375 11575];
%! assert (sm2nm (sm), nm)
%! sm = reshape (sm, [2 2 1]);
%! nm = reshape (nm, [2 2 1]);
%! assert (sm2nm (sm), nm)

%!assert (sm2nm (28.9375), 25.146)
