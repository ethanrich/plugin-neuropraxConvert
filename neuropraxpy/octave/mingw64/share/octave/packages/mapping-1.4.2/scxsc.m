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
## @deftypefn  {} {@var{lat}, @var{lon} =} gcxgc (@var{lat1}, @var{lon1}, @var{r1}, @var{lat2}, @var{lon2}, @var{r2})
## @deftypefnx {} {@var{lat}, @var{lon} =} gcxgc (@dots{}, @var{angleUnit})
## @deftypefnx {} {@var{lat}, @var{lon}, @var{istn} =} gcxgc (@dots{})
## Determines the intersection points between two small circles.
##
## Input:
## @itemize
## @item
## @var{lat1}, @var{lon1}, @var{r1}: latitude, longitude, and range of
## small circle #1 in angular units.  These must be scalar values or vectors
## of equal length.
## @end item
##
## @item
## @var{lat2}, @var{lon2}, @var{r2}: latitude, longitude, and range of
## small circle #2 in the same angular units as small circle #1.  These must
## be scalar values or vectors of equal length.
## @end item
##
## @item
## @var{angleUnit}: string for angular units ('degrees' or 'radians',
## case-insensitive, just the first character will do).  Default is 'degrees'.
## @var{angleUnit} applies to all inputs and outputs.
## @end item
## @end itemize
##
## Outputs:
##
## @itemize
## @item
## @var{lat} and @var{lon} are both Nx2 vectors of latitude(s) and longitude(s)
## of the intersection point(s).  Circle pair(s) that have no intersection
## points or happen to lie on the same axis (identical or antipodal centers)
## NaN values are returned.
## @end item
##
## @item
## Optional third output @var{istn}, if present, turns off warnings for
## coinciding circles or no intersections.  It is an Nx1 vector indicating
## the intersection situation of each input pair of circles, with for each
## circle pair the values:
##
## @table @asis
## @item 0
## The pair of circles has two distinct intersection points.
##
## @item 1
## The circles have identical axis, so are either coinciding or don't have
## any intersection points.
##
## @item 2
## The pair of circles have just one common intersection point (tangent).
##
## @item 3
## The pair of circles are disjoint, have no intersection points.
## @end table
## @item
## @end itemize
##
## Example:
##
## @example
## lat1 = 37.67;
## lon1 = -90.2;
## rng1 = 1.79;
## lat2 = 36.11;
## lon2 = -90.95;
## rng2 = 2.42;
## [newlat, newlon] = scxsc (lat1, lon1, rng1, lat2, lon2, rng2)
## newlat =
##   36.964   38.260
## newlon =
##  -88.132  -92.343
## @end example
##
## Coinciding, tangent, non-intersecting and intersecting circles:
## @example
## [lat, lon, w] = scxsc (0, 0, 1, 0, [0, 2, 0, 2], [1, 1, 2, 1.5])
## lat =
##       NaN      NaN
##         0        0
##       NaN      NaN
##    0.7262  -0.7262
##
## lon =
##       NaN      NaN
##    1.0000   1.0000
##       NaN      NaN
##    0.6875   0.6875
##
## w =
##    3
##    2
##    1
##    0
## @end example
##
## @seealso{gcxgc, gcxsc, gc2sc}
## @end deftypefn

function [lat, lon, idl] = scxsc (varargin)

  if (nargin < 6)
    print_usage();
  elseif (nargin == 6)
    angleUnit = "degrees";
  else
    angleUnit = varargin{7};
  endif

  if (! (all (cellfun ("isnumeric", varargin(1:6)) && ...
         all (cellfun ("isreal", varargin(1:6))))))
     error ("scxsc: numeric values expected for first six inputs");
  endif
  isv = ! cellfun ("isscalar", varargin(1:6));
  if (any (isv))
    ## At least one of the location inputs is a vector. Check sizes
    numval = cellfun ("numel", varargin(isv));
    if (any (diff (numval)))
      error ("gcxgc: all vector inputs must have same lengths");
    endif
    nv = max (numval);
    ## Make sure all inputs are column vectors of same length
    for ii=1:6
      if (isv(ii))
        varargin(ii) = {varargin{ii}(:)};
      else
        varargin(ii) = {(repmat (varargin{ii}, nv, 1))};
      endif
    endfor
  else
    nv = 1;
  endif

  vect = [varargin{1:6}];
  irad = 0;

  if (! ischar (angleUnit))
    error ("scxsc: character value expected for 'angleUnit'");
  elseif (strncmpi (angleUnit, "degrees", min (length (angleUnit), 7)))
    ## Latitude must be within (-90, 90)
    if (any (abs (vect(:, [1 4])) >= 90))
      error ("scxsc: azimuth value(s) out of acceptable range [-90, 90]")
    elseif (any (vect(:, [3 6])) >= 90 || any (vect(:, [3 6])) <= 0)
      error ("scxsc: circle radii must lie in range [-90, 90]")
    endif
  elseif (strncmpi (angleUnit, "radians", min (length (angleUnit), 7)))
    ## Latitude must be within (-pi/2, pi/2) as azimuth isn't defined outside
    if (any (abs (vect(:, [1 4])) >= pi / 2))
       error("scxsc: azimuth value(s) out of acceptable range (-pi/2, pi/2)")
    elseif (any (vect(:, [3 6])) >= pi/2 || any (vect(:, [3 6])) <= 0)
      ## Analogously for circle radii
      error ("scxsc: circle radii must lie in range [0, 90]")
    endif
    irad = 1;
    vect = rad2deg (vect);
  else
    error ("scxsc: illegal input for 'angleUnit'");
  endif
  ## Make sure we feed reasonable longitude values ([0..360]) to the
  ## goniometric functions below
  vect(:, [2 5]) = wrapTo360 (vect(:, [2 5]));

  ## Explore spherical distances between circle centers.
  ## Use haversine formula for approx.distances < 25..50 degrees
  id = abs ((vect(:, 1) + 360) - (vect(:, 4) + 360)) > 25;
  id = id | abs ((vect(:, 2) + 180) - (vect(:, 5) + 180)) > 25;
  ## Plain spherical cosine formula
  sphd = NaN (nv, 1);
  sphd(id) = acosd (sind (vect(id, 1)) .* sind (vect(id, 4)) + ...
                    cosd (vect(id, 1)) .* cosd (vect(id, 4)) .* ...
                    cosd (vect(id, 2) - vect(id, 5)));
  ## Haversine formula
  sphd(! id) = 2 * asind (sqrt ( ...
                  (sind (abs (vect(! id, 1) - vect(! id, 4)) / 2)) .^ 2 + ...
                  cosd (vect(! id, 1)) .* cosd (vect(! id, 4)) .* ...
                  sind (abs (vect(! id, 2) - vect(! id, 5)) / 2) .^2));

  ## Init tracker for various reasons for issues with intersections
  idl = zeros (nv, 1);

  ## Find circle pairs that have no intersections. Case 1: sphd > sum of radii
  idl(sphd - (vect(:, 3) + vect(:, 6)) > 0) = 1;
  ## Find circle pairs that have no intersections. Case 2: one circle
  ## completely lying in the other w/o tangent points
  idl(vect(:, 3) - sphd > vect(:, 6)) = 1;
  idl(vect(:, 6) - sphd > vect(:, 3)) = 1;

  ## Find circle pairs with coinciding (or antipodal) centers ==>
  ## Some may have no intersections (one enclosed in the other)
  [alat, alon] = antipode (vect(:, 4), vect(:, 5));
  idlc = find ((abs (vect(:, 1) - vect (:, 4)) < 1e-13 & ...
                abs (vect(:, 2) - vect (:, 5)) < 1e-13) | ...
               (abs (vect(:, 1) - alat) < 1e-13 & ...
                abs (vect(:, 2) - alon) < 1e-13));
  idl(idlc) = 1;
  ## Some of these may have coinciding circles
  idlca = abs (vect(idlc, 3) - vect(idlc, 6)) < 2 * eps | ...
          abs (vect(idlc, 3) - 180 + vect(idlc, 6)) < 2 * eps;
  idl(idlc(idlca)) = 3;
  ## Set up pointer to valid pairs
  idv = idl < 1;

  ## Warning section, only  for non-intersecting or coinciding circle pairs
  if (nargout < 3)
    if (any (idlca))
      warning ("Octave:coinciding-small-circles", ...
          "scxsc: (some) circle pair(s) coincide.\n");
    endif
    if (any (idl == 1))
      warning ("Octave:no-intersecting-circles", ...
               "scxsc: one or more circle pair(s) do not intersect.\n");
    endif
  endif

  ## Initialize output
  [lat lon] = deal (zeros (nv, 2));
  ## Set lat/lon rows for coinciding and/or disjoint circles to NaN
  lat(! idv, :) = lon(! idv, :) = NaN;
  if (numel (find (idv)) < 1)
    ## No pair w/o issues => nothing more to do here
    return
  endif
  idv = find (idv);

  ## Get geocentric coordinates
  c1 = geoc2cart (vect(idv, 1), vect(idv, 2));
  c2 = geoc2cart (vect(idv, 4), vect(idv, 5));

  ## Algorithm insight comes from
  ## https://gis.stackexchange.com/questions/48937/calculating-intersection-of-two-circles

  q = dot (c1, c2, 2);
  q2 = q .^ 2;

  n = cross (c1, c2, 2);
  n2 = dot (n, n, 2);

  r1 = vect(idv, 3);
  r2 = vect(idv, 6);

  a = (cosd (r1) - q .* cosd (r2)) ./ (1 - q2);
  b = (cosd (r2) - q .* cosd (r1)) ./ (1 - q2);

  x0 = a .* c1 + b .* c2;
  x02 = dot (x0, x0, 2);
  ## Dot product cannot be larger than 1 here
  x02 = sign (x02) .* min (1, abs (x02));

  t = sqrt ((1 - x02) ./ n2);  # <=== No chance n2 can be zero? (div by zero !!!)
  p1 = x0 + (t .* n);
  p2 = x0 - (t .* n);

  lat(idv, 1) = atan2d (p1(:, 3), hypot (p1(:, 1), p1(:, 2)));
  lon(idv, 1) = atan2d (p1(:, 2), p1(:, 1));

  lat(idv, 2) = atan2d (p2(:, 3), hypot (p2(:, 1), p2 (:, 2)));
  lon(idv, 2) = atan2d (p2(:, 2), p2(:, 1));

  idl(abs (diff (lat'))' < 2e-5 & abs (diff (lon'))' < 2e-5) = 2;

  if (irad)
    lat = deg2rad (lat);
    lon = deg2rad (lon);
  endif

endfunction


## Compute geocentric from geodesic coordinates
function [c] = geoc2cart (lat, lon)

  c(:, 1) = cosd (lon) .* cosd (lat);
  c(:, 2) = sind (lon) .* cosd (lat);
  c(:, 3) = sind (lat);

endfunction


%!test
%! R1 = rad2deg (107.5 / earthRadius ("NM")); # Convert NM to deg
%! R2 = rad2deg (145 / earthRadius ("NM"));
%! [lat, lon, jj] = scxsc (37.673442, -90.234036, R1, 36.109997, -90.953669, R2);
%! assert (lat(1), 36.988778646, 1e-6);
%! assert (lon(1), -88.15335362, 1e-6);

%!test
%! [a, b, c] = gc2sc (45, [0:45:360], 45);
%! ## Correct a, must be 30 exactly degrees. reckon() is a bit inaccurate
%! a = -30 * ones (9, 1);
%! [d, e, f] = gc2sc (-45, -135, -45);
%! wst = warning ("off", "Octave:coinciding-small-circles", "local");
%! [g, h] = scxsc (a, b, c, d, e, f);
%! warning (wst.state, "Octave:coinciding-small-circles");
%! assert (g(2, 1), NaN);
%! assert ([g(9, 1) h(9, 1)], [-57.997936587 -102.76438968], 1e-6);

%!test
%! wst1 = warning ("off", "Octave:coinciding-small-circles", "local");
%! wst2 = warning ("off", "Octave:no-intersecting-circles", "local");
%! [~, ~, w] = scxsc (0, 0, 1, 0, [0, 2, 0, 2], [1, 1, 2, 1.5]);
%! warning (wst2.state, "Octave:no-intersecting-circles");
%! warning (wst1.state, "Octave:coinciding-small-circles");
%! assert (w, [3; 2; 1; 0], eps);

%test  #3 Disjoint circles
%!warning <one or more circle> scxsc (45, 90, 1, -30, 60, 1);
%!warning <one or more circle> scxsc (0, 0, 10, 0, 4, 2);
%!warning <one or more circle> scxsc (0, 4, 3, 0, 0, 10);

%!error <numeric> scxsc ("s", 0, 100, 10, 30, 0);
%!error <numeric> scxsc (3i, 0, 100, 10, 30, 0);
%!error <numeric> scxsc (50, "s", 100, 10, 30, 0);
%!error <numeric> scxsc (50, 2i, 10, 10, 30, 0);
%!error <numeric> scxsc (50, 0, "s", 10, 30, 0);
%!error <numeric> scxsc (50, 0, 100i, 10, 30, 0);
%!error <numeric> scxsc (50, 0, 100, "s", 30, 0);
%!error <numeric> scxsc (50, 0, 100, 10i, 30, 0);
%!error <numeric> scxsc (50, 0, 100, 10, "s", 0);
%!error <numeric> scxsc (50, 0, 100, 10, 30i, 0);
%!error <numeric> scxsc (50, 0, 100, 10, 30, "s");
%!error <numeric> scxsc (50, 0, 100, 10, 30, 2i);
%!error <illegal> scxsc (50, 0, 100, 10, 30, 0, "f");
%!error <illegal> scxsc (50, 0, 100, 10, 30, 0, "degreef");
%!error <azimuth value> scxsc (190, 0, 90, -90.000001, 180, 80);
%!error <azimuth value> scxsc (190, 0, -90.001, -90.000001, 180, 80);
%!error <azimuth value> scxsc (pi/1.999, 0, pi/2, pi/2.0001, 2, 2*pi/3, "r");
