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
## @deftypefn  {Function File} {@var{deg} =} sm2deg (@var{sm})
## @deftypefnx {Function File} {@var{deg} =} sm2deg (@var{sm}, @var{radius})
## @deftypefnx {Function File} {@var{deg} =} sm2deg (@var{sm}, @var{sphere})
## Converts distance to angle by dividing distance by radius.
##
## Calculates the angles @var{deg} for the distances @var{sm} in a sphere with
## @var{radius} (also in statute miles).  If unspecified, radius defaults to 6371 km,
## the mean radius of Earth and is converted to statute miles internally.
##
## Alternatively, @var{sphere} can be one of "sun", "mercury", "venus", "earth",
## "moon", "mars", "jupiter", "saturn", "uranus", "neptune", or "pluto", in
## which case radius will be set to that object mean radius.
##
## @seealso{km2deg}
## @end deftypefn

## Author: Pooja Rao <poojarao12@gmail.com>

function deg = sm2deg (sm, radius = "earth")
  ## This function converts statute miles (sm) to degrees (deg)

  ## Check arguments
  if (nargin < 1 || nargin > 2)
    print_usage();
  elseif (ischar (radius))
    ## Get radius of sphere and convert its default units (km)
    ## to statute miles (sm)
    radius = km2sm (spheres_radius (radius));
  ## Check input
  elseif (! isnumeric (radius) || ! isscalar (radius))
    error ("sm2deg: RADIUS must be a numeric scalar");
  endif
  deg = 180 * sm/(pi*radius);

endfunction

%!test
%! ratio = unitsratio ('km','sm');
%! assert (sm2deg (10), km2deg (ratio*10), 10*eps);
%! assert (sm2deg (10, 80), km2deg (ratio*10, ratio*80), 10*eps);
%! assert (sm2deg (10, "pluto"), km2deg (ratio*10, "pluto"), 10*eps);

