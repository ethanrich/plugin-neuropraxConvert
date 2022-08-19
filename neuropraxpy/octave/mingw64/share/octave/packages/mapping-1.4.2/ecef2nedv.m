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
## @deftypefn  {Function File} {@var{n}, @var{e}, @var{d} =} ecef2nedv (@var{u}, @var{v}, @var{w}, @var{lat}, @var{lon})
## @deftypefnx {Function File} {@var{n}, @var{e}, @var{d} =} ecef2nedv (@var{u}, @var{v}, @var{w}, @var{lat}, @var{lon}, @var{angleUnit})
## Convert vector projection UVW (ECEF coordinate frame) to local NED (North
## East, Down) coordinates.
##
## Inputs:
## @table @asis
## @item
## @var{u}, @var{v}, @var{w}: vector components in ECEF coordinate frame
## (length).  All these inputs must have the same dimensions (scalar, vector
## or nD array).
##
## @item
## @var{lat}, @var{lon}: geodetic latitude and longitude (angle, default =
## degrees).  If non-scalar the dimensions should match those of the first
## three inputs.
##
## @item
## (optional) @var{angleUnit}: string for angular units ('degrees' or 'radians',
## case-insensitive, just the first character will do).  Default is 'degrees'.
## @end table
##
## Outputs:
## @table @asis
## @item
## @var{n}, @var{e}, @var{d}:  North, East, Down cartesian coordinates in same
## length units (and dimensions) as first three inputs.
## @end table
##
## Examples:
## @example
## [n, e, d] = ecef2nedv (200, 300, 1000, 45, -45)
## n =  757.11
## e =  353.55
## d =  -657.11
## @end example
##
## With radians
## @example
## [n, e, d] = ecef2nedv (200, 300, 1000, pi/4, -pi/4, "r")
## n =  757.11
## e =  353.55
## d =  -657.11
## @end example
##
## @seealso{ned2ecefv, ecef2aer, ecef2enu, ecef2enuv, ecef2ned, ecef2geodetic}
## @end deftypefn

## Function adapted by anonymous contributor, see:
## https://savannah.gnu.org/patch/index.php?9923

function [n, e, d] = ecef2nedv (u, v, w, lat, lon, angleUnit = "degrees")

  if (nargin < 5 || nargin > 6)
    print_usage();
  endif

  if (! isnumeric (u)   || ! isreal (u)   || ...
      ! isnumeric (v)   || ! isreal (v)   || ...
      ! isnumeric (w)   || ! isreal (w)   || ...
      ! isnumeric (lat) || ! isreal (lat) || ...
      ! isnumeric (lon) || ! isreal (lon))
     error ("ecef2nedv: numeric values expected for first five inputs");
  endif
  if (! all (size (u) == size (v))     || ...
      ! all (size (v) == size (w)))
    error ("ecef2nedv: non-matching dimensions of ECEF inputs.");
  elseif (! (isscalar (lat) && isscalar (lon)))
    if (! all (size (lat) == size (u)) || ! all (size (lon) == size (u)))
      error ("ecef2nedv: dimensions of Lat / Lon don't match those of ECEF.");
    endif
  endif

  if (! ischar (angleUnit))
    error ("ecef2nedv: character value expected for 'angleUnit'");
  elseif (strncmpi (angleUnit, "degrees", length (angleUnit)))
    lat = deg2rad (lat);
    lon = deg2rad (lon);
  elseif (! strncmpi (angleUnit, "radians", length (angleUnit)))
    error ("ecef2nedv: illegal input for 'angleUnit'");
  endif

  t =  cos (lon) .* u + sin (lon) .* v;
  e = -sin (lon) .* u + cos (lon) .* v;

  u =  cos (lat) .* t + sin (lat) .* w;
  n = -sin (lat) .* t + cos (lat) .* w;

  d = -u;

endfunction


%!test
%! [n, e, d] = ecef2nedv (186.277521, 286.84222, 939.69262, 42, -82, "d");
%! assert ([n, e, d], [871.0476287, 224.3854022, -436.9521873], 10e-6);

%!test
%! [n, e, d] = ecef2nedv (186.277521, 286.84222, 939.69262, ...
%!                      0.733038285837618, -1.43116998663535, "r");
%! assert ([n, e, d], [871.0476287, 224.3854022, -436.9521873], 10e-6);

%!test  ## Multidimensionality
%! [n, e, d] = ecef2nedv ([186.277521; 200], [286.84222; 300], [939.69262; 1000], 42, -82);
%! assert ([n, e, d], [871.047629, 224.385402, -436.952187; ...
%!                     923.305431, 239.805544, -469.041983], 1e-6);

%!test
%! [nv, ev, dv] = ecef2nedv (530.2445, 492.1283, 396.3459, 61.64, 30.70);
%! assert ([nv, ev, dv], [-434.0403, 152.4451, -684.69634], 1e-4);

%!error <numeric> ecef2nedv("s", 25, 1e3, 0, 0)
%!error <numeric> ecef2nedv(3i, 25, 1e3, 0, 0)
%!error <numeric> ecef2nedv(33, "s", 1e3, 0, 0)
%!error <numeric> ecef2nedv(33, 3i, 1e3, 0, 0)
%!error <numeric> ecef2nedv(33, 25, "s", 0, 0)
%!error <numeric> ecef2nedv(33, 25, 3i, 0, 0)
%!error <numeric> ecef2nedv(33, 25, 1e3, "s", 0)
%!error <numeric> ecef2nedv(33, 25, 1e3, 3i, 0)
%!error <numeric> ecef2nedv(33, 25, 1e3, 0, "s")
%!error <numeric> ecef2nedv(33, 25, 1e3, 0, 3i)
%!error <illegal> ecef2nedv (33, 70, 1e3, 0, 0, "f");
%!error <illegal> ecef2nedv (33, 70, 1e3, 0, 0, "degreef")
%!error <non-matching> [u, v, w] = ecef2nedv ([1, 2, 3], [4, 5, 6], [7, 9], 60, 50)
%!error <don't match> [u, v, w] = ecef2nedv ([1, 2, 3], [4, 5, 6], [7, 8, 9], [40; 50], [-40; -50])
%!error <don't match> [u, v, w] = ecef2nedv ([1, 2, 3], [4, 5, 6], [7, 8, 9], 50, [-45; 50])
