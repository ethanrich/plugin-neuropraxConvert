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
## @deftypefn  {Function File} {@var{x}, @var{y}, @var{z} =} enu2ecef (@var{n}, @var{e}, @var{d}, @var{lat}, @var{lon}, @var{alt})
## @deftypefnx {Function File} {@var{x}, @var{y}, @var{z} =} enu2ecef (@var{n}, @var{e}, @var{d}, @var{lat}, @var{lon}, @var{alt}, @var{spheroid})
## @deftypefnx {Function File} {@var{x}, @var{y}, @var{z} =} enu2ecef (@var{n}, @var{e}, @var{d}, @var{lat}, @var{lon}, @var{alt}, @var{spheroid}, @var{angleUnit})
## Convert local cartesian North, East, Down (NED) coordinates to Earth Centered
## Earth Fixed (ECEF) coordinates.
##
## Inputs:
## @itemize
## @item
## @var{n}, @var{e}, @var{d}: look angles and distance to target point
## (angle, angle, length).  Length unit of @var{u} (height) is that of the
## used reference ellipsoid (see below).  Can be scalars but vector or
## nD-array values are accepted if they have equal dimensions.
##
## @item
## @var{lat}, @var{lon}, @var{alt}: ellipsoid geodetic coordinates of
## observer location (angle, angle, length).  Length unit of @var{alt}
## (height) is that of the used reference ellipsoid (see below).  In case of
## multiple observer locations their numbers and dimensions should match those
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
## Examples
## @example
## [x, y, z] = ned2ecef (286.84, 186.28, -939.69, 42, -82, 200)
## x = 6.6093e+05
## y = -4.7014e+06
## z = 4.2466e+06
## @end example
##
## With radians
## @example
## [x, y, z] = ned2ecef (286.84, 186.28, -939.69, pi/4, -pi/2, 200, ...
##                       "wgs84", "radians")
## x =  186.28
## y =  -4.5182e+06
## z =  4.4884e+06
## @end example
##
## @seealso{ecef2ned, ned2aer, ned2ecefv, ned2geodetic, referenceEllipsoid}
## @end deftypefn

## Function contributed by anonymous contributor, see:
## https://savannah.gnu.org/patch/index.php?9923

function [x, y, z] = ned2ecef (varargin)

  spheroid = "";
  angleUnit = "degrees";
  if (nargin < 6 || nargin > 8)
    print_usage();
  elseif (nargin == 6)
    ## Assume lat, lon, alt, lat0, lon0, alt0 given
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
      error ("ned2ecef: spheroid or angleUnit expected for arg. #7");
    endif
  elseif (nargin == 8)
    spheroid = varargin{7};
    angleUnit = varargin{8};
  endif

  n  =  varargin{1};
  e  =  varargin{2};
  u  =  varargin{3}; # Note multiplying by -1 makes it numeric so just use
                     # -u for the function
  lat = varargin{4};
  lon = varargin{5};
  alt = varargin{6};
  if (! isnumeric (e)   || ! isreal (e)   || ...
      ! isnumeric (n)   || ! isreal (n)   || ...
      ! isnumeric (u)   || ! isreal (u)   ||...
      ! isnumeric (lat) || ! isreal (lat) || ...
      ! isnumeric (lon) || ! isreal (lon) ||  ...
      ! isnumeric (alt) || ! isreal (alt))
    error ("ned2ecef: numeric values expected for first 6 inputs.");
  endif
  if (! all (size (e) == size (n)) || ...
      ! all (size (n) == size (u))) ...
    error ("ned2ecef: non-matching dimensions of inputs.");
  endif
  if (! (isscalar (lat) && isscalar (lon) && isscalar (alt)))
    ## Check if for each test point a matching observer point is given
    if (! all (size (lat) == size (e)) || ...
        ! all (size (lon) == size (n)) || ...
        ! all (size (alt) == size (u)))
      error (["ned2ecef: non-matching dimensions of observer points and ", ...
              "target points"]);
    endif
  endif

  if (isnumeric (spheroid))
    spheroid = num2str (spheroid);
  endif
  E = sph_chk (spheroid);

  [x, y, z] = enu2ecef (e, n, -u, lat, lon, alt, E, angleUnit);

endfunction


%!test
%! [x, y, z] = ned2ecef (286.84, 186.28, -939.69, 42, -82, 200);
%! assert ([x, y, z], [6.6093019515e5, -4.70142422216e6, 4.24657960122e6], 10e-6)

%!test
%! [x3, y3, z3] = ned2ecef (286.84, 186.28, -939.69, 0.733038285837618, -1.43116998663535, 200, "", "rad");
%! assert ([x3, y3, z3], [660.93019e3, -4701.42422e3, 4246.5796e3],10e-3)

%!test
%! [a, b, c] = ned2ecef (-923083.2, 355601.3, -1041016.4, 45.9132, 36.7484, 1877753.2);
%! assert ([a, b, c], [5507528.8891, 4556224.1399, 6012820.7522], 1e-4)

%!test
%! [x,y,z] = ned2ecef( 1334.3, -2544.4, 360.0, 44.532, -72.782, 1699);
%! assert ([x, y, z], [1345659.962, -4350890.986, 4452313.969], 1e-3);

%!error <numeric> ned2ecef("s", 25, 1e3, 0, 0, 0)
%!error <numeric> ned2ecef(3i, 25, 1e3, 0, 0, 0)
%!error <numeric> ned2ecef(33, "s", 1e3, 0, 0, 0)
%!error <numeric> ned2ecef(33, 3i, 1e3, 0, 0, 0)
%!error <numeric> ned2ecef(33, 25, "s", 0, 0, 0)
%!error <numeric> ned2ecef(33, 25, 3i, 0, 0, 0)
%!error <numeric> ned2ecef(33, 25, 1e3, "s", 0, 0)
%!error <numeric> ned2ecef(33, 25, 1e3, 3i, 0, 0)
%!error <numeric> ned2ecef(33, 25, 1e3, 0, "s", 0)
%!error <numeric> ned2ecef(33, 25, 1e3, 0, 3i, 0)
%!error <numeric> ned2ecef(33, 25, 1e3, 0, 0, "s")
%!error <numeric> ned2ecef(33, 25, 1e3, 0, 0, 3i)
%!error <non-matching> ned2ecef ([1 1], [2 2]', [3 3], 4, 5, 6)
%!error <non-matching> ned2ecef ([1 1], [2 2], [33], 4, 5, 6)
%!error <non-matching> ned2ecef ([1 1], [2 2], [3 3], [4 4], 5, 6)
%!error <non-matching> ned2ecef ([1 1], [2 2], [3 3], 4, [5 5], 6)
%!error <non-matching> ned2ecef ([1 1], [2 2], [3 3], 4, 5, [6 6])
