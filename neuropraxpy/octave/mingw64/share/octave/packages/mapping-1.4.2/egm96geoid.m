## Copyright (C) 2022 Philip Nienhuis
##
## This program is free software: you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation, either version 3 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program.  If not, see <https://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {} {@var{hgt} =} egm96geoid (@var{lat}, @var{lon})
## @deftypefnx {} {@var{hgt} =} egm96geoid (@var{lat}, @var{lon}, @var{method})
## @deftypefnx {} {@var{hgt} =} egm96geoid ()
## @deftypefnx {} {@var{hgt} =} egm96geoid (@var{samplefactor})
## Return local height of EGM96 geoid relative to WGS84 geoid in meters.
##
## The input values @var{lat}, @var{lon} are in (decimal) degrees.  Scalar
## values as well as vectors/2D arrays are accepted are accepted, in the
## latter case the dimensions of @var{lon} and @var{lat} should match.  They
## are wrapped in the latitude = [-90:90] and longitude [-180:180] intervals.
##
## The optional third input @var{method} defines the interpolation method
## and can be one of the following: "nearest" (default), "linear",
## "pchip"/"cubic" (same ), or "spline".  When "spline" is specified the
## latitude and longitude data should be either scalars or vectors of
## uniform spacing in 'meshgrid' format and orientation.
##
## Alternatively, egm96geoid can return the base grid or a sampled base
## grid.  If called without input argument, the entire 721x1441 base grid
## is returned.  If just one input argument is specified it must be a
## positive integer value which is then interpreted as a sampling factor:
## the grid is returned but sampled starting at (1,1) with values at
## (1:<samplefactor>:end).  Positions (1, 1), (721, 1), (1441, 1) and
## (721, 721) of the base grid correspond to (Lon, Lat) = (0, 90),
## (180, 90), (360, 90) = (0, 90), and (180, -90), respectively.
##
## @var{hgt}, the egm96geoid output value(s), are in meters relative to
## the WGS84 standard ellipsoid.
##
## @example
## h = egm96geoid (-20.05, 59.81)
##  ==>
##  ans = 60.614
## @end example
##
## The geoid elevation data are based on interpolation using a 15' x 15' grid
## obtained from:
## https://www.usna.edu/Users/oceano/pguth/md_help/html/egm96.htm
## As a consequence the accuracy is highly dependent on the input latitude:
## near the equator, interpolation is based on a 27.76 x 27.76 km square grid,
## while near the poles the grid cells are effectively more needle-like
## triangles with a base of merely 121 m and a height of 27.76 km.
##
## @seealso{interp2, referenceEllipsoid}
## @end deftypefn

## Author: Philip Nienhuis <prnienhuis at users.sf.net>
## Created: 2020-04-13

function hg = egm96geoid (lat, lon=[], method="nearest")

  persistent egm96 = [];

  ## Input validation
  if (nargin > 3)
    print_usage ();
  elseif (nargin >= 1 &&
          ! (isnumeric (lat) && isreal (lat) && isnumeric (lon) && isreal (lon)))
    error ("egm96geoid: numeric real values expected for latitude and longitude");
  elseif (! ischar (method))
    error ("egm96geoid: name of interpolation method expected");
  elseif (nargin >= 2 && ...
        ! all (size (lon) == size (lat)) && ! strcmpi (method, "spline"))
    error ("em96geoid: latitudes and longitudes dimensions mismatch (%s)", ...
          sprintf ("%dx%d vs %dx%d", size (lon), size (lat)));
  endif
  ## Issues with interpolation methods are left to interp2.m

  if (isempty (egm96))
    load (strrep (which ("egm96geoid"), "egm96geoid.m", "data/egm96geoid.mat"));
  endif

  ## If no, or just one input arg given, return base grid.
  if (nargin == 0)
    ## Return entire grid
    hg = egm96;
    return
  elseif (nargin == 1)
    ## Return sampled grid
    if (lat < 1 || lat > 360)
      print_usage ();
    endif
    hg = egm96(1:lat:end, 1:lat:end);
    return
  endif

  ## Wrap coordinates into range [-180:180, -90:90]
  lat = wrapTo180 (2 * lat) / 2;
  lon = wrapTo360 (lon);

  ## Interpolate on 0.25 x 0.25 degrees grid. The egm96 data is organized
  ## as a 721x1441 grid with item (1, 1) at [Lon=-180, Lat=-90) and item
  ## (361, 721) at [Lat=180, Lon=90].
  hg = interp2 (0:0.25:360, 90:-0.25:-90, egm96, lon, lat, method);

endfunction


%!test ## Check for heights of some global extreme regions
%! assert (egm96geoid ([20, 50, 60, 10, -5], [-120, -50, -20, 75, 140]), ...
%!         [-47.576, 24.159,60.658, -97.286, 75.784], 1e-2);

%!error <numeric> egm96geoid ("a", 1)
%!error <numeric> egm96geoid (2.5i, 1)
%!error <usage> egm96geoid (-1)
%!error <dimensions mismatch> egm96geoid (1, [3 4])
%!error <name of interpolation> egm96geoid (1, 1, 2)

