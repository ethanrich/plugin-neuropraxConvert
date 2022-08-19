## Copyright (C) 2014-2022 Michael Hirsch, Ph.D.
## Copyright (C) 2013-2022 Felipe Geremia Nievinski
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
## @deftypefn  {Function File} {@var{n}, @var{e}, @var{d} =} ecef2ned (@var{x}, @var{y}, @var{z}, @var{lat0}, @var{lon0}, @var{alt0})
## @deftypefnx {Function File} {@var{n}, @var{e}, @var{d} =} ecef2ned (@var{x}, @var{y}, @var{z}, @var{lat0}, @var{lon0}, @var{alt0}, @var{spheroid})
## @deftypefnx {Function File} {@var{n}, @var{e}, @var{d} =} ecef2ned (@var{x}, @var{y}, @var{z}, @var{lat0}, @var{lon0}, @var{alt0}, @var{spheroid}, @var{angleUnit})
## Convert Earth Centered Earth Fixed (ECEF) coordinates to local North,
## East, Down (NED) coordinates.
##
## Inputs:
## @itemize
## @item
## @var{x}, @var{y}, @var{z}:
## ECEF coordinates of target points (length units equal to length unit of
## used referenceEllipsoid, of which the default is meters).  Can be scalars
## but vectors and nD arrays are accepted if they have equal dimensions.
##
## @item
## @var{lat0}, @var{lon0}, @var{alt0}: latitude, longitude and height of local
## observer point(s).  Length unit of local height: see above.  In case of
## multiple local locations their numbers and dimensions should match those of
## the target points (i.e., one observer location for each target point).
##
## @item
## (Optional) @var{spheroid}: referenceEllipsoid specified as EPSG number,
## ellipsoid name, or parameter struct.  An empty string ("") or empty numeric
## array ([]) is also accepted.  Default is WGS84.
##
## @item
## (Optional) @var{angleUnit}: string for angular units ('radians' or
## 'degrees'), only the first letter matters.  Default is 'd': degrees.
## @end itemize
##
## Outputs:
## @itemize
## @var{n}, @var{e}, @var{d}:  North, East, Down: local cartesian coordinates
## of target point(s) (default length unit that of invoked referenceEllipsoid,
## of which the default is meters).
## @end itemize
##
## Example:
## @example
## [n, e, d] = ecef2ned (660930, -4701424, 4246579, 42, -82, 200, ...
##                       "wgs84", "degrees")
## -->
##      n =  286.56
##      e =  186.12
##      d = -939.10
## @end example
##
## @seealso{ned2ecef, ecef2aer, ecef2enu, ecef2enuv, ecef2geodetic, ecef2nedv,
## referenceEllipsoid}
## @end deftypefn

## Function adapted by anonymous contributor, see:
## https://savannah.gnu.org/patch/index.php?9923

function [n, e, d] = ecef2ned (varargin)

  spheroid = "";
  angleUnit = "degrees";
  if (nargin < 6 || nargin > 8)
    print_usage();
  elseif (nargin == 6)
    ## Assume ECEF & lat0, lon0, alt0 coordinates given
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
      error ("ecef2ned: spheroid or angleUnit expected for arg. #7");
    endif
  elseif (nargin == 8)
    spheroid = varargin{7};
    angleUnit = varargin{8};
  endif

  x  = varargin{1};
  y  = varargin{2};
  z  = varargin{3};
  lat0 = varargin{4};
  lon0 = varargin{5};
  alt0 = varargin{6};
  if (! isnumeric (x)  || ! isreal (x)  || ...
      ! isnumeric (y)  || ! isreal (y)  || ...
      ! isnumeric (z)  || ! isreal (z)  || ...
      ! isnumeric (lat0) || ! isreal (lat0) ||  ...
      ! isnumeric (lon0) || ! isreal (lon0) || ...
      ! isnumeric (alt0) || ! isreal (alt0))
    error ("ecef2ned : numeric real input expected for first 6 input args.");
  endif
  if (! all (size (x) == size (y)) || ! all (size (y) == size (z)))
    error ("ecef2ned: non-matching dimensions of ECEF inputs.");
  endif
  if (! (isscalar (lat0) && isscalar (lon0) && isscalar (alt0)))
    ## Check if for each test point a matching observer point is given
    if (! all (size (lat0) == size (x)) || ...
        ! all (size (lon0) == size (y)) || ...
        ! all (size (alt0) == size (z)))
      error (["ecef2ned: non-matching dimensions of observer points and ", ...
              "target points"]);
    endif
  endif

  E = sph_chk (spheroid);

  if (! ischar (angleUnit) || ! ismember (lower (angleUnit(1)), {"d", "r"}))
    error ("ecef2ned: angleUnit should be one of 'degrees' or 'radians'")
  endif

  [x0, y0, z0] = geodetic2ecef (E, lat0, lon0, alt0, angleUnit);
  [n, e, d]    = ecef2nedv (x - x0, y - y0, z - z0, lat0, lon0, angleUnit);

endfunction


%!test
%! [n, e, d] = ecef2ned (660930.192761082, -4701424.222957011, 4246579.604632881, 42, -82, 200);
%! assert([n, e, d], [286.84222, 186.27752, -939.69262], 10e-6);

%!test
%! Rad = deg2rad ([42, -82]);
%! [e, n, u] = ecef2ned (660930.192761082, -4701424.222957011, 4246579.604632881, Rad(1), Rad(2), 200, "rad");
%! assert ([e, n, u], [286.84, 186.28, -939.69], 10e-3);

%!test
%! [a, b, c] = ecef2ned (5507528.9, 4556224.1, 6012820.8, 45.9132, 36.7484, 1877753.2);
%! assert ([a, b, c], [-923083.1558, 355601.2616, -1041016.4238], 1e-4);

%!test
%! [nn, ee, dd] = ecef2ned (1345660, -4350891, 4452314, 44.532, -72.782, 1699);
%! assert ([nn, ee, dd], [1334.3045, -2544.3677, 359.9609], 1e-4);

%!error <angleUnit> ecef2ned (45, 45, 100, 50, 50, 200, "", "km")
%!error <numeric real input expected>  ecef2ned ("A", 45, 100, 50, 50, 200)
%!error <numeric real input expected>  ecef2ned (45i, 45, 100, 50, 50, 200)
%!error <numeric real input expected>  ecef2ned (45, "A", 100, 50, 50, 200)
%!error <numeric real input expected>  ecef2ned (45, 45i, 100, 50, 50, 200)
%!error <numeric real input expected>  ecef2ned (45, 45, "A", 50, 50, 200)
%!error <numeric real input expected>  ecef2ned (45, 45, 100i, 50, 50, 200)
%!error <numeric real input expected>  ecef2ned (45, 45, 100, "A", 50, 200)
%!error <numeric real input expected>  ecef2ned (45, 45, 100, 50i, 50, 200)
%!error <numeric real input expected>  ecef2ned (45, 45, 100, 50, "A", 200)
%!error <numeric real input expected>  ecef2ned (45, 45, 100, 50, 50i, 200)
%!error <numeric real input expected>  ecef2ned (45, 45, 100, 50, 50, "A")
%!error <numeric real input expected>  ecef2ned (45, 45, 100, 50, 50, 200i)
%!error <non-matching> ecef2ned ([1 1], [2 2]', [3 3], 4, 5, 6)
%!error <non-matching> ecef2ned ([1 1], [2 2], [33], 4, 5, 6)
%!error <non-matching> ecef2ned ([1 1], [2 2], [3 3], [4 4], 5, 6)
%!error <non-matching> ecef2ned ([1 1], [2 2], [3 3], 4, [5 5], 6)
%!error <non-matching> ecef2ned ([1 1], [2 2], [3 3], [4; 4], [5; 5], [6; 6])
