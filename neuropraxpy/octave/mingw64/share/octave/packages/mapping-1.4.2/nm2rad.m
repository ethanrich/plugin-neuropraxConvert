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
## @deftypefn  {Function File} {@var{rad} =} nm2rad (@var{nm})
## @deftypefnx {Function File} {@var{rad} =} nm2rad (@var{nm}, @var{radius})
## @deftypefnx {Function File} {@var{rad} =} nm2rad (@var{nm}, @var{sphere})
## Converts distance to angle by dividing distance by radius.
##
## Calculates the angles @var{rad} for the distances @var{nm} in a sphere with
## @var{radius} (also in nautical miles).  If unspecified, radius defaults to 6371 km,
## the mean radius of Earth and is converted to nautical miles internally.
##
## Alternatively, @var{sphere} can be one of "sun", "mercury", "venus", "earth",
## "moon", "mars", "jupiter", "saturn", "uranus", "neptune", or "pluto", in
## which case radius will be set to that object mean radius.
##
## @seealso{km2rad}
## @end deftypefn

## Author: Pooja Rao <poojarao12@gmail.com>

function rad = nm2rad (nm, radius = "earth")
  ## This function converts nautical miles (nm) to radians (rad)
  
  ## Check arguments
  if (nargin < 1 || nargin > 2)
    print_usage();
  elseif (ischar (radius))
    ## Get radius of sphere and convert its default units (km)
    ## to nautical miles (nm)
    radius = km2nm (spheres_radius (radius));
  ## Check input
  elseif (! isnumeric (radius) || ! isscalar (radius))
    error ("nm2rad: RADIUS must be a numeric scalar");
  endif
  rad = nm/radius;

endfunction

%!test
%! ratio = unitsratio ('km','nm');
%! assert (nm2rad (10), km2rad (ratio*10), 10*eps);
%! assert (nm2rad (10, 80), km2rad (ratio*10, ratio*80), 10*eps);
%! assert (nm2rad (10, "pluto"), km2rad (ratio*10, "pluto"), 10*eps);

