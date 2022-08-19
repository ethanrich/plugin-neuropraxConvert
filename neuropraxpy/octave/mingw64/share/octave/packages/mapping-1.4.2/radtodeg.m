## Copyright (C) 2014-2022 Carnë Draug <carandraug@octave.org>
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
## @deftypefn  {Function File} {} rad2deg (@var{anglin})
## @deftypefnx {Function File} {} radtodeg (@var{anglin})
## Converts angles input in radians to the equivalent in degrees.
##
## @seealso{deg2rad, unitsratio}
## @end deftypefn

function anglout = radtodeg (anglin)
  ## This function only exists for Matlab compatibility, but really,
  ## naming it rad2deg is much more standard (deg2km, ind2rgb, sub2ind)
  anglout = rad2deg (anglin);
endfunction

%!assert (radtodeg(pi),180,10*eps)
