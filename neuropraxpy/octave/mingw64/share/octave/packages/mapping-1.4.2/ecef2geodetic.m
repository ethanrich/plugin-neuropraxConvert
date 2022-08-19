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
## @deftypefn  {Function File} {@var{lat}, @var{lon}, @var{alt} =} ecef2geodetic (@var{spheroid}, @var{X}, @var{Y}, @var{Z})
## @deftypefnx  {Function File} {@var{lat}, @var{lon}, @var{alt} =} ecef2geodetic (@var{X}, @var{Y}, @var{Z})
## @deftypefnx  {Function File} {@var{lat}, @var{lon}, @var{alt} =} ecef2geodetic (@dots{}, @var{angleUnit})
## @deftypefnx  {Function File} {@var{lat}, @var{lon}, @var{alt} =} ecef2geodetic (@var{X}, @var{Y}, @var{Z}, @var{spheroid})
## Convert from Earth Centered Earth Fixed (ECEF) coordinates to geodetic
## coordinates.
##
## Inputs:
## @itemize
## @item
## @var{spheroid} can be a referenceEllipsoid name or struct (see help for
## referenceEllipsoid.m).  Unfortunately an EPSG number as first argument
## input as a numeric value cannot be accepted UNLESS ecef2geodetic is called
## with five (5) input arguments.  Rather input the number as a character string
## (between quotes).  If omitted or if an empty string or empty array ('[]')
## is supplied the WGS84 ellipsoid (EPSG 7030) will be selected.
##
## Inputting @var{spheroid} as 4th argument is accepted but not recommended;
## in that case the @var{lat} and @var{lon} outputs are returned in radians.
##
## @item
## @var{X}, @var{Y} and @var{Z} (length) are Earth-Centered Earth Fixed
## coordinates.  They can be scalars, vectors or matrices but they must all
## have the same size and dimensions.  Their length unit is that of the used
## reference ellipsoid, whose default is meters.
## @end itemize
##
## Outputs:
## @itemize
## @var{lat}, @var{lon}, @var{alt}: geodetic coordinates (angle, angle, length).
## The default output is in degrees unless @var{spheroid} is specified as 4th
## argument (see above), or if "radians" is specified for optional last
## argument @var{angleUnit}. The geodetic height's (@var{alt}) length unit
## equals that of the used reference ellipsoid, whose default is meters.  The
## size and dimension(s) of @var{lat}, @var{lon} and @var{alt} are the same
## as @var{X}, @var{Y} and @var{Z}.
##
## Note: height is relative to the reference ellipsoid, not the geoid.  Use
## e.g., egm96geoid to compute the height difference between the geoid and
## the WGS84 reference ellipsoid.
## @end itemize
##
## Example:
## @example
## Aalborg GPS Centre
## X =     3426949.39675307
## Y =     601195.852419885
## Z =     5327723.99358255
## lat = 57.02929569;
## lon = 9.950248114;
## h = 56.95; # meters
##
## >> [lat, lon, alt] = geodetic2ecef ("", X, Y, Z)
## lat = 57.029
## lon = 9.9502
## alt = 56.95
## @end example
##
## @seealso{geodetic2ecef, ecef2aer, ecef2enu, ecef2enuv,ecef2ned, ecef2nedv,
## egm96geoid, referenceEllipsoid}
## @end deftypefn

## Function supplied by anonymous contributor, see:
## https://savannah.gnu.org/patch/index.php?9658

function [lat, lon, alt] = ecef2geodetic (varargin)

  ## ip = XYZ offset into varargin
  ip = 0;
  spheroid = "";
  angleUnit = "degrees";
  if (nargin < 3 || nargin > 5)
    print_usage ();
  elseif (nargin == 3)
    ## Only XYZ input expected
    spheroid = "wgs84";
  elseif (nargin == 4)
    ## Sort out if arg.#1 or arg.#4 is a spheroid, or arg.#4 an angleUnit
    if (isstruct (varargin{1}) || ischar (varargin{1}))
      ## Assume arg #1 = spheroid
      spheroid = varargin{1};
      ip = 1;
    elseif (isstruct (varargin{4}))
      ## Assume arg #4 = spheroid
      spheroid = varargin{4};
    elseif (ischar (varargin{4}))
      if (ismember (varargin{4}(1), {"r", "d"}))
        ## Assume arg #4 = angleunit
        angleUnit = varargin{4};
        spheroid = "wgs84";
      else
        spheroid = varargin{4};
      endif
    endif
  elseif (nargin == 5)
    ip = 1;
    spheroid = varargin{1};
    if (isnumeric (spheroid))
      spheroid = num2str (spheroid);
    endif
    angleUnit = varargin{5};
  endif
  X = varargin{ip + 1};
  Y = varargin{ip + 2};
  Z = varargin{ip + 3};

  if (! isnumeric (X) || ! isreal (X) || ...
      ! isnumeric (Y) || ! isreal (Y) || ...
      ! isnumeric (Z) || ! isreal (Z))
    error ("ecef2geodetic : numeric input expected");
  endif
  if (! all (size (X) == size (Y)) || ! all (size (Y) == size (Z)))
    error ("enu2geodetic: non-matching dimensions of ECEF inputs.");
  endif

  if (! ischar (angleUnit) || ! ismember (lower (angleUnit(1)), {"d", "r"}))
    error ("ecef2geodetic: angleUnit should be one of 'degrees' or 'radians'")
  endif

  E = sph_chk (spheroid);

  ## Insight from: http://wiki.gis.com/wiki/index.php/Geodetic_system
  lon = atan2 (Y, X);

  ecc = E.Eccentricity;
  e_sq = ecc ^ 2;
  ep_2 = e_sq / (1 - e_sq) ; ## This is (e')^2
  r = hypot (X, Y);
  E2 = E.SemimajorAxis ^ 2 - E.SemiminorAxis ^ 2;
  F = 54 * E.SemiminorAxis .^ 2 * Z .^ 2;
  G = r .^ 2 + (1 - e_sq) * Z .^ 2 - e_sq * E2;
  C = (ecc .^ 4 .* F .* r .^ 2) ./ (G .^ 3);
  S = (1 + C + sqrt (C .^ 2 + 2 .* C)) .^ (1 / 3);
  P = F ./ (3 .* (S + 1 ./ S + 1) .^ 2 .* G .^ 2);
  Q = sqrt (1 + 2 * ecc .^ 4 * P);
  r0 = -(P * e_sq .* r) ./ (1 + Q) + ...
      sqrt (.5 * E.SemimajorAxis .^ 2 * (1 + 1 ./ Q) - ...
            (P .* (1 - e_sq) .* Z .^ 2) ./ (Q .^ 2 + Q) - .5 * P .* r .^ 2);
  U = sqrt ((r - e_sq .* r0) .^ 2 + Z .^ 2);
  V = sqrt (( r - e_sq .* r0) .^ 2 + (1 - e_sq) .* Z .^ 2);
  Frac =  E.SemiminorAxis .^ 2  ./ (E.SemimajorAxis * V);
  Z0 = Frac .* Z;
  alt = U .* (1 - Frac);
  lat = atan2 ((Z + ep_2 .* Z0), r) ;

  if ( strncmpi (lower (angleUnit), "d", 1) == 1 )
    lon = rad2deg (lon);
    lat = rad2deg (lat);
  endif

endfunction


%!shared X, Y, Z
%! X = 3426949.397;
%! Y = 601195.852;
%! Z = 5327723.994; ## meters

%!test
%! [latd, lond, h] = ecef2geodetic ("wgs84", X, Y, Z);
%! assert ([latd, lond, h], [57.02929569, 9.950248114, 56.95], 10e-3);

%!test
%! [latd, lond, h] = ecef2geodetic (X, Y, Z);
%! assert ([latd, lond, h], [57.02929569, 9.950248114, 56.95], 10e-3);

%!test
%! latr = deg2rad (57.02929569);
%! lonr = deg2rad (9.950248114);
%! [lat, lon, h2] = ecef2geodetic ("wgs84", X, Y, Z, "radians");
%! assert ([lat, lon, h2], [latr, lonr, 56.95], 10e-3);

%!test
%! latr = deg2rad (57.02929569);
%! lonr = deg2rad (9.950248114);
%! [lat, lon, h2] = ecef2geodetic (X, Y, Z, "radians");
%! assert ([lat, lon, h2], [latr, lonr, 56.95], 10e-3);

%!error <angleUnit> ecef2geodetic ("", 4500000, 450000, 50000000, "km")
%!error <numeric input expected>  ecef2geodetic ("", "A", 450000, 50000000)
%!error <numeric input expected>  ecef2geodetic ("", 45i, 450000, 50000000)
%!error <numeric input expected>  ecef2geodetic ("", 4500000, "B", 50000000)
%!error <numeric input expected>  ecef2geodetic ("", 4500000, 45i, 50000000)
%!error <numeric input expected>  ecef2geodetic ("", 4500000, 450000, "C")
%!error <numeric input expected>  ecef2geodetic (4500000, 450000, "C")
%!error <numeric input expected>  ecef2geodetic ("", 4500000, 450000, 50i)
%!error <numeric input expected>  ecef2geodetic (4500000, 450000, 50i)

