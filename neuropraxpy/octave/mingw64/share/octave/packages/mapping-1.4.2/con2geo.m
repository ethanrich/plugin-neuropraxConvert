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
## @deftypefn {} {@var{phi} =} con2geo (@var{chi})
## @deftypefnx {} {@var{phi} =} con2geo (@var{chi}, @var{spheroid})
## @deftypefnx {} {@var{phi} =} con2geo (@var{chi}, @var{spheroid}, @var{angleUnit})
## Returns the geodetic latitude given latitude conformal @var{chi}
##
## Input
## @itemize
## @item
## @var{chi}: the conformal latitude(s).  Scalar, vector or nD arrays are
## accepted.
##
## @item
## (optional) @var{spheroid}: referenceEllipsoid parameter struct: the default
## is wgs84.
##
## @item
## (optional) @var{angleUnit}: string for angular units ('degrees' or 'radians',
## case-insensitive, just the first charachter will do). Default is 'degrees'.
## @end itemize
##
## Output
## @itemize
## @item
## @var{phi}: the geodetic latitude(s), shape similar to @var{chi}.
## @end itemize
##
## Example
## @example
## con2geo(44.8077)
## ans =  45.000
## @end example
## @seealso{geo2auth, geo2con, geo2iso, geo2rect, rect2geo}
## @end deftypefn

function [phi] = con2geo (chi, spheroid ="", angleUnit = "degrees")

   if (nargin < 1 || nargin > 3)
    print_usage();
  endif

  if (! isnumeric (chi) || ! isreal (chi))
    error ("con2geo: numeric input expected");
  endif

  E = sph_chk (spheroid);

  if (! ischar (angleUnit))
    error ("con2geo: character value expected for 'angleUnit'");
  elseif (strncmpi (angleUnit, "degrees", min (length (angleUnit), 7)))
    ## Latitude must be within [-90 ... 90]
    if (any (abs (chi) > 90))
      error ("con2geo: azimuth value(s) out of acceptable range [-90, 90]")
    endif
    chi = deg2rad (chi);
  elseif (strncmpi (angleUnit, "radians", min (length (angleUnit), 7)))
    ## Latitude must be within [-pi/2 ... pi/2]
    if (any (abs (chi) > pi / 2))
       error("con2geo: azimuth value(s) out of acceptable range (-pi/2, pi/2)")
    endif
  else
    error ("con2geo: illegal input for 'angleUnit'");
  endif

    ecc = E.Eccentricity;
    ## From Snyder's "Map Projections-A Working Manual" [pg 15].
    e2 = ecc ^ 2;
    e4 = ecc ^ 4;
    e6 = ecc ^ 6;
    e8 = ecc ^ 8;
    phi = chi + ...
          ((e2 / 2 + (5 /24) * e4 + e6 / 12 + (13 / 360) * e8) * sin (2 * chi)) + ...
          ((7/48 * e4 + (29 / 240) * e6  + (811 / 11520) * e8) * sin (4 * chi)) + ...
          (((7 / 120) * e6  + (81 / 1120) * e8)  * sin (6 * chi)) + ...
          (((4279 / 161280) * e8)  * sin (8 * chi));

  if (strncmpi (angleUnit, "degrees", length (angleUnit)))
    phi = rad2deg (phi);
  endif

endfunction


%!test
%! chi = [0:15:90];
%! phi = con2geo (chi);
%! Z = degrees2dm (phi - chi);
%! check = [0
%!          5.7891134
%!          10.01261
%!          11.538913
%!          9.9734791
%!          5.7499818
%!          0];
%! assert (Z(:,2), check, 1e-6)

%!error <numeric> con2geo ("s")
%!error <numeric> con2geo (5i)

