## Copyright (c) 2014-2022 Michael Hirsch, Ph.D.
## Copyright (c) 2013-2022 Felipe Geremia Nievinski
## Copyright (C) 2020-2022 Philip Nienhuis
##
## Redistribution and use in source and binary forms, with or without
## modification, are permitted provided that the following conditions are met:
## 1. Redistributions of source code must retain the above copyright notice,
##    this list of conditions and the following disclaimer.
## 2. Redistributions in binary form must reproduce the above copyright notice,
##    this list of conditions and the following disclaimer in the documentation
##    and/or other materials provided with the distribution.
## THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
## AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
## THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
## ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
## LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
## CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
## SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
## OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
## WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
## (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
## SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

## -*- texinfo -*-
## @deftypefn  {Function File} {@var{e}, @var{n}, @var{u} =} geodetic2enu (@var{lat}, @var{lon}, @var{alt}, @var{lat0}, @var{lon0}, @var{alt0})
## @deftypefnx {Function File} {@var{e}, @var{n}, @var{u} =} geodetic2enu (@var{lat}, @var{lon}, @var{alt}, @var{lat0}, @var{lon0}, @var{alt0}, @var{spheroid})
## @deftypefnx {Function File} {@var{e}, @var{n}, @var{u} =} geodetic2enu (@var{lat}, @var{lon}, @var{alt}, @var{lat0}, @var{lon0}, @var{alt0}, @var{spheroid}, @var{angleUnit})
## Convert from geodetic coordinates to local East, North, Up (ENU) coordinates.
##
## Inputs:
## @itemize
## @item
## @var{lat}, @var{lon}, @var{alt}:  ellipsoid geodetic coordinates of target
## point (angle, angle, length).  Can be scalars but vectors and nD arrays
## values are accepted if they have equal dimensions.
##
## @item
## @var{lat0}, @var{lon0}, @var{alt0}: ellipsoid geodetic coordinates of
## observer location (angle, angle, length).  In case of multiple observer
## locations their numbers and dimensions should match those of the target
## points (i.e., one observer location for each target point).  The length
## units of target point(s) and observer location(s) should match.
##
## Note: @var{alt} (height) is relative to the reference ellipsoid, not the
## geoid.  Use e.g., egm96geoid to compute the height difference between the
## geoid and the WGS84 reference ellipsoid.
##
## @item
## @var{spheroid} (optional): a user-specified sheroid (see referenceEllipsoid);
## it can be omitted or given as an empty string or empty numeric array('[]'),
## in which cases WGS84 will be selected as default spheroid.
##
## @var{angleUnit}: string for angular units ('degrees' or 'radians',
## case-insensitive, just the first character will do).  Default is 'degrees'.
## @end itemize
##
## Outputs:
## @itemize
## @item
## @var{e}, @var{n}, @var{u}:  East, North, Up Cartesian coordinates
## (length).
## @end itemize
##
## Lengh units are those of the invoked reference ellipsoid (see below).
##
## Example:
## @example
## lat  = 42.002; lon  = -81.998; alt  = 1000;
## lat0 = 42;     lon0 = -82;     alt0 = 200;
## [e, n, u] = geodetic2enu(lat, lon, alt, lat0, lon0, alt0, "wgs84", "degrees")
## e =  165.72
## n =  222.18
## u =  799.99
## @end example
##
## @seealso{enu2geodetic, geodetic2aer, geodetic2ecef, geodetic2ned,
## egm96geoid, referenceEllipsoid}
## @end deftypefn

## Function adapted by anonymous contributor, see:
## https://savannah.gnu.org/patch/index.php?9918

function [e, n, u] = geodetic2enu (varargin)

  spheroid = "";
  angleUnit = "degrees";
  if (nargin < 6 || nargin > 8)
    print_usage();
  elseif (nargin == 7)
    if (isnumeric (varargin{7}))
      ## EPSG spheroid code
      spheroid = varargin{7};
    elseif (ischar (varargin{7}))
      if (! isempty (varargin{7}) && ismember (varargin{7}(1), {"r", "d"}))
        angleUnit = varargin{7};
      else
        spheroid = varargin{7};
      endif
    elseif (isstruct (varargin{7}))
      spheroid = varargin{7};
    else
      error ("geodetic2enu: spheroid or angleUnit expected for arg. #7");
    endif
  elseif (nargin == 8)
    spheroid = varargin{7};
    angleUnit = varargin{8};
  endif

  lat  = varargin{1};
  lon  = varargin{2};
  alt  = varargin{3};
  lat0 = varargin{4};
  lon0 = varargin{5};
  alt0 = varargin{6};
  if (! isnumeric (lat)  || ! isreal (lat)  || ...
      ! isnumeric (lon)  || ! isreal (lon)  || ...
      ! isnumeric (alt)  || ! isreal (alt)  || ...
      ! isnumeric (lat0) || ! isreal (lat0) ||  ...
      ! isnumeric (lon0) || ! isreal (lon0) || ...
      ! isnumeric (alt0) || ! isreal (alt0))
     error ("geodetic2enu: numeric real input expected");
  endif
  if (! all (size (lat) == size (lon)) || ! all (size (lon) == size (alt)))
    error ("geodetic2enu: non-matching dimensions of ECEF inputs.");
  endif

  if (isnumeric (spheroid))
    spheroid = num2str (spheroid);
  endif
  E = sph_chk (spheroid);

  if (! ischar (angleUnit) || ! ismember (lower (angleUnit(1)), {"d", "r"}))
    error ("geodetic2enu: angleUnit should be one of 'degrees' or 'radians'")
  endif

  [x1, y1, z1] = geodetic2ecef (E, lat, lon, alt, angleUnit);
  [x2, y2, z2] = geodetic2ecef (E, lat0, lon0, alt0, angleUnit);

  dx = x1 - x2;
  dy = y1 - y2;
  dz = z1 - z2;

  [e, n, u] = ecef2enuv (dx, dy, dz, lat0, lon0, angleUnit);

endfunction


%!test
%! lat  = 42.002582; lon = -81.997752; alt = 1139.7;
%! lat0 = 42; lon0 = -82; alt0 = 200;
%! [e, n, u] = geodetic2enu(lat, lon, alt, lat0, lon0, alt0);
%! assert([e, n, u], [186.28, 286.84, 939.69], 10e-3);

%!test
%! Rad=deg2rad([42.002582, -81.997752, 42, -82]);
%! alt = 1139.7; alt0 = 200;
%! [e, n, u] = geodetic2enu(Rad(1), Rad(2), alt, Rad(3), Rad(4), alt0, "rad");
%! assert([e, n, u], [186.28, 286.84, 939.69], 10e-3);

%!test
%! [a, b, c] = enu2geodetic (-7134.8, -4556.3, 2852.4, 46.017, 7.750, 1673, 'wgs84');
%! [d, e, f] = geodetic2enu (a, b, c, 46.017, 7.750, 1673);
%! assert ([d, e, f], [ -7134.8, -4556.3, 2852.4], 1e-6);

%!error <angleUnit> geodetic2enu (45, 45, 100, 50, 50, 200, "", "km")
%!error <numeric real input expected>  geodetic2enu ("A", 45, 100, 50, 50, 200)
%!error <numeric real input expected>  geodetic2enu (45i, 45, 100, 50, 50, 200)
%!error <numeric real input expected>  geodetic2enu (45, "A", 100, 50, 50, 200)
%!error <numeric real input expected>  geodetic2enu (45, 45i, 100, 50, 50, 200)
%!error <numeric real input expected>  geodetic2enu (45, 45, "A", 50, 50, 200)
%!error <numeric real input expected>  geodetic2enu (45, 45, 100i, 50, 50, 200)
%!error <numeric real input expected>  geodetic2enu (45, 45, 100, "A", 50, 200)
%!error <numeric real input expected>  geodetic2enu (45, 45, 100, 50i, 50, 200)
%!error <numeric real input expected>  geodetic2enu (45, 45, 100, 50, "A", 200)
%!error <numeric real input expected>  geodetic2enu (45, 45, 100, 50, 50i, 200)
%!error <numeric real input expected>  geodetic2enu (45, 45, 100, 50, 50, "A")
%!error <numeric real input expected>  geodetic2enu (45, 45, 100, 50, 50, 200i)

