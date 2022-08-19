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
## @deftypefn {Function File} {@var{u}, @var{v}, @var{w} =} enu2ecefv (@var{e}, @var{n}, @var{u}, @var{lat}, @var{lon})
## @deftypefnx {Function File} {@var{u}, @var{v}, @var{w} =} enu2ecefv (@var{e}, @var{n}, @var{u}, @var{lat}, @var{lon})
## Convert vector projection(s) of local ENU coordinates to UVW (in ECEF
## coordinate frame).
##
## Inputs:
## @itemize
## @item
## @var{e}, @var{n}, @var{u}:  East, North, Up local cartesian coordinates
## (length).  All these inputs must have the same dimensions (scalar, vector
## or nD array) and length units.
## @end item
##
## @item
## @var{lat}, @var{lon}: geodetic latitude and longitude (angle).  If
## non-scalar the dimensions should match those of the first three inputs.
## @end item
##
## @item
## @var{angleUnit}: string for angular units ('degrees' or 'radians',
## case-insensitive, just the first character will do).  Default is 'degrees'.
## @end item
## @end itemize
##
## Outputs:
## @itemize
## @item
## @var{u}, @var{v}, @var{w}: vectors in local ENU system (length units and
## dimensions same as first three inputs).
## @end itemize
##
## Examples:
## @example
## [u, v, w] = enu2ecefv (353.55, 757.11, 657.11, 45, -45)
## u =  200.00
## v =  300.00
## w =  1000.0
## @end example
##
## With radians
## @example
## [u, v, w] = enu2ecefv (353.55, 757.11, 657.11, pi/4, -pi/4, "r")
## u =  200.00
## v =  300.00
## w =  1000.0
## @end example
##
## @seealso{ecef2enuv, enu2aer, enu2ecef, enu2geodetic, enu2uvw}
## @end deftypefn

## Function adapted by anonymous contributor, see:
## https://savannah.gnu.org/patch/index.php?9918

function [u, v, w] = enu2ecefv (e, n, u, lat, lon, angleUnit = "degrees")

  if (nargin < 5)
    print_usage();
  endif

  if (! isnumeric (e)   || ! isreal (e)   || ...
      ! isnumeric (n)   || ! isreal (n)   || ...
      ! isnumeric (u)   || ! isreal (u)   || ...
      ! isnumeric (lat) || ! isreal (lat) || ...
      ! isnumeric (lon) || ! isreal (lon))
     error ("enu2ecefv : numeric values expected for first five inputs");
  endif
  if (! all (size (e) == size (n))     || ...
      ! all (size (n) == size (u)))
    error ("enu2ecefv: non-matching dimensions of ECEF inputs.");
  elseif (! (isscalar (lat) && isscalar (lon)))
    if (! all (size (lat) == size (u)) || ! all (size (lon) == size (u)))
      error ("enu2ecefv: dimensions of Lat / Lon don't match those of ECEF.");
    endif
  endif

  if (! ischar (angleUnit))
    error ("enu2ecefv: character value expected for 'angleUnit'");
  elseif (strncmpi (angleUnit, "degrees", length (angleUnit)))
    lat = deg2rad (lat);
    lon = deg2rad (lon);
  elseif (! strncmpi (angleUnit, "radians", length (angleUnit)))
    error ("enu2ecefv: illegal input for 'angleUnit'");
  endif

  t = cos(lat) .* u - sin(lat) .* n;
  w = sin(lat) .* u + cos(lat) .* n;

  u = cos(lon) .* t - sin(lon) .* e;
  v = sin(lon) .* t + cos(lon) .* e;

endfunction


%!test
%! [u, v, w] = enu2ecefv (224.3854022, 871.0476287, 436.9521873, 42, -82, "d");
%! assert ([u, v, w], [186.277521, 286.84222, 939.69262], 10e-6)

%!test
%! [u, v, w] = enu2ecefv (224.3854022, 871.0476287, 436.9521873, ...
%!                      0.733038285837618, -1.43116998663535, "r");
%! assert ([u, v, w], [186.277521, 286.84222, 939.69262], 10e-6)

%!test  ## Multidimensionality
%! [u, v, w] = enu2ecefv ([224.3854022; 200], [871.0476287; 900], [436.9521873; 500], 42, -82);
%! assert ([u, v, w], [186.277521, 286.84222, 939.69262; ...
%!                     165.954015, 256.23513, 1003.395646], 1e-6);

%!error <numeric> enu2ecefv("s", 25, 1e3, 0, 0)
%!error <numeric> enu2ecefv(3i, 25, 1e3, 0, 0)
%!error <numeric> enu2ecefv(33, "s", 1e3, 0, 0)
%!error <numeric> enu2ecefv(33, 3i, 1e3, 0, 0)
%!error <numeric> enu2ecefv(33, 25, "s", 0, 0)
%!error <numeric> enu2ecefv(33, 25, 3i, 0, 0)
%!error <numeric> enu2ecefv(33, 25, 1e3, "s", 0)
%!error <numeric> enu2ecefv(33, 25, 1e3, 3i, 0)
%!error <numeric> enu2ecefv(33, 25, 1e3, 0, "s")
%!error <numeric> enu2ecefv(33, 25, 1e3, 0, 3i)
%!error <illegal> enu2ecefv (33, 70, 1e3, 0, 0, "f");
%!error <illegal> enu2ecefv (33, 70, 1e3, 0, 0, "degreef")
%!error <non-matching> [u, v, w] = enu2ecefv ([1, 2, 3], [4, 5, 6], [7, 9], 60, 50)
%!error <don't match> [u, v, w] = enu2ecefv ([1, 2, 3], [4, 5, 6], [7, 8, 9], [40; 50], [-40; -50])
%!error <don't match> [u, v, w] = enu2ecefv ([1, 2, 3], [4, 5, 6], [7, 8, 9], 50, [-45; 50])

