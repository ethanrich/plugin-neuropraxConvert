## Copyright (C) 2014-2022 Pooja Rao <poojarao12@gmail.com>
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
## @deftypefn  {Function File} {@var{km} =} rad2km (@var{rad})
## @deftypefnx {Function File} {@var{km} =} rad2km (@var{rad}, @var{radius})
## @deftypefnx {Function File} {@var{km} =} rad2km (@var{rad}, @var{sphere})
## Converts angle to distance by multiplying angle with radius.
##
## Calculates the distances @var{km} in a sphere with @var{radius} (also in
## kilometers) for the angles @var{rad}.  If unspecified, radius defaults to
## 6371, the mean radius of Earth.
##
## Alternatively, @var{sphere} can be one of "sun", "mercury", "venus", "earth",
## "moon", "mars", "jupiter", "saturn", "uranus", "neptune", or "pluto", in
## which case radius will be set to that object mean radius.
##
## @seealso{deg2km, deg2sm, km2rad, km2deg,
## nm2deg, nm2rad, rad2km, rad2nm, rad2sm, sm2deg, sm2rad}
## @end deftypefn

## Author: Pooja Rao <poojarao12@gmail.com>

function km = rad2km (rad, radius = "earth")
  ## This function converts radians (rad) to kilometers (km)

  ## Check arguments
  if (nargin < 1 || nargin > 2)
    print_usage();
  elseif (ischar (radius))
    ## Get radius of sphere with its default units (km)
    radius = spheres_radius (radius);
  ## Check input
  elseif (! isnumeric (radius) || ! isscalar (radius))
    error ("rad2km: RADIUS must be a numeric scalar");
  endif
  km = (rad * radius) ;

endfunction


%!test
%!assert (km2rad (rad2km (10)), 10, 10*eps);
%!assert (km2rad (rad2km (10, 80), 80), 10, 10*eps);
%!assert (km2rad (rad2km (10, "pluto"), "pluto"), 10, 10*eps);
