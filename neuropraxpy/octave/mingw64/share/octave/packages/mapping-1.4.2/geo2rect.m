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
## @deftypefn  {} {@var{mu} =} geo2rect (@var{phi})
## @deftypefnx {} {@var{mu} =} geo2rect (@var{phi}, @var{spheroid})
## @deftypefnx {} {@var{mu} =} geo2rect (@var{phi}, @var{spheroid}, @var{angleUnit})
## Returns the rectifying latitude given geodetic latitude @var{phi}
##
## Input
## @itemize
## @item
## @var{phi}: the geodetic latitude
## @end itemize
##
## @itemize
## @item
## (optional) @var{spheroid}: referenceEllipsoid name, EPSG code, or parameter
## struct: default is wgs84.
##
## @item
## (optional) @var{angleUnit}: string for angular units ('degrees' or 'radians',
## case-insensitive, just the first character will do). Default is 'degrees'.
## @end itemize
##
## Output
## @itemize
## @item
## @var{mu}: the rectifying latitude
## @end itemize
##
## Example
## @example
## geo2rect(45)
## ans =  44.856
## @end example
## @seealso{geo2auth, geo2con, geo2iso}
## @end deftypefn

function [mu] = geo2rect (phi, spheroid ="", angleUnit = "degrees")

  if (nargin < 1 || nargin > 3)
    print_usage();
  endif

  if (! isnumeric (phi) || ! isreal (phi))
    error ("geo2rect: numeric input expected");
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
    error ("geo2rect: character value expected for 'angleUnit'");
  elseif (strncmpi (angleUnit, "degrees", min (length (angleUnit), 7)))
    ## Latitude must be within [-90 ... 90]
    if (any (abs (phi) > 90))
      error ("geo2rect: azimuth value(s) out of acceptable range [-90, 90]")
    endif
    phi = deg2rad (phi);
  elseif (strncmpi (angleUnit, "radians", min (length (angleUnit), 7)))
    ## Latitude must be within [-pi/2 ... pi/2]
    if (any (abs (phi) > pi / 2))
       error("geo2rect: azimuth value(s) out of acceptable range (-pi/2, pi/2)")
    endif
  else
    error ("geo2rect: illegal input for 'angleUnit'");
  endif

  m = meridianarc (0, phi, E);
  m_p = meridianarc (0, pi / 2, E);

  mu = pi / 2 .* m ./ m_p;

  if (strncmpi (angleUnit, "degrees", length (angleUnit)))
    mu = rad2deg (mu);
  endif

endfunction


%!test
%! mu = geo2rect (45);
%! Z = degrees2dm(mu - 45);
%! assert (Z(:,2), -8.65908066558504, 1e-6);

%!error <numeric> geo2rect ("s")
%!error <numeric> geo2rect (5i)

