## Copyright (C) 2022 The Octave Project Developers
##
## This program is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program.  If not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {}  {@var{lat2} =} meridianfwd (@var{lat}, @var{s})
## @deftypefnx {} {@var{lat2} =} meridianfwd (@var{lat}, @var{s}, @var{spheroid})
## @deftypefnx {} {@var{lat2} =} meridianfwd (@var{lat}, @var{s}, @var{spheroid}, @var{angleUnit})
## Retuns the new latitude given a starting latitude and distance travelled
## along a meridian.
##
## Inputs
##
## @itemize
## @item
## @var{lat1}: the starting latitude.
##
## @item
## @var{s} the distance travelled.  The units are based on the ellipsoid.
## The default is in meters but should match that of the ellipsoid (if any).
##
## @item
## (optional) @var{spheroid}: referenceEllipsoid (parameter struct, name or
## code): the default is 'wgs84'.
##
## @item
## (optional) @var{angleUnit}: string for angular units ('degrees' or 'radians',
## case-insensitive, just the first character will do). Default is 'radians'.
##
## Output
## @item
## @var{lat2}: the final latitude after travelling a distance of @var{s}
## @end itemize
##
## Example
## @example
## lat = meridianfwd (40, 1e6)
## lat =  48.983
## @end example
##
## @seealso{meridianarc, geodeticfwd}
## @end deftypefn

function [lat2] = meridianfwd (lat, s, spheroid = "wgs84", angleUnit = "radians")

  if (nargin < 2 || nargin > 4)
    print_usage();
  endif

  lat2 = geodeticfwd (lat, 0, s, 0, spheroid, angleUnit, "length");

endfunction


%!test
%! a = rad2deg (meridianfwd (-pi/4, [60 120] * 45 * 1846.2756967249574, 'wgs84'));
%! assert (a, [0, 45], 5e-7);

