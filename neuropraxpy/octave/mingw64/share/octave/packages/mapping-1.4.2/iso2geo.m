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
## @deftypefn  {} {@var{psi} =} iso2geo (@var{phi})
## @deftypefnx {} {@var{psi} =} iso2geo (@var{phi}, @var{spheroid})
## @deftypefnx {} {@var{psi} =} iso2geo (@var{phi}, @var{spheroid}, @var{angleUnit})
## Returns the isometric latitude given geodetic latitude @var{phi}
##
## Input
## @itemize
## @item
## @var{phi}: the geodetic latitude(s).  Can be a scalar, vector or ND-array.
## @end itemize
##
## @itemize
## @item
## (optional) @var{spheroid}: referenceEllipsoid.  For admissible values see
## `referenceEllipsoid`.  The default value is 'WGS84'.
##
## @item
## (optional) @var{angleUnit}: string for angular units ('degrees' or 'radians',
## case-insensitive, just the first charachter will do).  Default is 'degrees'.
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
## iso2geo (45)
## ans =  41.170
## @end example
## @seealso{geo2auth, geo2con, geo2iso, geo2rect}
## @end deftypefn

function [phi] = iso2geo (psi, spheroid = "", angleUnit = "degrees")

  if (nargin < 1 || nargin > 3)
    print_usage();
  endif

  if (! isnumeric (psi) || ! isreal (psi))
    error ("iso2geo: numeric input expected");
  endif

  E = sph_chk(spheroid);

  if (! ischar (angleUnit))
    error ("iso2geo: character value expected for 'angleUnit'");
  elseif (strncmpi (angleUnit, "degrees", min (length (angleUnit), 7)))
    psi = deg2rad (psi);
  elseif (! strncmpi (angleUnit, "radians", min (length (angleUnit), 7)))
    error ("iso2geo: illegal input for 'angleUnit'");
  endif

  ## From Snyder's "Map Projections-A Working Manual" [pg 15].
  chi = 2 * atan (exp (psi)) - pi / 2;
  phi = con2geo (chi, E, "radians");

  if (strncmpi (angleUnit, "degrees", length (angleUnit)))
    phi = rad2deg (phi);
  endif

endfunction

%!test
%! psi = iso2geo (50.227465817);
%! assert (psi, 45, 1e-6)

%!test
%! assert(iso2geo (geo2iso ([-90 : 10: 0; 0 : 10 : 90]), "wgs84"), ...
%! [-90 : 10: 0; 0 : 10 : 90], 1e-8);

%!error <numeric> iso2geo ("s")
%!error <numeric> iso2geo (5i)

