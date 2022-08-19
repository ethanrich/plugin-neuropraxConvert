## Copyright (C) 2022 Philip Nienhuis
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
## @deftypefn  {} {@var{dist} =} departure (@var{long1}, @var{long2}, @var{lat})
## @deftypefnx {} {@var{dist} =} departure (@var{long1}, @var{long2}, @var{lat}, @var{spheroid})
## @deftypefnx {} {@var{dist} =} departure (@var{long1}, @var{long2}, @var{lat}, @var{angleUnit})
## @deftypefnx {} {@var{dist} =} departure (@var{long1}, @var{long2}, @var{lat}, @var{spheroid}, @var{angleUnit})
## Compute the distance between two longitudes at a given latitude.
##
## Inputs:
## @itemize
## @item
## @var{long1}, @var{long2}: the start and end meridians (longitudes), resp.,
## between which the departure distance is to be calculated (angle).  If
## non-scalars the dimensions of @var{long1} and @var{long2} should match.
##
## @item
## @var{lat}: the latitude (parallel) at which the departure distance is to
## be calculated (angle). Can be a scalar even if @var{long1} and @var{long2}
## are vectors or nD arrays, in this case all departures are computed at the
## same latitude.  However, if non-scalar its size should match those of
## @var{long1} and @var{long2} (i.e., for each [@var{long1}, @var{long2}]
## pair there should be a distinct @var{lat} value).
##
## @item
## @var{spheroid}: referenceEllipsoid parameter struct; default is wgs84.  A
## string value describing the spheroid or a numerical EPSG code is also
## accepted.
##
## @item
## @var{angleUnit}: string for angular units ('degrees' or 'radians',
## case-insensitive, just the first charachter will do).  Default is
## 'degrees'.  Is an ellipsoid is also specified @var{angleUnit} only
## applies to the input values, if not it applies to input and output values.
## @end itemize
##
## Output
## @itemize
## @item
## @var{dist}: Computed distance (angle).  If an ellipsoid is used the
## answer is in the units of the ellipsoid (length).
## @end itemize
##
## Examples
## @example
## dist = departure (60, 80, 50)
## dist =  12.856
##
## Including an ellipsoid
##
## E = wgs84Ellipsoid ("km");
## dist = departure (60, 80, 50, E)
## dist =  1433.9
## # In this case dist is returned in kilometers.
## # Call can also be e.g.,:
## # dist = departure (60, 80, 50, referenceEllipsoid ("wgs84", "km"))
## @end example
##
##
## @seealso{distance}
## @end deftypefn

## Information is based on
## https://astronavigationdemystified.com/2015/10/14/calculating-the-distance
## -between-meridians-of-longitude-along-a-parallel-of-latitude/

## Function contributed by anonymous contributor, see:
## https://savannah.gnu.org/patch/index.php?9913

function [dist] = departure (varargin)

  spheroid = "";
  angleUnit = "degrees";
  angck = 0;
  if (nargin < 3 || nargin > 5)
    print_usage();
  elseif (nargin == 4)
    if (isnumeric (varargin{4}))
      ## EPSG spheroid code
      spheroid = varargin{4};
    elseif (ischar (varargin{4}))
      if (! isempty (varargin{4}) && ismember (varargin{4}(1), {"r", "d"}))
        angleUnit = varargin{4};
        angck = 1; ## Dummy for when radians are used
      else
        spheroid = varargin{4};
      endif
    elseif (isstruct (varargin{4}))
      spheroid = varargin{4};
    else
      error ("departure: spheroid or angleUnit expected for arg. #4");
    endif
  elseif (nargin == 5)
    spheroid = varargin{4};
    angleUnit = varargin{5};
  endif
  if (isnumeric (spheroid))
    spheroid = num2str (spheroid);
  endif

  long1 = varargin{1};
  long2 = varargin{2};
  lat   = varargin{3};
  if (! isnumeric (long1)  || ! isreal (long1) || ...
      ! isnumeric (long2)  || ! isreal (long2) || ...
      ! isnumeric (lat)    || ! isreal (lat));
    error ("departure: numeric real values expected for first 3 inputs.")
  endif
  if (! all (size (long1) == size (long2)))
    error ("departure: non-matching dimensions of longitude inputs.");
  elseif (! isscalar (lat) && ! all (size (long1) == size (lat)))
    error ("departure: non-matching dimensions of longitude and latitude inputs.")
  endif

  if (! ischar (angleUnit) || ! ismember (lower (angleUnit(1)), {"d", "r"}))
    error ("departure: angleUnit should be one of 'degrees' or 'radians'")
  endif

  if (ismember (lower (angleUnit(1)), {"r"}))
    long1 = rad2deg (long1);
    long2 = rad2deg (long2);
    lat   = rad2deg (lat);
  endif

  delta = abs (long2 - long1);

  if (nargin == 3 || angck)
    dist = delta .* cosd (lat);
    if (ismember (lower (angleUnit(1)), {"r"}))
      dist = deg2rad (dist);
    endif
  else
    E = sph_chk (spheroid);

    ## To include spheroid use
    ## https://en.wikipedia.org/wiki/Longitude#Length_of_a_degree_of_longitude
    e2 = E.Eccentricity ^ 2;
    num = delta .* pi / 180 .* E.SemimajorAxis .* cosd (lat);
    dem = sqrt (1 - e2 .* sind (lat) ^ 2);
    dist = num ./ dem;
  endif

endfunction


%!test
%! dist = departure (60, 80, 50);
%! assert (dist, 12.856, 1e-3)
%! dist = departure (deg2rad (60), deg2rad (80), deg2rad (50), "radians");
%! assert (dist, deg2rad (12.856), 1e-3)

%!test
%! assert (departure (0, deg2rad (30), deg2rad (60), "wgs84", "r"), ...
%!         departure (0, 30, 60, "wgs84", "d"), 1e-10);

%!test
%! E = wgs84Ellipsoid ("km");
%! dist = departure (60, 80, 50, E);
%! assert (dist, 1433.915, 1e-3)

%!test
%! assert (departure ([20 25], [30 35], 40), [7.6604 7.6604], 1e-4);

%!test
%! assert (departure ([20 25], [30 35], [40 41]), [7.6604 7.5471], 1e-4);

%!error <numeric> departure ("s", 80, 50)
%!error <numeric> departure ( 5i, 80, 50)
%!error <numeric> departure ( 60, "s", 50)
%!error <numeric> departure ( 60, 5i, 50)
%!error <numeric> departure ( 60, 80, "s")
%!error <numeric> departure ( 60, 80, 5i)
%!error <non-matching> departure ([20 25], [30; 35], 40)
%!error <non-matching> departure ([20 25], [30 35], [40; 40])

