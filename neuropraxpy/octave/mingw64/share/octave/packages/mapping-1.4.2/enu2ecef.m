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
## @deftypefn {Function File} {@var{x}, @var{y}, @var{z} =} enu2ecef (@var{e}, @var{n}, @var{u}, @var{lat}, @var{lon}, @var{alt})
## @deftypefnx {Function File} {@var{x}, @var{y}, @var{z} =} enu2ecef (@var{e}, @var{n}, @var{u}, @var{lat}, @var{lon}, @var{alt}, @var{spheroid})
## @deftypefnx {Function File} {@var{x}, @var{y}, @var{z} =} enu2ecef (@var{e}, @var{n}, @var{u}, @var{lat}, @var{lon}, @var{alt}, @var{spheroid}, @var{angleUnit})
## Convert local cartesian East, North, Up (ENU) coordinates to Earth Centered
## Earth Fixed (ECEF) coordinates.
##
## Inputs:
## @itemize
## @item
## @var{e}, @var{n}, @var{u}: look angles and distance to point
## under consideration (angle, angle, length).  Length unit of @var{u}
## (height) is that of the used reference ellipsoid (see below).  Can be
## scalars but vectoror nD-array values are accepted if they have equal
## dimensions.
##
## @item
## @var{lat}, @var{lon}, @var{alt}: ellipsoid geodetic coordinates of
## observer location (angle, angle, length).  Length unit of @var{alt}
## (height) is that of the used reference ellipsoid (see below).  In case of
## multiple local locations their numbers and dimensions should match those
## of the target points (i.e., one observer location for each target point).
##
## @item
## @var{spheroid}: referenceEllipsoid parameter struct, name or EPSG number;
## default is wgs84.  Can be an empty string or empty numeric array ('[]') to
## indicate default value.
##
## @item
## @var{angleUnit}: string for angular units ('degrees' or 'radians',
## case-insensitive, just the first character will do). Default is 'degrees'.
## @end itemize
##
## Outputs:
## @itemize
## @item
## @var{x}, @var{y}, @var{z}: Earth Centered Earth Fixed (ECEF) coordinates.
## Length units are those of the used reference ellipsoid.
## @end itemize
##
## Example
## @example
## [x, y, z] = enu2ecef (186.28, 286.84, 939.69, 42, -82, 200)
## x = 6.6093e+05
## y = -4.7014e+06
## z = 4.2466e+06
## @end example
##
## With radians
## @example
## [x, y, z] = enu2ecef (186.28, 286.84, 939.69, pi/4, -pi/2, 200, "wgs84", "radians")
## x =  186.28
## y =  -4.5182e+06
## z =  4.4884e+06
## @end example
##
## @seealso{ecef2enu, enu2aer, enu2ecefv, enu2geodetic, enu2uvw}
## @end deftypefn

## Function adapted by anonymous contributor, see:
## https://savannah.gnu.org/patch/index.php?9918

function [x, y, z] = enu2ecef (varargin)

  spheroid = "";
  angleUnit = "degrees";
  if (nargin < 6 || nargin > 8)
    print_usage();
  elseif (nargin == 6)
    ## Assume lat, lon, alt, lat0, lon0, alt0 given
  elseif (nargin == 7)
    if (isnumeric (varargin{7}))
      ## EPSG spheroid code
      spheroid = num2str (varargin{7});
    elseif (ischar (varargin{7}))
      if (! isempty (varargin{7}) && ismember (varargin{7}(1), {"r", "d"}))
        angleUnit = varargin{7};
      else
        spheroid = varargin{7};
      endif
    elseif (isstruct (varargin{7}))
      spheroid = varargin{7};
    else
      error ("enu2ecef: spheroid or angleUnit expected for arg. #7");
    endif
  elseif (nargin == 8)
    spheroid = varargin{7};
    angleUnit = varargin{8};
  endif

  e  = varargin{1};
  n  = varargin{2};
  u  = varargin{3};
  lat = varargin{4};
  lon = varargin{5};
  alt = varargin{6};
  if (! isnumeric (e)   || ! isreal (e)   || ...
      ! isnumeric (n)   || ! isreal (n)   || ...
      ! isnumeric (u)   || ! isreal (u)   ||...
      ! isnumeric (lat) || ! isreal (lat) || ...
      ! isnumeric (lon) || ! isreal (lon) ||  ...
      ! isnumeric (alt) || ! isreal (alt))
    error ("enu2ecef: numeric values expected for first 6 inputs.");
  endif

  if (! all (size (e) == size (n)) || ...
      ! all (size (n) == size (u))) ...
    error ("enu2ecef: non-matching dimensions of inputs.");
  endif
  if (! (isscalar (lat) && isscalar (lon) && isscalar (alt)))
    ## Check if for each test point a matching observer point is given
    if (! all (size (lat) == size (e)) || ...
        ! all (size (lon) == size (n)) || ...
        ! all (size (alt) == size (u)))
      error (["enu2ecef: non-matching dimensions of observer points and ", ...
              "target points"]);
    endif
  endif

  E = sph_chk (spheroid);

  ## Origin of the local system in geocentric coordinates.
  [x0, y0, z0] = geodetic2ecef (E, lat, lon, alt, angleUnit);
  ## Rotating ENU to ECEF
  [dx, dy, dz] = enu2uvw (e, n, u, lat, lon, angleUnit);
  ## Origin + offset from origin equals position in ECEF
  x = x0 + dx;
  y = y0 + dy;
  z = z0 + dz;

endfunction

%!test
%! [x, y, z] = enu2ecef (186.28, 286.84, 939.69, 42, -82, 200);
%! assert ([x, y, z], [6.6093019515e5, -4.70142422216e6, 4.24657960122e6], 10e-6)

%!test
%! [x3, y3, z3] = enu2ecef ( 186.28, 286.84, 939.69, 0.733038285837618, -1.43116998663535, 200, "", "rad");
%! assert ([x3, y3, z3], [660.93019e3, -4701.42422e3, 4246.5796e3],10e-3)

%!test
%! [a, b, c] = enu2ecef (355601.3, -923083.2, 1041016.4, 45.9132, 36.7484, 1877753.2);
%! assert ([a, b, c], [5507528.8891, 4556224.1399, 6012820.7522], 1e-4)

%!error <numeric> enu2ecef("s", 25, 1e3, 0, 0, 0)
%!error <numeric> enu2ecef(3i, 25, 1e3, 0, 0, 0)
%!error <numeric> enu2ecef(33, "s", 1e3, 0, 0, 0)
%!error <numeric> enu2ecef(33, 3i, 1e3, 0, 0, 0)
%!error <numeric> enu2ecef(33, 25, "s", 0, 0, 0)
%!error <numeric> enu2ecef(33, 25, 3i, 0, 0, 0)
%!error <numeric> enu2ecef(33, 25, 1e3, "s", 0, 0)
%!error <numeric> enu2ecef(33, 25, 1e3, 3i, 0, 0)
%!error <numeric> enu2ecef(33, 25, 1e3, 0, "s", 0)
%!error <numeric> enu2ecef(33, 25, 1e3, 0, 3i, 0)
%!error <numeric> enu2ecef(33, 25, 1e3, 0, 0, "s")
%!error <numeric> enu2ecef(33, 25, 1e3, 0, 0, 3i)
%!error <non-matching> enu2ecef ([1 1], [2 2]', [3 3], 4, 5, 6)
%!error <non-matching> enu2ecef ([1 1], [2 2], [33], 4, 5, 6)
%!error <non-matching> enu2ecef ([1 1], [2 2], [3 3], [4 4], 5, 6)
%!error <non-matching> enu2ecef ([1 1], [2 2], [3 3], 4, [5 5], 6)
%!error <non-matching> enu2ecef ([1 1], [2 2], [3 3], 4, 5, [6 6])

