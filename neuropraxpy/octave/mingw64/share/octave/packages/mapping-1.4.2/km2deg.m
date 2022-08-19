## Copyright (C) 2008-2022 Alexander Barth <abarth93@users.sourceforge.net>
## Copyright (C) 2013-2022 Carnë Draug <carandraug@octave.org>
##
## This program is free software; you can redistribute it and/or modify it under
## the terms of the GNU General Public License as published by the Free Software
## Foundation; either version 3 of the License, or (at your option) any later
## version.
##
## This program is distributed in the hope that it will be useful, but WITHOUT
## ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
## FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
## details.
##
## You should have received a copy of the GNU General Public License along with
## this program; if not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn  {Function File} {@var{deg} =} km2deg (@var{km})
## @deftypefnx {Function File} {@var{deg} =} km2deg (@var{km}, @var{radius})
## @deftypefnx {Function File} {@var{deg} =} km2deg (@var{km}, @var{sphere})
## Convert distance to angle.
##
## Calculates the angles @var{deg} for the distances @var{km} in a sphere with
## @var{radius} (also in kilometers).  If unspecified, radius defaults to 6371,
## the mean radius of Earth.
##
## Alternatively, @var{sphere} can be one of "sun", "mercury", "venus", "earth",
## "moon", "mars", "jupiter", "saturn", "uranus", "neptune", or "pluto", in
## which case radius will be set to that object mean radius.
##
## @seealso{deg2km, deg2sm, km2rad, km2deg,
## nm2deg, nm2rad, rad2km, rad2nm, rad2sm, sm2deg, sm2rad}
## @end deftypefn

## Author: Alexander Barth <barth.alexander@gmail.com>

function deg = km2deg (km, radius = "earth")
  if (nargin < 1 || nargin > 2)
    print_usage();
  elseif (ischar (radius))
    ## Get radius of sphere with default units (km)
    radius = spheres_radius (radius);
  elseif (! isnumeric (radius) || ! isscalar (radius))
    error ("km2deg: RADIUS must be a numeric scalar");
  endif
  deg = 180 * km/(pi*radius);
endfunction

%!assert (deg2km (km2deg (10)), 10, 10*eps)
%!assert (deg2km (km2deg (10, 80), 80), 10, 10*eps)
%!assert (deg2km (km2deg (10, "pluto"), "pluto"), 10, 10*eps)
