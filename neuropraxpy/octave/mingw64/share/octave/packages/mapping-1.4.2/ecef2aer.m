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
## @deftypefn {Function File} {@var{az}, @var{el}, @var{slantrange} =} ecef2aer (@var{x}, @var{y}, @var{z}, @var{lat0}, @var{lon0}, @var{alt0})
## @deftypefnx {Function File} {@var{az}, @var{el}, @var{slantrange} =} ecef2aer (@dots{}, @var{spheroid})
## @deftypefnx {Function File} {@var{az}, @var{el}, @var{slantrange} =} ecef2aer (@dots{}, @var{spheroid}, @var{angleUnit})
## Convert Earth Centered Earth Fixed (ECEF) coordinates to local Azimuth,
## Elevation and slantRange (AER) coordinates.
##
## Inputs:
## @itemize
## @item
## @var{x}, @var{y}, @var{z}:
## ECEF coordinates of target points (length units equal to length unit of
## used referenceEllipsoid, of which the default is meters).  Vectors and nD
## arrays are accepted if they have equal dimensions.
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
## All these coordinated must be either scalars or vectors or nD-arrays in which
## case all must have the same dimensions.
##
## Outputs:
## @itemize
## @item
## @var{az}, @var{el}, @var{slantrange}: look angles and distance to point
## under consideration (default units: degrees, degrees, and length unit of
## invoked referenceEllipsoid, of which default = meters).
## @end itemize
##
## Example:
## @example
## [az, el, slantrange] = ecef2aer (660930.192761082, -4701424.22295701, ...
##                                  4246579.60463288, 42, -82, 200, "wgs84")
## az = 33.000
## el = 70.000
## slantrange = 1000.00
## @end example
##
## With radians:
## @example
## [az, el, slantrange] = ecef2aer (660930.192761082,-4701424.22295701, ...
##                                  4246579.60463288, 0.73304, -1.4312, 200, ...
##                                  "wgs84", "rad")
## az = 0.57596
## el = 1.2217
## slantrange = 1000.0
## @end example
##
## @seealso{aer2ecef, ecef2enu, ecef2enuv, ecef2geodetic, ecef2ned, ecef2nedv,
## referenceEllipsoid}
##
## @end deftypefn

function [az, el, slantRange] = ecef2aer (varargin)

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
      error ("ecef2aer: spheroid or angleUnit expected for arg. #7");
    endif
  elseif (nargin == 8)
    spheroid = varargin{7};
    angleUnit = varargin{8};
  endif
  if (isnumeric (spheroid))
    spheroid = num2str (spheroid);
  endif

  x  = varargin{1};
  y  = varargin{2};
  z  = varargin{3};
  lat0 = varargin{4};
  lon0 = varargin{5};
  alt0 = varargin{6};
  if (! isnumeric (x)    || ! isreal (x)    || ...
      ! isnumeric (y)    || ! isreal (y)    || ...
      ! isnumeric (z)    || ! isreal (z)    || ...
      ! isnumeric (lat0) || ! isreal (lat0) ||  ...
      ! isnumeric (lon0) || ! isreal (lon0) || ...
      ! isnumeric (alt0) || ! isreal (alt0))
     error ("ecef2aer : numeric real input expected for first 6 input args.");
  endif
  if (! all (size (x) == size (y)) || ! all (size (y) == size (z)))
    error ("ecef2aer: non-matching dimensions of ECEF inputs.");
  endif
  if (! (isscalar (lat0) && isscalar (lon0) && isscalar (alt0)))
    ## Check if for each test point a matching obsrver point is given
    if (! all (size (lat0) == size (x)) || ...
        ! all (size (lon0) == size (y)) || ...
        ! all (size (alt0) == size (z)))
      error (["ecef2aer: non-matching dimensions of observer points and ", ...
              "target points"]);
    endif
  endif

  if (! ischar (angleUnit) || ! ismember (lower (angleUnit(1)), {"d", "r"}))
    error ("ecef2aer: angleUnit should be one of 'degrees' or 'radians'")
  endif

  E = sph_chk (spheroid);

  [e, n, u] = ecef2enu (x, y, z, lat0, lon0, alt0, E, angleUnit);
  [az, el, slantRange] = enu2aer (e, n, u, angleUnit);

endfunction

%!test
%! [az, el, slantrange] = ecef2aer (660930.192761082, -4701424.22295701, 4246579.60463288, 42, -82, 200);
%! assert ([az, el, slantrange], [33, 70, 1e3], 10e-6)

%!test
%! [az, el, slantrange] = ecef2aer (660930.192761082, -4701424.22295701, 4246579.60463288, 0.7330382858, -1.43116999, 200, "", "r");
%! assert ([az, el, slantrange], [0.57595865, 1.221730476, 1e3], 5e-3)

%!test
%! [az, el, slantrange] = ecef2aer (10766080.3, 14143607.0, 33992388.0, 42.3221, -71.3576, 84.7);
%! assert ([az, el, slantrange], [24.801, 14.619, 36271632.6754], 1e-3)

%!error <angleUnit> ecef2aer (45, 45, 100, 50, 50, 200, "", "km")
%!error <numeric real input expected>  ecef2aer ("A", 45, 100, 50, 50, 200)
%!error <numeric real input expected>  ecef2aer (45i, 45, 100, 50, 50, 200)
%!error <numeric real input expected>  ecef2aer (45, "A", 100, 50, 50, 200)
%!error <numeric real input expected>  ecef2aer (45, 45i, 100, 50, 50, 200)
%!error <numeric real input expected>  ecef2aer (45, 45, "A", 50, 50, 200)
%!error <numeric real input expected>  ecef2aer (45, 45, 100i, 50, 50, 200)
%!error <numeric real input expected>  ecef2aer (45, 45, 100, "A", 50, 200)
%!error <numeric real input expected>  ecef2aer (45, 45, 100, 50i, 50, 200)
%!error <numeric real input expected>  ecef2aer (45, 45, 100, 50, "A", 200)
%!error <numeric real input expected>  ecef2aer (45, 45, 100, 50, 50i, 200)
%!error <numeric real input expected>  ecef2aer (45, 45, 100, 50, 50, "A")
%!error <numeric real input expected>  ecef2aer (45, 45, 100, 50, 50, 200i)
%!error <non-matching> ecef2aer ([1 1], [2 2]', [3 3], 4, 5, 6)
%!error <non-matching> ecef2aer ([1 1], [2 2], [33], 4, 5, 6)
%!error <non-matching> ecef2aer ([1 1], [2 2], [3 3], [4 4], 5, 6)
%!error <non-matching> ecef2aer ([1 1], [2 2], [3 3], 4, [5 5], 6)
%!error <non-matching> ecef2aer ([1 1], [2 2], [3 3], [4; 4], [5; 5], [6; 6])

