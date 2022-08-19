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
## @deftypefn {Function File} {@var{lat1}, @var{lon1}, @var{alt1} =} aer2geodetic (@var{az},@var{el}, @var{slantRange}, @var{lat0}, @var{lon0}, @var{alt0})
## @deftypefnx {Function File} {@var{lat1}, @var{lon1}, @var{alt1} =} aer2geodetic (@var{az},@var{el}, @var{slantRange}, @var{lat0}, @var{lon0}, @var{alt0}, @var{spheroid})
## @deftypefnx {Function File} {@var{lat1}, @var{lon1}, @var{alt1} =} aer2geodetic (@var{az},@var{el}, @var{slantRange}, @var{lat0}, @var{lon0}, @var{alt0}, @var{spheroid}, @var{angleUnit})
## Convert Azimuth, Elevation and Range (AER) coordinates to geodetic
## coordinates (latitude, longitude, local height).
##
## Inputs:
## @itemize
## @item
## @var{az}, @var{el}, @var{slantrange}: look angles and distance to target
## point(s) (angle, angle, length).  Vectors and nD arrays are accepted
## if they have equal dimensions.  The length unit is those of the used
## spheroid, the default of which is meters.
##
## @item
## @var{lat0}, @var{lon0}, @var{alt0}: ellipsoid geodetic coordinates of
## local observer location (angle, angle, length).  In case of multiple
## observer locations their numbers and dimensions should match those of
## the target points (i.e., one observer location for each target point).
## The length units of the target point(s) and observer location(s) should
## match.
##
## @item
## @var{spheroid}: referenceEllipsoid parameter struct, or name (string value)
## or EPSG code (real numeric) of referenceEllipsoid; default is 'wgs84'.
##
## @item
## @var{angleUnit}: string for angular units ('degrees' or 'radians',
## case-insensitive, just first character will suffice). Default is 'degrees'.
## @end itemize
##
## Outputs:
## @itemize
## @item
## @var{lat1}, @var{lon1}, @var{alt1}: geodetic coordinates of target point(s)
## (angle, angle, length).  The length unit matches that of the ellipsoid.
## @end itemize
##
## Example
## @example
## [x, y, z] = aer2geodetic (33, 70, 1e3, 42, -82, 200)
## x =  42.000
## y = -82.000
## z = 1139.7
## @end example
##
## With radians
## @example
## [x, y, z] = aer2geodetic (pi/6, pi/3, 1e3, pi/4, -pi/2, 200, ...
##                           "wgs84", "radians")
## x =  0.78547
## y = -1.5707
## z =  1066.0
## @end example
##
## Note: aer2geodetic is a mere wrapper for functions aer2ecef followed by
## ecef2geodetic.
##
## @seealso{geodetic2aer, aer2ecef, aer2enu, aer2ned, referenceEllipsoid}
## @end deftypefn

## Function adapted by anonymous contributor, see:
## https://savannah.gnu.org/patch/index.php?8377

function [lat1, lon1, alt1] = aer2geodetic (az, el, slantrange, lat0, lon0, alt0, spheroid = "", angleUnit = "degrees")

  if (nargin < 6 || nargin > 8)
    print_usage();
  endif

  if (! isnumeric (az)         || ! isreal (az) || ...
      ! isnumeric (el)         || ! isreal (el) || ...
      ! isnumeric (slantrange) || ! isreal (slantrange) || ...
      ! isnumeric (lat0)       || ! isreal (lat0) || ...
      ! isnumeric (lon0)       || ! isreal (lon0) ||  ...
      ! isnumeric (alt0)       || ! isreal (alt0))
    error ("aer2geodetic: numeric real values expected for first six inputs.");
  endif
  if (! all (size (az) == size (el)) || ! all (size (el) == size (slantrange)))
    error ("aer2geodetic: non-matching dimensions of inputs.");
  endif
  if (! (isscalar (lat0) && isscalar (lon0) && isscalar (alt0)))
    if (! all (size (lat0) == size (lon0)) || ! all (size (lon0) == size (alt0)))
      error ("aer2geodetic: geodetic coordinates don't match those of AER.");
    endif
  endif

  if (isnumeric (spheroid) && isscalar (spheroid))
    spheroid = num2str (spheroid);
  endif

  E = sph_chk (spheroid);

  [x, y, z] = aer2ecef (az, el, slantrange, lat0, lon0, alt0, E, angleUnit);
  [lat1, lon1, alt1] = ecef2geodetic (E, x, y, z, angleUnit);

endfunction


%!test
%! [lat2, lon2, alt2] = aer2geodetic (33, 70, 1e3, 42, -82, 200);
%! assert ([lat2, lon2, alt2], [42.002581, -81.997752, 1.1397018e3], 10e-6);

%!test
%! [lat2, lon2, alt2] = aer2geodetic ( 0.575958653158129, 1.22173047639603, ...
%!                      1e3, 0.733038285837618, -1.43116998663535, 200, "", "rad");
%! assert ([lat2, lon2, alt2], [0.7330833, -1.4311307, 1.13970179e3], 10e-6);

%!test
%! [lat2, lon2, alt2] = aer2geodetic ([33; 34], [70; 71], [1e3; 1.1e3], ...
%!                                    [42; 43], [-82; -80], [200; 210]);
%! assert ([lat2, lon2, alt2], [42.002582, -81.997752, 1139.7018; ...
%!                              43.002672 , -79.997544, 1250.080495], 1e-6);

%!error <numeric> aer2geodetic ("s", 25, 1e3, 0, 0, 0)
%!error <numeric> aer2geodetic (3i, 25, 1e3, 0, 0, 0)
%!error <numeric> aer2geodetic (33, "s", 1e3, 0, 0, 0)
%!error <numeric> aer2geodetic (33, 3i, 1e3, 0, 0, 0)
%!error <numeric> aer2geodetic (33, 25, "s", 0, 0, 0)
%!error <numeric> aer2geodetic (33, 25, 3i, 0, 0, 0)
%!error <numeric> aer2geodetic (33, 25, 1e3, "s", 0, 0)
%!error <numeric> aer2geodetic (33, 25, 1e3, 3i, 0, 0)
%!error <numeric> aer2geodetic (33, 25, 1e3, 0, "s", 0)
%!error <numeric> aer2geodetic (33, 25, 1e3, 0, 3i, 0)
%!error <numeric> aer2geodetic (33, 25, 1e3, 0, 0, "s")
%!error <numeric> aer2geodetic (33, 25, 1e3, 0, 0, 3i)
%!error <non-matching> aer2geodetic ([1 2], [3 ], 5, 45, -45, 400)
%!error <non-matching> aer2geodetic ([1; 2], [3 4], [5 6], 45, -45, 400)
%!error <non-matching> aer2geodetic ([1; 2], [3 4], [5 6], [45 50], [-45 -50], 400)
%!error <non-matching> aer2geodetic ([1; 2], [3 4], [5 6], [45; 50], [-45; -50], [400; 500])

