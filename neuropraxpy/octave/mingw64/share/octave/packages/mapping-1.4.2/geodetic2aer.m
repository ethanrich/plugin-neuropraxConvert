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
## @deftypefn  {Function File} {@var{az}, @var{el}, @var{slantRange} =} geodetic2aer (@var{lat}, @var{lon}, @var{alt}, @var{lat0}, @var{lon0}, @var{alt0})
## @deftypefnx {Function File} {@var{az}, @var{el}, @var{slantRange} =} geodetic2aer (@var{lat}, @var{lon}, @var{alt}, @var{lat0}, @var{lon0}, @var{alt0}, @var{spheroid})
## @deftypefnx {Function File} {@var{az}, @var{el}, @var{slantRange} =} geodetic2aer (@var{lat}, @var{lon}, @var{alt}, @var{lat0}, @var{lon0}, @var{alt0}, @var{spheroid}, @var{angleUnit})
## Convert from geodetic coordinates (latitude, longitude, local height) to
## Azimuth, Elevation and Range (AER) coordinates.
##
## Inputs:
## @itemize
## @item
## @var{lat}, @var{lon}, @var{alt}:  ellipsoid geodetic coordinates of target
## point(s) (angle, angle, length).  In case of non-scalar inputs (i.e.,
## multiple points) the dimensions (vectors, nD arrays) of each of these
## inputs should match.  The length unit is that of the used ellipsoid
## (default is meters).
##
## @item
## @var{lat0}, @var{lon0}, @var{alt0}: ellipsoid geodetic coordinates of local
## observer (angle, angle, length).  In case of multiple observer locations
## their numbers and dimensions should match those of the target points (i.e.,
## one observer location for each test point).  The length units of the
## point(s) and observer location(s) should match.
##
## @item
## @var{spheroid} is a user-specified sheroid (see referenceEllipsoid).  It
## can be spcifid as a referenceEllipsoid struct, a name or an EPSG number.  If
## omitted WGS84 will be selected as default spheroid and the default length
## will then be meters.
##
## @item
## @var{angleUnit}: string for angular units ('degrees' or 'radians',
## case-insensitive, just the first character will do).  Default is 'degrees'.
## @end itemize
##
## Outputs:
## @itemize
## @item
## @var{e}, @var{n}, @var{u}:  East, North, Up Cartesian coordinates
## (meters).
## @end itemize
##
## Example:
## @example
## lat  = 42.002; lon  = -81.998; alt  = 1000;
## lat0 = 42;     lon0 = -82;     alt0 = 200;
## [e, n, u] = geodetic2aer (lat, lon, alt, lat0, lon0, alt0, "wgs84", "degrees")
## -->
##    az =  36.719
##    el =  70.890
##    slantRange =  846.65
## @end example
##
## @seealso{aer2geodetic, geodetic2ecef, geodetic2enu, geodetic2ned,
## referenceEllipsoid}
## @end deftypefn

## Function adapted by anonymous contributor, see:
## https://savannah.gnu.org/patch/index.php?9918

function [az, el, slantRange] = geodetic2aer (varargin)

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
      error ("geodetic2aer: spheroid or angleUnit expected for arg. #7");
    endif
  elseif (nargin == 8)
    spheroid = varargin{7};
    angleUnit = varargin{8};
  endif

  lat  = varargin{1};
  lon  = varargin{2};
  alt  = varargin{3};
  lat0 = varargin{4};
  lon0 = varargin{5};
  alt0 = varargin{6};
  if (! isnumeric (lat)  || ! isreal (lat)  || ...
      ! isnumeric (lon)  || ! isreal (lon)  || ...
      ! isnumeric (alt)  || ! isreal (alt)  || ...
      ! isnumeric (lat0) || ! isreal (lat0) ||  ...
      ! isnumeric (lon0) || ! isreal (lon0) || ...
      ! isnumeric (alt0) || ! isreal (alt0))
     error ("geodetic2aer: numeric input expected");
  endif

  if (! all (size (lat) == size (lon)) || ! all (size (lon) == size (alt)))
    error ("geodetic2aer: non-matching dimensions of inputs.");
  endif
  if (! (isscalar (lat0) && isscalar (lon0) && isscalar (alt0)))
    ## Check if for each test point a matching obsrver point is given
    if (! all (size (lat0) == size (lat)) || ...
        ! all (size (lon0) == size (lon)) || ...
        ! all (size (alt0) == size (alt)))
      error (["geodetic2aer: non-matching dimensions of geodetic locations ", ...
              "and AER target points"]);
    endif
  endif

  if (isnumeric (spheroid))
    spheroid = num2str (spheroid);
  endif
  E = sph_chk (spheroid);

  if (! ischar (angleUnit) || ! ismember (lower (angleUnit(1)), {"d", "r"}))
    error ("geodetic2aer: angleUnit should be one of 'degrees' or 'radians'")
  endif

  [e, n, u] = geodetic2enu (lat, lon, alt, lat0, lon0, alt0, E, angleUnit);
  [az, el, slantRange] = enu2aer (e, n, u, angleUnit);

endfunction


%!test
%! lat  = 42.002582; lon = -81.997752; alt = 1139.7;
%! lat0 = 42; lon0 = -82; alt0 = 200;
%! [az, el, slantRange] = geodetic2aer (lat, lon, alt, lat0, lon0, alt0);
%! assert([az, el, slantRange], [33, 70, 1000], 10e-3);

%!test
%! Rad=deg2rad([42.002582, -81.997752, 42, -82, 33, 70]);
%! alt = 1139.7; alt0 = 200;
%! [az, el, slantRange] = geodetic2aer(Rad(1), Rad(2), alt, Rad(3), Rad(4), alt0, "rad");
%! assert([az, el, slantRange], [Rad(5), Rad(6), 1000], 10e-3);

%!test
%! [g, h, k] = geodetic2aer (45.977, 7.658, 4531, 46.017, 7.750, 1673);
%! assert ([g, h, k], [238.075833, 18.743875, 8876.843345], 1e-6);

%!error <angleUnit> geodetic2aer (45, 45, 100, 50, 50, 200, "", "km")
%!error <numeric input expected>  geodetic2aer ("A", 45, 100, 50, 50, 200)
%!error <numeric input expected>  geodetic2aer (45i, 45, 100, 50, 50, 200)
%!error <numeric input expected>  geodetic2aer (45, "A", 100, 50, 50, 200)
%!error <numeric input expected>  geodetic2aer (45, 45i, 100, 50, 50, 200)
%!error <numeric input expected>  geodetic2aer (45, 45, "A", 50, 50, 200)
%!error <numeric input expected>  geodetic2aer (45, 45, 100i, 50, 50, 200)
%!error <numeric input expected>  geodetic2aer (45, 45, 100, "A", 50, 200)
%!error <numeric input expected>  geodetic2aer (45, 45, 100, 50i, 50, 200)
%!error <numeric input expected>  geodetic2aer (45, 45, 100, 50, "A", 200)
%!error <numeric input expected>  geodetic2aer (45, 45, 100, 50, 50i, 200)
%!error <numeric input expected>  geodetic2aer (45, 45, 100, 50, 50, "A")
%!error <numeric input expected>  geodetic2aer (45, 45, 100, 50, 50, 200i)

