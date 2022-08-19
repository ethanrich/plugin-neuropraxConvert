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
## @deftypefn {} {@var{chi} =} geo2con (@var{phi})
## @deftypefnx {} {@var{chi} =} geo2con (@var{phi}, @var{spheroid})
## @deftypefnx {} {@var{chi} =} geo2con (@var{phi}, @var{spheroid}, @var{angleUnit})
## Returns the conformal latitude given geodetic latitude @var{phi}
##
## Input
## @itemize
## @item
## @var{phi}: the geodetic latitude
## @end itemize
##
## @itemize
## @item
## (optional) @var{spheroid}: referenceEllipsoid name, EPSG number, or
## parameter struct: the deualt is wgs84.
##
## @item
## (optional) @var{angleUnit}: string for angular units ('degrees' or 'radians',
## case-insensitive, just the first charachter will do). Default is 'degrees'.
## @end itemize
##
## Output
## @itemize
## @item
## @var{chi}: the conformal latitude
## @end itemize
##
## Example
## @example
## geo2con(45)
## ans =  44.808
## @end example
## @seealso{geo2auth, geo2iso, geo2rect}
## @end deftypefn

function [chi] = geo2con (phi, spheroid ="", angleUnit = "degrees")

   if (nargin < 1 || nargin > 3)
    print_usage();
  endif

  if (! isnumeric (phi) || ! isreal (phi))
    error ("geo2con: numeric input expected");
  endif

  if (isempty (spheroid))
    E = referenceEllipsoid ("wgs84");
  else
    if (isnumeric (spheroid))
      spheroid = num2str (spheroid);
    endif
    E = sph_chk (spheroid);
  endif

  if (! ischar (angleUnit))
    error ("geo2con: character value expected for 'angleUnit'");
  elseif (strncmpi (angleUnit, "degrees", min (length (angleUnit), 7)))
    ## Latitude must be within [-90 ... 90]
    if (any (abs (phi) > 90))
      error ("geo2con: azimuth value(s) out of acceptable range [-90, 90]")
    endif
    phi = deg2rad (phi);
  elseif (strncmpi (angleUnit, "radians", min (length (angleUnit), 7)))
    ## Latitude must be within [-pi/2 ... pi/2]
    if (any (abs (phi) > pi / 2))
       error("geo2con: azimuth value(s) out of acceptable range (-pi/2, pi/2)")
    endif
  else
    error ("geo2con: illegal input for 'angleUnit'");
  endif

  ecc = E.Eccentricity;

  chi = atan (sinh (asinh (tan (phi)) - ecc .* atanh (ecc .* sin (phi))));

  if (strncmpi (angleUnit, "degrees", length (angleUnit)))
    chi = rad2deg (chi);
  endif

endfunction


%!test
%! phi = [0:15:90];
%! chi = geo2con (phi);
%! Z = degrees2dm(chi - phi);
%! check = [0; ...
%!     -5.755543956550260; ...
%!     -9.979077451140980; ...
%!     -11.53895663467140; ...
%!     -10.00703049899710; ...
%!     -5.783497189944170; ...
%!           0];
%! assert (Z(:,2), check, 1e-6)

%!error <numeric> geo2con ("s")
%!error <numeric> geo2con (5i)

