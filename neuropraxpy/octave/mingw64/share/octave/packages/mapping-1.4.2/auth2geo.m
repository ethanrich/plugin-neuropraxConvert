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
## @deftypefn  {} {@var{phi} =} auth2geo (@var{xi})
## @deftypefnx {} {@var{phi} =} auth2geo (@var{xi}, @var{spheroid})
## @deftypefnx {} {@var{phi} =} auth2geo (@var{xi}, @var{spheroid}, @var{angleUnit})
## Returns the geodetic latitude given authalic latitude @var{xi}.
##
## Input
## @itemize
## @item
## @var{xi}: the authalic latitude(s); scalar, vector or nD array.
##
## @item
## (optional) @var{spheroid}: referenceEllipsoid name, EPSG code, or parameter
## struct: the default is wgs84.
##
## @item
## (optional) @var{angleUnit}: string for angular units ('degrees' or 'radians',
## case-insensitive, just the first charachter will do).  Default is 'degrees'.
## @end itemize
##
## Output
## @itemize
## @var{phi}: the geodetic latitude(s), shape matching that of @var{xi}.
## @item
## @end itemize
##
## Example
## @example
## auth2geo(44.872)
## ans =  45.000
## @end example
## @seealso{geo2auth, geo2con, geo2iso, geo2rect}
## @end deftypefn


function [phi] = auth2geo (xi, spheroid = "", angleUnit = "degrees")

  if (nargin < 1 || nargin > 3)
    print_usage();
  endif

  if (! isnumeric (xi) || ! isreal (xi))
    error ("auth2geo: numeric input expected");
  endif

  if (isnumeric (spheroid))
    spheroid = num2str (spheroid);
  endif
  E = sph_chk (spheroid);

  if (! ischar (angleUnit))
    error ("auth2geo: character value expected for 'angleUnit'");
  elseif (strncmpi (angleUnit, "degrees", min (length (angleUnit), 7)))
    ## Latitude must be within [-90 ... 90]
    if (any (abs (xi) > 90))
      error ("auth2geo: azimuth value(s) out of acceptable range [-90, 90]")
    endif
    xi = deg2rad (xi);
  elseif (strncmpi (angleUnit, "radians", min (length (angleUnit), 7)))
    ## Latitude must be within [-pi/2 ... pi/2]
    if (any (abs (phi) > pi / 2))
       error("auth2geo: azimuth value(s) out of acceptable range (-pi/2, pi/2)")
    endif
  else
    error ("auth2geo: illegal input for 'angleUnit'");
  endif


  ecc = E.Eccentricity;
  ## From Snyder's "Map Projections-A Working Manual" [pg 16].
  e2 = ecc ^ 2;
  e4 = ecc ^ 4;
  e6 = ecc ^ 6;
  phi = xi + ...
        (((e2 / 3) + (31 / 180) * e4 + (517 /5040) * e6) * sin(2 * xi)) + ...
        (((23 / 360) * e4 + (251 / 3780) * e6) * sin(4 * xi)) + ...
        (((761 / 45360) * e6) * sin(6 * xi));

  if (strncmpi (angleUnit, "degrees", length (angleUnit)))
    phi = rad2deg (phi);
  endif

endfunction


%!test
%! xi = [0:15:90];
%! phi = auth2geo (xi);
%! Z = degrees2dm(phi - xi);
%! check = [0
%!          3.8575173
%!          6.6751024
%!          7.6978157
%!          6.6579355
%!          3.8403504
%!          0];
%! assert (Z(:,2), check, 1e-6)

%!error <numeric> auth2geo ("s")
%!error <numeric> auth2geo (5i)

