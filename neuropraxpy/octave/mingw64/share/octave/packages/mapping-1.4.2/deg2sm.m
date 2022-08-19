## Copyright (C) 2013-2022 Alexander Barth
## Copyright (C) 2018-2022 Philip Nienhuis
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
## @deftypefn  {Function File} {@var{sm} =} deg2sm (@var{deg})
## @deftypefnx {Function File} {@var{sm} =} deg2sm (@var{deg}, @var{radius})
## @deftypefnx {Function File} {@var{sm} =} deg2sm (@var{deg}, @var{sphere})
## Converts angle n degrees to distance in statute miles by multiplying angle
## with radius.
##
## Calculates the distances @var{sm} in a sphere with @var{radius} (also in
## statute miles) for the angles @var{deg}.  If unspecified, radius defaults to
## 3958 sm, the mean radius of Earth.
##
## Alternatively, @var{sphere} can be one of "sun", "mercury", "venus", "earth",
## "moon", "mars", "jupiter", "saturn", "uranus", "neptune", or "pluto", in
## which case radius will be set to that object's mean radius.
##
## @seealso{deg2km, deg2nm, km2rad, km2deg,
## nm2deg, nm2rad, rad2km, rad2nm, rad2sm, sm2deg, sm2rad}
## @end deftypefn

## Built with insight from
## Author: Alexander Barth <barth.alexander@gmail.com>
## Adapted from deg2km.m by Anonymous contributor, see patch #9709

function sm = deg2sm (deg, radius = "earth")

  ## Check arguments
  if (nargin < 1 || nargin > 2)
    print_usage();
  elseif (ischar (radius))
    ## Get radius of sphere with its default units (km)
    radius = km2sm (spheres_radius (radius));
  ## Check input
  elseif (! isnumeric (radius) || ! isreal (radius))
    error ("deg2sm: RADIUS must be a numeric scalar");
  endif
  sm = (deg2rad (deg) * radius);

endfunction


%!test
%!assert (sm2deg (deg2sm (10)), 10, 10*eps);
%!assert (sm2deg (deg2sm (10, 80), 80), 10, 10*eps);
%!assert (sm2deg (deg2sm (10, "pluto"), "pluto"), 10, 10*eps);

%!error <RADIUS> deg2sm (5, 5i)
