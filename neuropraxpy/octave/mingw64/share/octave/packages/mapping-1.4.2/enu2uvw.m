## Copyright (C) 2014-2022 Michael Hirsch, Ph.D.
## Copyright (C) 2013-2022 Felipe Geremia Nievinski
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
## @deftypefn {Function File} {@var{u}, @var{v}, @var{w} =} enu2uvw (@var{east}, @var{north}, @var{up}, @var{lat0}, @var{lon0})
## @deftypefnx {Function File} {@var{u}, @var{v}, @var{w} =} enu2uvw (@var{east}, @var{north}, @var{up}, @var{lat0}, @var{lon0}, @var{angleUnit})
## Convert East, North, Up (ENU) coordinates to UVW coordinates.
##
## Inputs:
##
## @var{east}, @var{north}, @var{up}: East, North, Up: coordinates of point(s)
## (meters)
##
## @var{lat0}, @var{lon0}: geodetic coordinates of observer/reference point(s)
## (degrees)
##
## @var{angleUnit}: string for angular units ('degrees' or 'radians',
## case-insensitive, first character will suffice).  Default = 'degrees'.
##
## Outputs:
##
## @var{u}, @var{v}, @var{w}:  coordinates of point(s) (meters).
##
## @seealso{enu2aer, enu2ecef, enu2ecefv, enu2geodetic}
## @end deftypefn

## Function adapted by anonymous contributor, see:
## https://savannah.gnu.org/patch/index.php?8377

function [u, v, w] = enu2uvw (east, n, up, lat0, lon0, angleUnit = "degrees")

  if (nargin < 5 || nargin > 6)
    print_usage ();
  endif

  if (! isnumeric (east) || ! isreal (east) || ...
      ! isnumeric (n)    || ! isreal (n) || ...
      ! isnumeric (up)   || ! isreal (up) || ...
      ! isnumeric (lat0) || ! isreal (lat0) || ...
      ! isnumeric (lon0) || ! isreal (lon0))
    error ("enu2uvw : numeric values expected for first 5 arguments");
  endif
  if (! all (size (east) == size (n)) || ! all (size (n) == size (up)))
    error ("enu2uvw: non-matching dimensions of ENU inputs.");
  endif
  if (! (isscalar (lat0) && isscalar (lon0)))
    ## Check if for each target point a matching obsrver point is given
    if (! all (size (lat0) == size (east)) || ...
        ! all (size (lon0) == size (n)))
      error (["enu2uvw: non-matching dimensions of observer points and ", ...
              "target points"]);
    endif
  endif

  if (! ischar (angleUnit))
    error ("enu2uvw: character value expected for 'angleUnit'");
  elseif (strncmpi (angleUnit, "degrees", length (angleUnit)))
    lat0 = deg2rad (lat0);
    lon0 = deg2rad (lon0);
  elseif (! strncmpi (angleUnit, "radians", length (angleUnit)))
    error ("enu2uvw: illegal input for 'angleUnit'");
  endif

  t = cos (lat0) .* up - sin (lat0) .* n;
  w = sin (lat0) .* up + cos (lat0) .* n;

  u = cos (lon0) .* t - sin (lon0) .* east;
  v = sin (lon0) .* t + cos (lon0) .* east;

endfunction

%!test
%! [u, v, w] = enu2uvw (186.277521, 286.84222, 939.69262, 42, -82, "d");
%! assert ([u, v, w], [254.940936348589, -475.5397947444, 841.942404132992], 10e-6)

%!test
%! [u, v, w] = enu2uvw (186.277521, 286.84222, 939.69262, ...
%!                      0.733038285837618, -1.43116998663535, "r");
%! assert ([u, v, w], [254.940936348589, -475.5397947444, 841.942404132992], 10e-6)

%!error <numeric> enu2uvw("s", 25, 1e3, 0, 0)
%!error <numeric> enu2uvw(3i, 25, 1e3, 0, 0)
%!error <numeric> enu2uvw(33, "s", 1e3, 0, 0)
%!error <numeric> enu2uvw(33, 3i, 1e3, 0, 0)
%!error <numeric> enu2uvw(33, 25, "s", 0, 0)
%!error <numeric> enu2uvw(33, 25, 3i, 0, 0)
%!error <numeric> enu2uvw(33, 25, 1e3, "s", 0)
%!error <numeric> enu2uvw(33, 25, 1e3, 3i, 0)
%!error <numeric> enu2uvw(33, 25, 1e3, 0, "s")
%!error <numeric> enu2uvw(33, 25, 1e3, 0, 3i)
%!error <illegal> enu2uvw (33, 70, 1e3, 0, 0, "f");
%!error <illegal> enu2uvw (33, 70, 1e3, 0, 0, "degreef");

