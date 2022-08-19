## Copyright (C) 2014-2022 Alfredo Foltran <alfoltran@gmail.com>
## Copyright (C) 2021-2022 Philip Nienhuis <prnienhuis@users.sf.net>
##
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; if not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} {} @var{dist} = geodeticarc(@var{pt1}, @var{pt2})
## @deftypefnx {Function File} {} @var{dist} = geodeticarc(@var{pt1}, @var{pt2}, @var{ellipsoid})
## @deftypefnx {Function File} {[@var{dist}, @var{az}] = } {geodeticarc(@var{pt1}, @var{pt2})}
## @deftypefnx {Function File} {[@var{dist}, @var{az}] = } {geodeticarc(@var{pt1}, @var{pt2}, @var{ellipsoid})}
## Calculates the distance (in meters) between two (sets of) locations on
## an ellipsoid.
##
## The formula devised by Thaddeus Vincenty (1975) is used with an accurate
## ellipsoidal model of the earth (@var{ellipsoid}). @*
## Note: for antipodal points (within 0.5 degree) Vincenty's formulae are
## known to be inaccurate and may even break down.
##
## Inputs:
##
## @itemize
## @item
## @var{pt1} and @var{pt2} are two-column matrices of the form @*
## [latitude longitude].
## The units for the input coordinates angles must be degrees.
##
## @item
## Optional argument @var{ellipsoid} defines the reference ellipsoid to use.
## The default ellipsoidal model is 'WGS84', which is the globally most
## accurate model.
## @end itemize
##
## Outputs:
##
## @itemize
## @item
## @var{dist} is the computed distance between @var{pt1} and @var{pt2} in
## meters, computed along the shortest geodesic.
##
## @item
## @var{az} is a 2-column array of starting and ending azimuths of the
## geodesics in the direction from @var{pt1} to @var{pt2}, in degrees relative
## to the North (clockwise).
## @end itemize
##
## Examples:
## @example
## >> geodeticarc ([37, -76], [37, -9])
## ans = 5830081.06
## >> geodeticarc ([37, -76], [67, -76], referenceEllipsoid (7019))
## ans = 3337842.87
## @end example
##
## @seealso{distance, geodeticfwd, referenceEllipsoid, vincenty}
## @end deftypefn

function [dist, az] = geodeticarc (varargin)

  if (nargin < 2)
    error ("geodeticarc: too few arguments");
  elseif (! (all (cellfun ("isnumeric", varargin(1:2))) && ...
                  cellfun ("isreal", varargin(1:2))))
    error ("geodeticarc: first 2 arguments should be real numeric nx2 arrays");
  elseif (nargin == 2)
    ellipsoid = referenceEllipsoid ("wgs84");
  elseif (isstruct (varargin{3}))
    ellipsoid = varargin{3};
  elseif (isnumeric (varargin{3}) && numel (varargin{3}) == 2)
    ## Might be SemimajorAxis and Flattening
    ellipsoid.SemimajorAxis = varargin{3}(1);
    ellipsoid.Flattening    = varargin{3}(2);
    ecc = flat2ecc (varargin{3}(2));
    ellipsoid.SemiminorAxis = minaxis (varargin{3}(1), ecc);
  else
    ellipsoid = referenceEllipsoid (varargin{3});
  endif

  ## Check & process numeric input data sizes
  isnv = ! cellfun ("isvector", varargin(1:2));
  if (any (isnv))
    ## Check dimensions
    cdim = cellfun (@(x) numel (size (x)), varargin(isnv));
    if (any (cdim != 2))
      error ("geodeticarc: first 2 arguments should be real numeric nx2 arrays");
    endif
    ## Check for proper orientation and expand any scalar args, if required
    for ii=1:2
      vsz = size (varargin{ii});
      if (vsz(2) != 2)                ## orientation
        error ("geodeticarc: first 2 arguments should be real numeric nx2 arrays");
      else                            ## nr.of points
        npt(ii) = vsz(1);
      endif
    endfor
    if (any (npt > 1))
      if (any (npt == 1))
        varargin{npt == 1} = repmat (varargin{npt == 1}, npt(npt != 1), 1);
      elseif (! (npt(1) - npt(2) == 0))
        error (["geodeticarc: at least one of first 2 inputs must be a 1x2 vector\n" ...
                "              or both must have the same dimensions\n"]);
      endif
    endif
  elseif (! all (cellfun ("isrow", varargin(1:2))))
    error ("geodeticarc: first 2 arguments should be real numeric nx2 arrays");
  endif

  ## Do the actual work. Based on Alfredo Foltran's vincenty.m
  ## https://github.com/alfoltranteam/octave-map/blob/master/src/vincenty.m
  ## (In turn based on Vicenty.T (1975) Direct and inverse solutions of
  ##  geodesics on the ellipsoid with application of nested equations)

  major = ellipsoid.SemimajorAxis;
  minor = ellipsoid.SemiminorAxis;
  f = ellipsoid.Flattening;
  ## Avoid confusion of length units imposed by ellipsoid, standardize on meters
  if (isfield (ellipsoid, "LengthUnit") && ! isempty (ellipsoid.LengthUnit))
    major *= unitsratio ("meters", ellipsoid.LengthUnit);
    minor *= unitsratio ("meters", ellipsoid.LengthUnit);
  endif

  iter_limit = 20;

  pt1 = deg2rad (varargin{1});
  pt2 = deg2rad (varargin{2});

  [lat1 lng1] = deal (pt1(:, 1), pt1(:, 2));
  [lat2 lng2] = deal (pt2(:, 1), pt2(:, 2));

  delta_lng = lng2 - lng1;

  reduced_lat1 = atan ((1 - f) * tan (lat1));
  reduced_lat2 = atan ((1 - f) * tan (lat2));

  [sin_reduced1 cos_reduced1] = deal (sin (reduced_lat1), cos (reduced_lat1));
  [sin_reduced2 cos_reduced2] = deal (sin (reduced_lat2), cos (reduced_lat2));

  lambda_lng = delta_lng;
  lambda_prime = 2 * pi;

  i = 0;
  ## Keep track of which sigmas have converged
  lit = true (size (lambda_lng));
  dist = NaN (size (lambda_lng));
  ## Preallocate to avoid dimension changes avoid shadowing function "sigma"
  sin_sigma = cos_sigma = sin_alpha = cos_sq_alpha = cos2_sigma_m = C = ...
              gsigma = zeros (size (lambda_lng));
  do
    i++;
    [sin_lambda_lng cos_lambda_lng] = deal (sin (lambda_lng), cos (lambda_lng));
    sin_sigma(lit) = sqrt ((cos_reduced2(lit) .* sin_lambda_lng(lit)) .^ 2 + ...
                           (cos_reduced1(lit) .* sin_reduced2(lit) - ...
                            sin_reduced1(lit) .* cos_reduced2(lit) .* ...
                            cos_lambda_lng(lit)) .^ 2);

    dist(find (abs (sin_sigma < eps))) = 0;
    lit(find (abs (sin_sigma < eps))) = false;

    cos_sigma(lit) = (sin_reduced1(lit) .* sin_reduced2(lit) + ...
                      cos_reduced1(lit) .* cos_reduced2(lit) .* cos_lambda_lng(lit));
    gsigma(lit) = atan2 (sin_sigma(lit), cos_sigma(lit));
    sin_alpha(lit) = (cos_reduced1(lit) .* cos_reduced2(lit) .* ...
                      sin_lambda_lng(lit) ./ sin_sigma(lit));
    cos_sq_alpha(lit) = 1 - sin_alpha(lit) .^ 2;

    if (abs (cos_sq_alpha(lit) > eps))
      cos2_sigma_m(lit) = cos_sigma(lit) - 2 .* (sin_reduced1(lit) ...
                          .* sin_reduced2(lit) ./ cos_sq_alpha(lit));
    else
      cos2_sigma_m(lit) = 0.0;                       ## Equatorial line
    endif

    C(lit) = f / 16.0 * cos_sq_alpha(lit) .* (4 + f * (4 - 3 * cos_sq_alpha(lit)));

    lambda_prime = lambda_lng;
    lambda_lng(lit) = (delta_lng(lit) + (1 - C(lit)) * f .* sin_alpha(lit) .* (gsigma(lit) + ...
                  C(lit) .* sin_sigma(lit) .* (cos2_sigma_m(lit) + C(lit) .* cos_sigma(lit) .* ...
                  (-1 + 2 * cos2_sigma_m(lit) .^ 2))));
    ## Which inputs haven't converged yet
    lit(lit) = abs (lambda_lng(lit) - lambda_prime(lit)) > 10e-12 | abs (sin_sigma(lit) < eps);
    ## printf ("%2d ", i, lit); printf ("\n");  ## Debug, remove when tested
  until (all (! lit) || i > iter_limit);

  if (i > iter_limit)
    warning ("Inverse vincenty's formulae failed to converge for some inputs!");
    sin_sigma(lit) = NaN;
  endif

  u_sq = cos_sq_alpha .* (major ^ 2 - minor ^ 2) / minor ^ 2;
  A = 1 + u_sq ./ 16384.0 .* (4096 + u_sq .* (-768 + u_sq .* (320 - 175 * u_sq)));
  B = u_sq ./ 1024.0 .* (256 + u_sq .* (-128 + u_sq .* (74 - 47 .* u_sq)));
  delta_sigma = (B .* sin_sigma .* (cos2_sigma_m + B / 4 .* (cos_sigma .* ...
                (-1 + 2 * cos2_sigma_m .^ 2) - B / 6 .* cos2_sigma_m .* ...
                (-3 + 4 * sin_sigma .^ 2) .* (-3 + 4 * cos2_sigma_m .^ 2))));
  dist(isnan (dist)) = (minor * A .* (gsigma - delta_sigma))(isnan (dist));

  if (nargout() > 1)
    alpha1 = atan2 (cos_reduced2 .* sin_lambda_lng, ...
                    cos_reduced1 .* sin_reduced2 - sin_reduced1 .* ...
                    cos_reduced2 .* cos_lambda_lng);
    alpha2 = atan2 (cos_reduced1 .* sin_lambda_lng, ...
                    -sin_reduced1 .* cos_reduced2 + cos_reduced1 .* ...
                    sin_reduced2 .* cos_lambda_lng);
    az = rad2deg ([alpha1 alpha2]);
  endif

endfunction


%!demo
%! lgts = geodeticarc ([[0:1:89]', zeros(90, 1)], [[1:1:90]', zeros(90, 1)]) / 60;
%! plot (0:89, lgts);
%! axis tight;
%! grid on;
%! hold on;
%! plot ([0 89], [1852 1852], "k", "linestyle", "-.");
%! plot ([45 45], [min(lgts) max(lgts)], "m", "linestyle", "-.");
%! title ("Arcminute length vs. Latitude");
%! xlabel ("Latitude (degrees)", "FontWeight", "bold");
%! ylabel ("Arcminute length (m)", "FontWeight", "bold");
%! text (5, 1852.5, "Nautical mile (1852 m)");


%!error <should be real numeric nx2> geodeticarc ("a", [0 0]);
%!error <should be real numeric nx2> geodeticarc ([0 0], [1; 1]);
%!error <should be real numeric nx2> geodeticarc ([0 0; 0 0; 0 0], [1; 1]);
%!error <should be real numeric nx2> geodeticarc ([1 2 3; 2 2 2], [0 0]);
%!error <at least one> geodeticarc ([1 3 2; 2 2 2]', [0 0; 5 6])

%!test
%! [dst, az] = geodeticarc ([37, -76], [37, -9; 67 -76; 37, -76]);
%! assert (dst, [5830081.06; 3337842.871; 0], 1e-2);
%! assert (mean (az'), [90, 0, 0,], 1e-7);

