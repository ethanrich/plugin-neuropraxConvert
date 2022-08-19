## Copyright (C) 2021-2022 Philip Nienhuis <prnienhuis at users.sf.net>
## Copyright (C) 2014-2022 Alfredo Foltran <alfoltran at gmail.com>
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
## along with Octave; see the file COPYING.  If not, see
## <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} {[@var{lato}, @var{lono}, @var{azo}] = } {geodeticfwd(@var{lat}, @var{lon}, @var{range}, @var{azi})}
## @deftypefnx {Function File} {[@var{lato}, @var{lono}, @var{azo}] = } {geodeticfwd(@var{lat}, @var{lon}, @var{range}, @var{azi}, @var{dim})}
## @deftypefnx {Function File} {[@var{lato}, @var{lono}, @var{azo}] = } {geodeticfwd(@var{lat}, @var{lon}, @var{range}, @var{azi}, @var{angleUnit})}
## @deftypefnx {Function File} {[@var{lato}, @var{lono}, @var{azo}] = } {geodeticfwd(@var{lat}, @var{lon}, @var{range}, @var{azi}, @var{ellipsoid})}
## @deftypefnx {Function File} {[@var{lato}, @var{lono}, @var{azo}] = } {geodeticfwd(@var{lat}, @var{lon}, @var{range}, @var{azi}, @var{dim}, @var{angleUnit}, @var{ellipsoid})}
## Compute the coordinates of the end-point of a displacement along a geodesic.
##
## Inputs:
##
## @itemize
## @item
## @var{lat}, @var{lon}: coordinates (latitude, longitude) of the starting point.
##
## @item
## @var{range}: displacement along a specified geodesic (angle or length).
##
## @item
## @var{azi}: direction of the displacement relative (clockwise) to the North.
##
## @indent
## All these inputs can be scalars, vectors or 2D/ND arrays. If any input is
## a vector or 2D or ND array, all other inputs MUST be either scalars, OR
## vectors or arrays of the exact same size, OR scalars.  Scalars will be
## automatically expanded to the size of the input vectors/arrays.
##
## The following optional arguments can be specified in any desired order:
## @end indent
##
## @item
## @var{dim}: (char, case-insensitive, can be shortened to just the first
## letter) unit of @var{range}: either "length" or "angle" (default).  The
## "length" unit is supposed to be "meters" but in case of a length input,
## one can also specify any length unit accepted by validateLengthUnit.
##
## @item
## @var{angleUnit}: angle unit for all input angles: "degrees" (default) or
## "radians" (case-insensitive, can be shortened to just the first letter).
##
## @item
## @var{ellipsoid}: reference ellipsoid.  Can be either an ellipsoid name,
## an ellipsoid code (entered as numerical or character string), of a vector
## of SemimajorAxis and Flattening.
## @end itemize
##
## Output arguments:
##
## @itemize
## @item
## @var{lato}, @var{lono}: computed latitude and longitude after displacement.
## For displacement inputs speciied as lengths, geodeticfwd needs to iterate
## to get a satisfactory solution.  If the maximum number number of iterations
## is exceeded a suitable warning is emitted and the related output(s) is/are
## set to NaN.
##
## @item
## @var{azo}: computed azimuth at (@var{lato}, @var{lono}).
## @end itemize
##
## geodeticfwd is based on vincentyDirect.m by Alfredo Foltran, in turn based
## on Vicenty.T (1975) "Direct and inverse solutions of geodesics on the
## ellipsoid with application of nested equations".
##
## @seealso{geodeticarc, meridianfwd, reckon, referenceEllipsoid,
##          validateLengthUnit, vincentyDirect}
## @end deftypefn

function [lato, lono, azo] = geodeticfwd (varargin)

  ## Basic input checks
  if (nargin < 4)
    error ("geodeticfwd: too few arguments");
  elseif (nargin > 7)
    error ("geodeticfwd: too many arguments");
  elseif (! (all (cellfun ("isnumeric", varargin(1:4))) && ...
                  cellfun ("isreal", varargin(1:4))))
    error ("geodeticfwd: all first 4 arguments should be real numeric");
  endif

  ## Check & process numeric input data sizes
  isv = ! cellfun ("isscalar", varargin(1:4));
  if (any (isv))
    ## Check dimensions
    cdim = cellfun (@(x) numel (size (x)), varargin(isv));
    if (any (diff (cdim)))
      error ("geodeticfwd: input arrays of different dimensions");
    endif
    for ii=1:cdim(1)
      if (any (diff (cellfun (@(x) size (x, ii), varargin(isv)))))
        error ("geodeticfwd: input arrays of different dimensions");
      endif
    endfor
    ## Expand any scalar args, if required
    jsv = find (! isv);
    for ii=1:numel (jsv)
      varargin{jsv(ii)} = varargin{jsv(ii)} * ones (size (varargin{find (isv)(1)}));
    endfor
  endif

  lat = varargin{1};
  lon = varargin{2};
  rng = varargin{3};
  azi = varargin{4};
  varargin(1:4) = [];

  ## Check & process optional inputs.
  ## First set provisional defaults
  dim = "angle";
  angleUnit = "degrees";
  ## Default ellipsoid = WGS84
  ellipsoid = referenceEllipsoid (7030);

  ## Keep track of presence of extra inputs
  i_length = i_angle = i_ell = false;
  for ii=1:numel (varargin)
    ## Only accept first mention of one extra input
    if (iscellstr (varargin(ii)))

      ## Check for angle units
      if (! i_angle)
        if (strncmpi (varargin{ii}, "degrees", numel (varargin{ii})))
          angleUnit = "degrees";
          i_angle = true;
          continue;
        elseif (strncmpi (varargin{ii}, "radians", numel (varargin{ii})))
          angleUnit = "radians";
          i_angle = true;
          continue;
        endif
      endif

      ## Check for length units (or angle)
      if (! i_length)
        if (strncmpi (varargin{ii}, "length", numel (varargin{ii})))
          dim = lengthUnit = "length";
          i_length = true;
          continue;
        elseif (strncmpi (varargin{ii}, "angle", numel (varargin{ii})))
          dim = "angle";
          i_length = true;
          continue;
        else
          try
            ## Try to convert rng to meters
            rng = rng * unitsratio ("m", varargin{ii});
            ## If control gets here, the length argument was a valid length unit
            dim = lengthUnit = "length";
            i_length = true;
            continue;
          catch
          end_try_catch
        endif
      endif

      ## Check reference ellipsoid
      if (! i_ell)
        try
          ellipsoid = referenceEllipsoid (varargin{ii});
          i_ell = true;
          continue;
        catch
        end_try_catch
      endif

      error ("geodeticfwd: input argument #%d not recognized", ii+4);

    elseif (cellfun ("isnumeric", varargin(ii)) && ! i_ell)
      if (isscalar (varargin{ii}))
        ## Assume it's a reference ellipsoid code
        ellipsoid = referenceEllipsoid (varargin{ii});
      elseif (isvector (varargin{ii}) && numel (varargin{ii}) == 2)
        ## Semimajoraxis and Flattening; compute Semiminoraxis
        ellipsoid.SemimajorAxis = a = varargin{ii}(1);
        ellipsoid.Flattening = b = varargin{ii}(2);
        ecc = flat2ecc (b);
        ellipsoid.SemiminorAxis = minaxis (a, ecc);
      else
        error ("geodeticfwd: invalid ellipsoid input (arg. #%d)", ii+4);
      endif
      i_ell = true;
      continue;

    elseif (isstruct (varargin{ii}) && ! i_ell)
      ## FIXME - check on proper ellipsoid struct
      ellipsoid = varargin{ii};
      if (! all (isfield (ellipsoid, {"SemimajorAxis", "SemiminorAxis", "Flattening"})))
        error ("geodeticfwd: invalid ellipsoid struct");
      endif
      continue;

    else
      ## Couldn't be recognized
      error ("geodeticfwd: input argument #%d not recognized", ii+4);
    endif
  endfor

  if (strcmpi (angleUnit, "degrees"))
    ## Rest of function based on radians
    lat = deg2rad (lat);
    lon = deg2rad (lon);
    azi = deg2rad (azi);
    ## If range was given as angle, convert it as well
    if  (strcmpi (dim, "angle"))
      rng = deg2rad (rng);
    endif
  endif

  ## Do the actual work. Based on Alfredo Foltran's vincentyDirect.m
  ## https://github.com/alfoltranteam/octave-map/blob/master/src/vincentyDirect.m
  ## (In turn based on Vicenty.T (1975) Direct and inverse solutions of
  ##  geodesics on the ellipsoid with application of nested equations)

  major = ellipsoid.SemimajorAxis;
  minor = ellipsoid.SemiminorAxis;
  f = ellipsoid.Flattening;

  iter_limit = 20;

  tanU1 = (1 - f) * tan (lat);
  U1 = atan (tanU1);
  sigma1 = atan2 (tanU1, cos (azi));
  cosU1 = cos (U1);
  sinAlpha = cosU1 .* sin (azi);
  cos2Alpha = (1 - sinAlpha) .* (1 + sinAlpha);
  u2 = cos2Alpha * (major ^ 2 - minor ^ 2) / minor ^ 2;

  A = 1 + u2 / 16384 .* (4096 + u2 .* (-768 + u2 .* (320 - 175 * u2)));
  B = u2 / 1024 .* (256 + u2 .* (-128 + u2 .* (74 - 47 * u2)));

  if (strcmpi (dim, "length"))
    ## Be sure all lengths are in meters
    if (isfield (ellipsoid, "LengthUnit") && ! isempty (ellipsoid.LengthUnit))
      rng   *= unitsratio ("meter", ellipsoid.LengthUnit);
      major *= unitsratio ("meter", ellipsoid.LengthUnit);
      minor *= unitsratio ("meter", ellipsoid.LengthUnit);
    else
      ## Maybe dimensionless as in Unit Sphere, or not given. Assume "meters"
    endif
    sigma = rng ./ (minor * A);
    lastSigma = sigma + 1;
    i = 0;
    ## Keep track of which sigmas have converged
    sgmit = true (size (sigma));
    ## Preallocate to avoid dimension changes
    lastSigma = doubleSigmaM = deltaSigma = zeros (size (sigma));
    do
      i++;
      lastSigma(sgmit) = sigma(sgmit);
      doubleSigmaM(sgmit) = 2 * sigma1(sgmit) + sigma(sgmit);
      deltaSigma(sgmit) = ...
         B(sgmit) .* sin (sigma(sgmit)) .* (cos (doubleSigmaM(sgmit)) + ...
         0.25 * B(sgmit) .* (cos (sigma(sgmit)) .* (-1 + 2 * cos (doubleSigmaM(sgmit)) .^ 2) ...
         - 1/6 .* B(sgmit) .* cos (doubleSigmaM(sgmit)) .* (-3 + 4 * sin (sigma(sgmit)) .^ 2) ...
         .* (-3 * 4 * cos (doubleSigmaM(sgmit)) .^ 2)));
      sigma(sgmit) = rng(sgmit) ./ (minor * A(sgmit)) + deltaSigma(sgmit);
      ## Which inputs haven't converged yet
      sgmit = abs (lastSigma - sigma) > 10e-12;
      ## printf ("%2d ", i, sgmit); printf ("\n");  ## Debug, remove when tested
    until (all (! sgmit) || i > iter_limit)
    if (i > iter_limit)
      warning ("Direct Vincenty's formulae failed to converge for some inputs!");
      sigma(sgmit) = NaN;
    endif
  elseif (strcmpi (dim, "angle"))
    sigma = rng;
  else
    error ("Parameter \"dim\" must be \"angle\", \"length\" or a valid length unit!");
  endif

  doubleSigmaM = 2 * sigma1 + sigma;
  sinU1 = sin (U1);
  lato = atan2 (sinU1 .* cos (sigma) + cosU1 .* sin (sigma) .* cos (azi), ...
                (1 - f) * sqrt (sinAlpha .^ 2 + (sinU1 .* sin (sigma) - ...
                cosU1 .* cos (sigma) .* cos (azi)) .^ 2));
  lambda = atan2 (sin (sigma) .* sin (azi), ...
                  cosU1 .* cos (sigma) - sinU1 .* sin (sigma) .* cos(azi));
  C = f/16 * cos2Alpha .* (4 + f * (4 - 3 * cos2Alpha));
  L = lambda - (1 - C) * f .* sinAlpha .* (sigma + C .* sin (sigma) .* ...
      (cos (doubleSigmaM) + C .* cos (sigma) .* (-1 + 2 * cos (doubleSigmaM) .^ 2)));
  lono = L + lon;
  lono = wrapToPi (lono);

  if (nargout () > 2)
    azo = atan2 (sinAlpha, -sinU1 .* sin (sigma) + cosU1 .* cos (sigma) .* cos (azi));
  else
    azo = [];
  endif

  if (strcmpi (angleUnit, "degrees"))
    lato = rad2deg (lato);
    lono = rad2deg (lono);
    azo = rad2deg (azo);
  endif

endfunction


%!error <too few arguments> geodeticfwd (1, 1, 1);
%!error <should be real numeric> geodeticfwd (1, 2, 'a', 4);
%!error <should be real numeric> geodeticfwd ({2}, 2, 'a', 4);
%!error <should be real numeric> geodeticfwd (1+2i, 2, 3, 4);
%!error <arrays of different dimensions> geodeticfwd ([1 2], [2; 1], 0, 0);
%!error <not recognized> geodeticfwd (1, 2, 3, 4, 'b');
%!error <not recognized> geodeticfwd (1, 2, 3, 4, 'm', 'b');
%!error <not recognized> geodeticfwd (1, 2, 3, 4, 'd', 'wgs84', 'f');
%!error <not recognized> geodeticfwd (1, 2, 3, 4, 'd', 'wgs84', {5});
%!error <invalid ellipsoid input> geodeticfwd (1,  2, 3, 4, [1, 2, 3]);
%!error <invalid ellipsoid struct> geodeticfwd (1,  2, 3, 4, struct ("a", "b"));
%!error <invalid ellipsoid> geodeticfwd (pi/4, -pi/4, pi/2, 10, 'nm', 'r', struct ("a", []));

%!test
%! [lato, lono, azo] = geodeticfwd (0, 0, pi, pi/4, 'a', 'Unit Sphere', 'r');
%! assert (rad2deg ([lato lono azo]), [0, 180, 135], 1e-10);

%!test
%! [lato, lono, azo] = geodeticfwd (0, 0, pi/2, pi/4, 'angle', 'Unit Sphere', 'radians');
%! assert (rad2deg ([lato lono azo]), [45, 90, 90], 1e-10);

%!test
%! [lato, lono, azo] = geodeticfwd (0, pi/4, pi/2, 3*pi/4, 'a', 'Unit Sphere', 'r');
%! assert (rad2deg ([lato lono azo]), [ -45, 135, 90], 1e-10);

%!test
%! [lato, lono, azo] = geodeticfwd (45, -45, 180, 90, 'Unit Sphere', 'd');
%! assert ([lato lono azo], [-45, 135, 90], 1e-10);


