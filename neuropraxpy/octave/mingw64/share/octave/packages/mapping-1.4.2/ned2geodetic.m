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
## @deftypefn {Function File}  {@var{lat}, @var{lon}, @var{alt} =} ned2geodetic (@var{n}, @var{e}, @var{d}, @var{lat0}, @var{lon0}, @var{alt0})
## @deftypefnx {Function File} {@var{lat}, @var{lon}, @var{alt} =} ned2geodetic (@var{n}, @var{e}, @var{d}, @var{lat0}, @var{lon0}, @var{alt0}, @var{spheroid})
## @deftypefnx {Function File} {@var{lat}, @var{lon}, @var{alt} =} ned2geodetic (@var{n}, @var{e}, @var{d}, @var{lat0}, @var{lon0}, @var{alt0}, @var{spheroid}, @var{angleUnit})
## Convert local cartesian North, East, Down (NED) coordinates to geodetic
## coordinates.
##
## Inputs:
## @itemize
## @item
## @var{n}, @var{e}, @var{d}: look angles and distance to target point(s)
## (angle, angle, length).  Can be scalars but vectors and nD arrays values
## are accepted if they have equal dimensions.
##
## @item
## @var{lat0}, @var{lon0}, @var{alt0}: ellipsoid geodetic coordinates of
## observer location (angle, angle, length).  In case of multiple observer
## locations their numbers and dimensions should match those of the target
## points (i.e., one observer location for each target point).  The length
## units of target point(s) and observer location(s) should match.
##
## @item
## @var{spheroid}: referenceEllipsoid parameter struct; default is wgs84.  A
## string value or numerical EPSG code describing the spheroid is also
## accepted.
##
## @item
## @var{angleUnit}: string for angular units ('degrees' or 'radians',
## case-insensitive, just the first charachter will do). Default is 'degrees'.
## @end itemize
##
## Outputs:
## @itemize
## @item
## @var{lat}, @var{lon}, @var{alt}: geodetic coordinates of target points
## (angle, angle, length).
##
## Note: @var{alt} (height) is relative to the reference ellipsoid, not the
## geoid.  Use e.g., egm96geoid to compute the height difference between the
## geoid and the WGS84 reference ellipsoid.
## @end itemize
##
## Lengh units are those of the invoked reference ellipsoid (see below).
##
## ned2geodetic.m is a wrapper for ned2ecef.m and ecef2geodetic.m
##
## Examples
## @example
## [lat, lon, alt] = ned2geodetic (286.84, 186.28, -939.69, 42, -82, 200)
## lat =  42.003
## lon = -81.998
## alt =  1139.7
## @end example
##
## With radians:
## @example
## [lat, lon, alt] = ned2geodetic (286.84, 186.28, -939.69, pi/4, -pi/2, 200, ...
##                                 "wgs84", "radians")
## lat =  0.78544
## lon = -1.5708
## alt =  1139.7
## @end example
##
## @seealso{geodetic2ned, ned2aer, ned2ecef, ned2ecefv, referenceEllipsoid}
## @end deftypefn

## Function adapted by anonymous contributor, see:
## https://savannah.gnu.org/patch/index.php?9923

function [lat, lon, alt] = ned2geodetic (varargin)

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
      error ("ned2geodetic: spheroid or angleUnit expected for arg. #7");
    endif
  elseif (nargin == 8)
    spheroid = varargin{7};
    angleUnit = varargin{8};
  endif

  n  = varargin{1};
  e  = varargin{2};
  d  = varargin{3};
  lat0 = varargin{4};
  lon0 = varargin{5};
  alt0 = varargin{6};
  if (! isnumeric (e)    || ! isreal (e) || ...
      ! isnumeric (n)    || ! isreal (n) || ...
      ! isnumeric (d)    || ! isreal (d) ||...
      ! isnumeric (lat0) || ! isreal (lat0) || ...
      ! isnumeric (lon0) || ! isreal (lon0) ||  ...
      ! isnumeric (alt0) || ! isreal (alt0))
    error ("ned2geodetic: numeric real values expected for first 6 inputs.");
  endif
  if (! all (size (e) == size (n)) || ...
      ! all (size (n) == size (d))) ...
    error ("ned2geodetic: non-matching dimensions of inputs.");
  endif
  if (! isscalar (lat0) || ! isscalar (lon0) || ! isscalar (alt0))
    ## Check if for each test point a matching obsrver point is given
    if (! all (size (lat0) == size (e)) || ...
        ! all (size (lon0) == size (n)) || ...
        ! all (size (alt0) == size (d)))
      error (["ned2geodetic: non-matching dimensions of non-scalar observer ", ...
              "points and target points"]);
    endif
  endif

  if (isnumeric (spheroid))
    spheroid = num2str (spheroid);
  endif
  E = sph_chk (spheroid);

  [x, y, z] = ned2ecef (n, e, d, lat0, lon0, alt0, E, angleUnit);
  [lat, lon, alt] = ecef2geodetic (E, x, y, z, angleUnit);

endfunction


%!test
%! [lat, lon, alt] = ned2geodetic (286.84, 186.28, -939.69, 42, -82, 200);
%! assert ([lat, lon, alt], [42.00258, -81.997752, 1139.69918], 10e-6);

%!test
%! [lat, lon, alt] = ned2geodetic (286.84, 186.28, -939.69, 0.733038285837618, -1.43116998663535, 200, "", "rad");
%! assert ([lat, lon, alt], [0.73308, -1.43113, 1139.69918], 10e-6);

%!test
%! [a, b, c] = ned2geodetic (-4556.3, -7134.8, -2852.4, 46.017, 7.750, 1673, 7030);
%! assert ([a, b, c], [45.976000, 7.657999, 4531.009608], 1e-6);

%!test
%! [a, b, c] = ned2geodetic (1334.3, -2543.6, 359.65, 44.532, -72.782, 1699);
%! assert ([a, b, c], [44.5440, -72.8140, 1339.9960], 1e-4);

%!error <numeric> ned2geodetic("s", 25, 1e3, 0, 0, 0)
%!error <numeric> ned2geodetic(3i, 25, 1e3, 0, 0, 0)
%!error <numeric> ned2geodetic(33, "s", 1e3, 0, 0, 0)
%!error <numeric> ned2geodetic(33, 3i, 1e3, 0, 0, 0)
%!error <numeric> ned2geodetic(33, 25, "s", 0, 0, 0)
%!error <numeric> ned2geodetic(33, 25, 3i, 0, 0, 0)
%!error <numeric> ned2geodetic(33, 25, 1e3, "s", 0, 0)
%!error <numeric> ned2geodetic(33, 25, 1e3, 3i, 0, 0)
%!error <numeric> ned2geodetic(33, 25, 1e3, 0, "s", 0)
%!error <numeric> ned2geodetic(33, 25, 1e3, 0, 3i, 0)
%!error <numeric> ned2geodetic(33, 25, 1e3, 0, 0, "s")
%!error <numeric> ned2geodetic(33, 25, 1e3, 0, 0, 3i)
%!error <non-matching> ned2geodetic ([1 1], [2 2]', [3 3], 4, 5, 6)
%!error <non-matching> ned2geodetic ([1 1], [2 2], [33], 4, 5, 6)
%!error <non-matching> ned2geodetic ([1 1], [2 2], [3 3], [4 4], 5, 6)
%!error <non-matching> ned2geodetic ([1 1], [2 2], [3 3], 4, [5 5], 6)
%!error <non-matching> ned2geodetic ([1 1], [2 2], [3 3], [4; 4], [5; 5], [6; 6])
