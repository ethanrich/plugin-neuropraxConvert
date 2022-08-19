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
## @deftypefn  {} {@var{psi} =} geo2iso (@var{phi})
## @deftypefnx {} {@var{psi} =} geo2iso (@var{phi}, @var{spheroid})
## @deftypefnx {} {@var{psi} =} geo2iso (@var{phi}, @var{spheroid}, @var{angleUnit})
## Return the isometric latitude given geodetic latitude @var{phi}.
##
## Input
## @itemize
## @item
## @var{phi}: the geodetic latitude.  Can be a scalar value, a vector or an
## ND-array.
## @end itemize
##
## @itemize
## @item
## (optional) @var{spheroid}: referenceEllipsoid.  For admissible values see
## `referenceEllipsoid.m`.  The default ellipsoid is WGS84.
## is wgs84.
##
## @item
## (optional) @var{angleUnit}: string for angular units ('degrees' or 'radians',
## case-insensitive, just the first character will do).  Default is 'degrees'.
## @end itemize
##
## Output
## @itemize
## @item
## @var{psi}: the isometric latitude(s), same shape as @var{phi}.
## @end itemize
##
## Example
## @example
## geo2iso (45)
## ans =  50.227
## @end example
## @seealso{geo2auth, geo2con, geo2rect, iso2geo}
## @end deftypefn

function [psi] = geo2iso (phi, spheroid = "", angleUnit = "degrees")

  if (nargin < 1 || nargin > 3)
    print_usage();
  endif

  if (! isnumeric (phi) || ! isreal (phi))
    error ("geo2iso: numeric input expected");
  endif

  E = sph_chk (spheroid);

  if (! ischar (angleUnit))
    error ("geo2iso: character value expected for 'angleUnit'");
  elseif (strncmpi (angleUnit, "degrees", min (length (angleUnit), 7)))
    ## Latitude must be within [-90 ... 90]
    if (any (abs (phi) > 90))
      error ("geo2iso: azimuth value(s) out of acceptable range [-90, 90]")
    endif
    phi = deg2rad (phi);
  elseif (strncmpi (angleUnit, "radians", min (length (angleUnit), 7)))
    ## Latitude must be within [-pi/2 ... pi/2]
    if (any (abs (phi) > pi / 2))
       error("geo2iso: azimuth value(s) out of acceptable range (-pi/2, pi/2)")
    endif
  else
    error ("geo2iso: illegal input for 'angleUnit'");
  endif

  ## Some previously tried solutions:

  ## https://en.wikipedia.org/wiki/Latitude#Isometric_latitude
  ## ecc = E.Eccentricity;
  ## psi = asinh (tan (phi)) - ecc .* atanh (ecc .* sin (phi));

  ## From Snyder's "Map Projections - A Working Manual" [pg 15]. Eq (3-7)
  ## psi = log(tan(pi/4+phi/2)*((1-ecc.*sin(phi))/(1+ecc.*sin(phi)))^(ecc/2));

  ## From Snyder's "Map Projections - A Working Manual" [pg 15]. Eq (3-8)
  chi = geo2con (phi, E, "radians");
  psi = log (tan (pi / 4 + chi / 2));

  psi(psi < -5.24) = -Inf;
  psi(psi >  5.24) =  Inf;

  if (strncmpi (angleUnit, "degrees", length (angleUnit)))
    psi = rad2deg (psi);
  endif

endfunction


%!test
%! psi = geo2iso (45);
%! assert (psi, 50.227465817, 1e-6)

%!test
%! psi = geo2iso ([-90 90]);
%! assert (psi, [-Inf Inf])

%!test
%! chi = geo2iso (iso2geo ([-90 : 10: 0; 0 : 10 : 90]), "wgs84");
%! assert (chi, [-90 : 10: 0; 0 : 10 : 90], 1e-6);

%!error <numeric> geo2iso ("s")
%!error <numeric> geo2iso (5i)

