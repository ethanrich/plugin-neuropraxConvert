## Copyright (C) 2022 The Octave Project Developers
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
## @deftypefn {} {@var{aq} =} areaquad (@var{lat1}, @var{lon1}, @var{lat2}, @var{lon2})
## @deftypefnx {} {@var{aq} =} areaquad (@var{lat1}, @var{lon1}, @var{lat2}, @var{lon2}, @var{spheroid})
## @deftypefnx {} {@var{aq} =} areaquad (@var{lat1}, @var{lon1}, @var{lat2}, @var{lon2}, @var{angleUnit})
## @deftypefnx {} {@var{aq} =} areaquad (@var{lat1}, @var{lon1}, @var{lat2}, @var{lon2}, @var{spheroid}, @var{angleUnit})
## Returns the area of a quadrilateral given two points.
##
## If no ellipsoid is given the result will be a fraction of a unit sphere
## with a radius of one meter.  If an ellipsoid struct is supplied the result's
## unit will be the squared unit of that ellipsoid; otherwise, if just an
## ellipsoid name is given result will be in standard units squared (e.g., m^2).
##
## Input
## @itemize
## @item
## @var{lat1}, @var{lon1}: the first point of the quadrilateral.
##
## @item
## @var{lat2}, @var{lon2}: the second point of the quadrilateral.
## @end itemize
##
## @indentedblock
## These coordinate inputs be scalars, vectors or 2D arrays.  If any of these
## is non-scalar, all other LAT/LON inputs must either have the same size or
## be scalars.
## @end indentedblock
##
## @itemize
## @item
## (optional) @var{spheroid}: referenceEllipsoid parameter struct; default
## is 'Unit Sphere'.  A string value or EPSG code describing the
## spheroid is also accepted.  Alternatively, a numerical vector
## @code{[semimajoraxis eccentricity]} can be supplied.  If specified,
## @var{spheroid} must be the 5th input argument.
##
## @item
## (optional) @var{angleUnit}: string for angular units ('degrees' or
## 'radians', case-insensitive, just the first charachter will do).  Default
## is 'degrees'.  If specified, @var{angleUnit} must be the last input argument.
## @end itemize
##
## Output:
## @itemize
## @item
## @var{aq}: the area of the quadrilateral.  If one or more of the inputs were
## vectors or arrays, areaquad's output will have the same size.
## @end itemize
##
## Example
## No ellipsoid (fraction of a sphere)
## @example
## aq = areaquad (0, 0, 90, 360)
## aq =  0.50000
## @end example
##
## With radians
## @example
## aq = areaquad (0, 0, pi / 2 , 2 * pi, "radians")
## aq =  0.50000
## @end example
##
## With ellipsoid in m^2
## @example
## aq = areaquad (0, 0, 90, 360, "wgs84")
## aq =    2.5503e+14
## @end example
##
## With vector
## @example
## aq = areaquad(-90,0,90,360,[6000 0]);
## aq =    4.5239e+08
## @end example
##
## @seealso{referenceEllipsoid,referenceSphere}
## @end deftypefn

function [aq] = areaquad (varargin)

  spheroid  = "";
  angleUnit = "degrees";
  insq      = 0;          # When a spheriod is given the area is in units squared

  if (nargin < 4 || nargin > 6)
    print_usage();
  elseif (nargin == 5)
    if (isnumeric (varargin{5}))
      ## EPSG spheroid code
      spheroid = varargin{5};
    elseif (ischar (varargin{5}))
      if (! isempty (varargin{5}) && ismember (lower (varargin{5}(1)), {"r", "d"}))
        angleUnit = varargin{5};
      else
        spheroid = varargin{5};
      endif
    elseif (isstruct (varargin{5}))
      spheroid = varargin{5};
    else
      error ("areaquad: spheroid or angleUnit expected for arg. #5");
    endif
  elseif (nargin == 6)
    spheroid = varargin{5};
    angleUnit = varargin{6};
  endif
  if (isnumeric (spheroid) && isscalar (spheroid))
    spheroid = num2str (spheroid);
  endif

  if (! (all (cellfun ("isnumeric", varargin(1:4))) && ...
         all (cellfun ("isreal", varargin(1:4)))))
     error ("areaquad: numeric values expected for first four inputs");
  endif

  ism = ! cellfun ("isscalar", varargin(1:4));
  if (! isempty (find (ism)))
    ## Some of the location inputs are vector or matrix. Check those sizes
    sz = reshape (cell2mat (cellfun (@(x) size (x), varargin(ism), "uni", 0)), 2, [])';
    ## Check if matrix sizes are all identical
    if (numel (find (ism)) > 1 && any (diff (sz)))
      error ("areaquad: sizes of input location vectors/matrices must match.");
    endif
    ## Make sure all scalar inputs become matrices of same size
    varargin(! ism) = cellfun (@(x) repmat (x, sz(ism(1), 1), sz(ism(1), 2)), ...
                               varargin(! ism), "uni", 0);
  else
    nv = 1;
  endif
  lat1 = varargin{1};
  lon1 = varargin{2};
  lat2 = varargin{3};
  lon2 = varargin{4};

  if (! ischar (angleUnit))
    error ("areaquad: character value expected for 'angleUnit'");
  elseif (strncmpi (angleUnit, "degrees", min (length (angleUnit), 7)))
    ## Latitude must be within [-90 ... 90]
    if (any (abs ([lat1 lat2]) > 90))
      error ("areaquad: azimuth value(s) out of acceptable range [-90, 90]")
    endif
    lat1 = deg2rad (lat1);
    lon1 = deg2rad (lon1);
    lat2 = deg2rad (lat2);
    lon2 = deg2rad (lon2);
  elseif (strncmpi (angleUnit, "radians", min (length (angleUnit), 7)))
    ## Latitude must be within [-pi/2 ... pi/2] as azimuth isn't defined outside
    if (any (abs ([lat1 lat2]) > pi / 2))
       error("areaquad: azimuth value(s) out of acceptable range (-pi/2, pi/2)")
    endif
  else
    error ("areaquad: illegal input for 'angleUnit'");
  endif

  if (isempty (spheroid))
    E = referenceSphere ();
    insq = 1;            # Returns the fraction of the surface area
  else
    E = sph_chk (spheroid);
  endif

  a = E.SemimajorAxis;
  e = E.Eccentricity;
  s1 = sin (lat1);
  s2 = sin (lat2);
  del = lon1 - lon2;

  if (e < eps)
    aq = abs ((del .* a .^ 2) .* (s2 - s1));
  else
    ## From Earl Burkholder: 3d Global Spatial Data Model 2nd Ed. pg 168.
    ## Make the equation more readable
    e2 = e .^ 2;
    f = 1 ./ (2 .* e);
    e2m1 = 1 - e2;

    s21 = s1 .^ 2;

    s22 = s2 .^ 2;
    se1 = 1 - e2 .* s21;
    se2 = 1 - e2 .* s22;

    c  = (del .* a .^2 .* e2m1) ./ 2;
    t1 = 1 + e .* s1;
    t2 = 1 + e .* s2;

    b1 = 1 - e .* s1;
    b2 = 1 - e .* s2;

    g = f .* (log ( t2 ./ b2) - (log (t1 ./ b1)));

    aq = abs (c .* ((s2 ./ (se2)) - (s1 ./ (se1)) + g));
  endif

  if (insq == 1)
    aq = aq ./ E.SurfaceArea;
  endif

endfunction


%!test
%! aq = areaquad (-90, 0, 90, 360);
%! assert (aq, 1, 1e-8);

%!test
%! aq = areaquad (-pi / 2, 0, pi / 2, 2 * pi,"r");
%! assert (aq, 1, 1e-8);

%!test
%! aq = areaquad (0, 0, 90, 360, "wgs84");
%! assert (aq, 2.5503281086204421875e+14, 1e-8);

%!test
%! aq = areaquad(-90,0,90,360,[0 6000]);
%! assert (aq, 4 * pi * 6000 ^ 2, 1e-8)

%!test
%! aq = areaquad(-90,0,90,360,[6000 0]);
%! assert (aq, 4 * pi * 6000 ^ 2, 1e-8)

%!test
%! aq = areaquad(-90,0,90,360,[1 0]);
%! assert (aq, 4 * pi, 1e-8)

%!test
%! aq = areaquad(-90,0,90,360,[0 1]);
%! assert (aq, 4 * pi, 1e-8)

%!test
%! assert (areaquad ([-60 -45; -30 0], 0, 45, 180), ...
%! [0.393283046242, 0.353553390593; ...
%!  0.301776695296, 0.176776695296], 1e-11);

%!error <numeric> areaquad ("s", 0, 90, 360)
%!error <numeric> areaquad (5i, 0, 90, 360)
%!error <numeric> areaquad (0, "s", 90, 360)
%!error <numeric> areaquad (0, 5i, 90, 360)
%!error <numeric> areaquad (0, 0, "s", 360)
%!error <numeric> areaquad (0, 0, 5i, 360)
%!error <numeric> areaquad (0, 0, 90, "s")
%!error <numeric> areaquad (0, 0, 90, 5i)

%!error <ecc> areaquad (-90, 0, 90, 360, [2.9 6000])
%!error <ellipsoid> areaquad (-90, 0, 90, 360, [2.9])
%!error <element> areaquad (-90, 0, 90, 360, [2.9 6000 70])
%!error <azimuth value> areaquad (-91, 0, 90, 360);
%!error <azimuth value> areaquad (-90, 0, 91, 360);
%!error <sizes of> areaquad ([1 2], 3, [4; 5], 6);

