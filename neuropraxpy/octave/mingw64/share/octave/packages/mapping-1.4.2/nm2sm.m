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
## @deftypefn {Function File} {} nm2sm (@var{nm})
## Convert nautical miles into U.S. survey miles (statute miles).
##
## @seealso{km2nm, km2sm, nm2km, sm2km, sm2nm}
## @end deftypefn

## Author: Eugenio Gianniti <eugenio.gianniti@mail.polimi.it>

function sm = nm2sm (nm)
  if (nargin != 1)
    print_usage ();
  endif
  persistent ratio = unitsratio ("U.S. survey mile (statute mile)", "nautical mile");
  sm = nm * ratio;
endfunction

%!test
%! nm = [50292 50.292 100.584 25.146 10058.4 12.573];
%! sm = [57875 57.875 115.75 28.9375 11575 14.46875];
%! assert (nm2sm (nm), sm)
%! sm = reshape (sm, [2 1 3]);
%! nm = reshape (nm, [2 1 3]);
%! assert (nm2sm (nm), sm)

%!assert (nm2sm (50292), 57875)
