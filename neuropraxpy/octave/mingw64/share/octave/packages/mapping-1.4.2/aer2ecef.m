## Copyright (c) 2014-2022 Michael Hirsch, Ph.D.
## Copyright (c) 2013-2022 Felipe Geremia Nievinski
## Copyright (C) 2019-2022 Philip Nienhuis
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
## @deftypefn {Function File} {@var{x}, @var{y}, @var{z} =} aer2ecef (@var{az},@var{el}, @var{slantRange}, @var{lat0}, @var{lon0}, @var{alt0})
## @deftypefnx {Function File} {@var{x}, @var{y}, @var{z} =} aer2ecef (@var{az},@var{el}, @var{slantRange}, @var{lat0}, @var{lon0}, @var{alt0}, @var{spheroid})
## @deftypefnx {Function File} {@var{x}, @var{y}, @var{z} =} aer2ecef (@var{az},@var{el}, @var{slantRange}, @var{lat0}, @var{lon0}, @var{alt0}, @var{spheroid}, @var{angleUnit})
## Convert Azimuth, Elevation, Range (AER) coordinates to Earth Centered Earth
## Fixed (ECEF) coordinates.
##
## Inputs:
## @itemize
## @var{az}, @var{el}, @var{slantrange}: look angles and distance to target
## point(s) (angle, angle, length).  Vectors and nD arrays are accepted
## if they have equal dimensions.
##
## @item
## @var{az}: azimuth angle clockwise from local north.
##
## @item
## @var{el}: elevation angle above local horizon.
##
## @item
## @var{slantrange}: distance from origin in local spherical system.
##
## @item
## @var{lat0}, @var{lon0}, @var{alt0}: latitude, longitude and height of
## local observer location(s) (angle, angle, length).  In case of multiple
## local locations their numbers and dimensions should be equal those of
## the target points.  The length unit(s) should match that/those of the
## target point(s).
##
## @item
## @var{spheroid}: referenceEllipsoid parameter struct; default is wgs84.  A
## string value describing the spheroid or numeric EPSG code is also accepted.
##
## @item
## @var{angleUnit}: string for angular units ('degrees' or 'radians',
## case-insensitive, just the first charachter will do). Default is 'degrees'.
## @end itemize
##
## Outputs:
## @itemize
## @item
## @var{x}, @var{y}, @var{z}: Earth Centered Earth Fixed (ECEF) coordinates.
## @end itemize
##
## Example
## @example
## [x, y, z] = aer2ecef (33, 70, 1e3, 42, -82, 200)
## x =    6.6057e+05
## y =   -4.7002e+06
## z =    4.2450e+06
## @end example
##
## With radians
## @example
## [x, y, z] = aer2ecef (pi/6, pi/3, 1e3, pi/4, -pi/2, 200, "wgs84", "radians")
## x =  250.00
## y =   -4.5180e+06
## z =    4.4884e+06
## @end example
##
## Note: aer2ecef is a mere wrapper for functions geodetic2ecef, aer2enu and
## enu2uvw.
##
## @seealso{ecef2aer, aer2enu, aer2geodetic, aer2ned, referenceEllipsoid}
## @end deftypefn

## Function adapted from patch by anonymous contributor, see:
## https://savannah.gnu.org/patch/index.php?8377

function [x,y,z] = aer2ecef (az, el, slantrange, lat0, lon0, alt0, ...
                             spheroid="", angleUnit="degrees")

  if (nargin < 6 || nargin > 8)
    print_usage();
  endif

  if (! isnumeric (az)         || ! isreal (az) || ...
      ! isnumeric (el)         || ! isreal (el) || ...
      ! isnumeric (slantrange) || ! isreal (slantrange) ||...
      ! isnumeric (lat0)       || ! isreal (lat0) || ...
      ! isnumeric (lon0)       || ! isreal (lon0) ||  ...
      ! isnumeric (alt0)       || ! isreal (alt0))
    error ("aer2ecef: numeric real values expected for first 6 inputs.");
  endif

  if (! all (size (az) == size (el)) || ...
      ! all (size (el) == size (slantrange))) ...
    error ("aer2ecef: non-matching dimensions of AER inputs.");
  endif
  if (! (isscalar (lat0) && isscalar (lon0) && isscalar (alt0)))
    ## Check if for each test point a matching obsrver point is given
    if (! all (size (lat0) == size (az)) || ...
        ! all (size (lon0) == size (el)) || ...
        ! all (size (alt0) == size (slantrange)))
      error (["aer2ecef: non-matching dimensions of observer points and ", ...
              "target points"]);
    endif
  endif

  if (isnumeric (spheroid) && isscalar (spheroid))
    spheroid = num2str (spheroid);
  endif

  E = sph_chk (spheroid);

  %% Origin of the local system in geocentric coordinates.
  [x0, y0, z0] = geodetic2ecef (E, lat0, lon0, alt0, angleUnit);
  %% Convert Local Spherical AER to ENU
  [e, n, u] = aer2enu (az, el, slantrange, angleUnit);
  %% Rotating ENU to ECEF
  [dx, dy, dz] = enu2uvw (e, n, u, lat0, lon0, angleUnit);
  %% Origin + offset from origin equals position in ECEF
  x = x0 + dx;
  y = y0 + dy;
  z = z0 + dz;

endfunction

%!test
% [x2, y2, z2] = aer2ecef (33, 70, 1e3, 42, -82, 200);
% assert ([x2, y2, z2], [660.930e3, -4701.424e3, 4246.579e3], 10e-6)
% [x3, y3, z3] = aer2ecef ( 0.575958653158129, 1.22173047639603, 1e3, 0.733038285837618, -1.43116998663535, 200, "", "rad");
% assert ([x3, y3, z3], [660.93019e3, -4701.42422e3, 4246.5796e3],10e-3)

%!error <numeric> aer2ecef("s", 25, 1e3, 0, 0, 0)
%!error <numeric> aer2ecef(3i, 25, 1e3, 0, 0, 0)
%!error <numeric> aer2ecef(33, "s", 1e3, 0, 0, 0)
%!error <numeric> aer2ecef(33, 3i, 1e3, 0, 0, 0)
%!error <numeric> aer2ecef(33, 25, "s", 0, 0, 0)
%!error <numeric> aer2ecef(33, 25, 3i, 0, 0, 0)
%!error <numeric> aer2ecef(33, 25, 1e3, "s", 0, 0)
%!error <numeric> aer2ecef(33, 25, 1e3, 3i, 0, 0)
%!error <numeric> aer2ecef(33, 25, 1e3, 0, "s", 0)
%!error <numeric> aer2ecef(33, 25, 1e3, 0, 3i, 0)
%!error <numeric> aer2ecef(33, 25, 1e3, 0, 0, "s")
%!error <numeric> aer2ecef(33, 25, 1e3, 0, 0, 3i)
%!error <non-matching> aer2ecef ([1 1], [2 2]', [3 3], 4, 5, 6)
%!error <non-matching> aer2ecef ([1 1], [2 2], [33], 4, 5, 6)
%!error <non-matching> aer2ecef ([1 1], [2 2], [3 3], [4 4], 5, 6)
%!error <non-matching> aer2ecef ([1 1], [2 2], [3 3], 4, [5 5], 6)
%!error <non-matching> aer2ecef ([1 1], [2 2], [3 3], [4; 4], [5; 5], [6; 6])

