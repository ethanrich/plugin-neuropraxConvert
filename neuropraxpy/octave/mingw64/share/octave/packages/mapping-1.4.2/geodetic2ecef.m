## Copyright (C) 2018-2022 Philip Nienhuis
##
## This program is free software; you can redistribute it and/or modify it under
## the terms of the GNU General Public License as published by the Free Software
## Foundation; either version 3 of the License, or (at your option) any later
## version.
##
## This program is distributed in the hope that it will be useful, but WITHOUT
## ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
## FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
## details.
##
## You should have received a copy of the GNU General Public License along with
## this program; if not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} {@var{X}, @var{Y}, @var{Z} =} geodetic2ecef (@var{lat}, @var{lon}, @var{alt})
## @deftypefnx {Function File} {@var{X}, @var{Y}, @var{Z} =} geodetic2ecef (@var{spheroid}, @var{lat}, @var{lon}, @var{alt})
## @deftypefnx {Function File} {@var{X}, @var{Y}, @var{Z} =} geodetic2ecef (@dots{}, @var{angleUnit})
## @deftypefnx {Function File} {@var{X}, @var{Y}, @var{Z} =} geodetic2ecef (@var{lat}, @var{lon}, @var{alt}, @var{spheroid})
## Convert from geodetic coordinates to Earth Centered Earth Fixed (ECEF)
## coordinates.
##
## Inputs:
## @itemize
## @item
## @var{spheroid} ia user-specified sheroid (see referenceEllipsoid); it can
## be omitted or given as an ampty string, in which case WGS84 will be the
## default spheroid.  Unfortunately EPSG numbers cannot be accepted.
##
## Inputting @var{spheroid} as 4th argument is accepted but not recommended;
## in that case the @var{lat} and @var{lon} inputs are required to be in
## radians.
##
## @item
## @var{lat}, @var{lon} (both angle) and @var{alt} (length) are latitude,
## longitude and height, respectively and can each be scalars.  Vectors or
## nD arrays are accepted but must all have the exact same size and
## dimension(s).  @var{alt}'s length unit is that of the invoked reference
## ellipsoid, whose default is meters.  For the default angle unit see below.
##
## Note: height is relative to the reference ellipsoid, not the geoid.  Use
## e.g., egm96geoid to compute the height difference between the geoid and
## the WGS84 reference ellipsoid.
##
## @item
## @var{angleUnit} can be "degrees" (= default) or "radians".  The default is
## degrees, unless @var{spheroid} was given as as 4th input argument in which
## case @var{angleUnit} is in radians and cannot be changed.
## @end itemize
##
## Ouputs:
## @itemize
## @item
## The output arguments @var{X}, @var{Y}, @var{Z} (Earth-Centered Earth Fixed
## coordinates) are in the length units of the invoked ellipsoid and have the
## same sizes and dimensions as input arguments @var{lat}, @var{lon} and
## @var{alt}.
## @end itemize
##
## Example:
## @example
## Aalborg GPS Centre
## lat=57.02929569;
## lon=9.950248114;
## h= 56.95; # meters
## >> [X, Y, Z] = geodetic2ecef ("", lat, lon, h)
## X =     3426949.39675307
## Y =     601195.852419885
## Z =     5327723.99358255
## @end example
## @seealso{ecef2geodetic, geodetic2aer, geodetic2enu, geodetic2ned, egm96geoid,
## referenceEllipsoid}
## @end deftypefn

## Function supplied by anonymous contributor, see:
## https://savannah.gnu.org/patch/index.php?9658

function [X, Y, Z] = geodetic2ecef (varargin)

  ip = 0;
  spheroid = "";
  angleUnit = "degrees";
  if (nargin < 3 || nargin > 5)
    print_usage ();
  elseif (nargin == 3)
    ## Assume just Lat, Lon and Alt given
  elseif (nargin == 4)
    if (isnumeric (varargin{1}))
      ## Find out if arg #4 = angleunit or spheroid
      if (isnumeric (varargin{4}) || isstruct (varargin{4}))
        ## Probably EPGS code => spheroid, or a spheroid struct right away
        spheroid = varargin{4};
      elseif (ischar (varargin{4}))
        if (ismember (varargin{4}(1), {"r", "d"}))
          ## Supposedly an angleUnit
          angleUnit = varargin{4};
        else
          ## Can only be name of spheroid
          spheroid = varargin{4};
        endif
      else
        error ("geodetic2ecef: spheroid or angleUnit expected for arg. #4");
      endif
    else
      ip = 1;
      spheroid = varargin{1};
    endif
  elseif (nargin == 5)
    ip = 1;
    spheroid = varargin{1};
    angleUnit = varargin{5};
  endif
  lat = varargin{ip + 1};
  lon = varargin{ip + 2};
  alt = varargin{ip + 3};

  if (! isnumeric (lat) || ! isreal (lat) || ...
      ! isnumeric (lon) || ! isreal (lon) || ...
      ! isnumeric (alt) || ! isreal (alt))
    error ("geodetic2ecef: numeric real input expected");
  endif
  if (! all (size (lat) == size (lon)) || ! all (size (lon) == size (alt)))
    error ("geodetic2ecef: non-matching dimensions of ECEF inputs.");
  endif

  if (! ischar (angleUnit) || ! ismember (lower (angleUnit(1)), {"d", "r"}))
    error ("geodetic2ecef: angleUnit should be one of 'degrees' or 'radians'")
  endif

  if (isnumeric (spheroid))
    spheroid = num2str (spheroid);
  endif
  E = sph_chk (spheroid);

  if (strncmpi (lower (angleUnit), "r", 1) == 1)
    c_p = cos (lat);
    s_p = sin (lat);

    c_l = cos (lon);
    s_l = sin (lon);
  else
    c_p = cosd (lat);
    s_p = sind (lat);

    c_l = cosd (lon);
    s_l = sind (lon);
  endif


  ## Insight From: Algorithms for Global Positioning pg 42
  N = E.SemimajorAxis ./ sqrt (1 - E.Eccentricity ^ 2 * s_p .^ 2);
  X = (N + alt) .* (c_p .* c_l) ;
  Y = (N + alt) .* (c_p .* s_l) ;
  Z = (N .* (1 - E.Flattening) ^ 2  + alt) .* s_p;

endfunction


%!test
%!shared h
%! latd = 57.02929569;
%! lond = 9.950248114;
%! h = 56.95; ## meters
%! [x, y, z]=geodetic2ecef("wgs84", latd, lond, h);
%! assert ([x, y, z], [3426949.397, 601195.852, 5327723.994], 10e-3);

%!test
%! lat = deg2rad (57.02929569);
%! lon = deg2rad (9.950248114);
%! [x2, y2, z2] = geodetic2ecef ("wgs84", lat, lon, h, "radians");
%! assert ([x2, y2, z2], [3426949.397, 601195.852, 5327723.994], 10e-3);

%!error <angleUnit> geodetic2ecef ("", 45, 45, 50, "km")
%!error <numeric real input expected>  geodetic2ecef ("", "A", 45, 50)
%!error <numeric real input expected>  geodetic2ecef ("", 45i, 45, 50)
%!error <numeric real input expected>  geodetic2ecef ("", 45, "B", 50)
%!error <numeric real input expected>  geodetic2ecef ("", 45, 45i, 50)
%!error <numeric real input expected>  geodetic2ecef ("", 45, 45, "C")
%!error <numeric real input expected>  geodetic2ecef ("", 45, 45, 50i)

