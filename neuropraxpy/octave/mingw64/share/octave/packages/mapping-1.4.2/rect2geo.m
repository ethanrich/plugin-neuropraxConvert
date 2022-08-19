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
## @deftypefn  {} {@var{phi} =} rect2geo (@var{mu})
## @deftypefnx {} {@var{phi} =} rect2geo (@var{mu}, @var{spheroid})
## @deftypefnx {} {@var{phi} =} rect2geo (@var{mu}, @var{spheroid}, @var{angleUnit})
## Returns the geodetic latitude given rectifying latitude @var{mu}
##
## Input
## @itemize
## @item
## @var{mu}: the rectifying latitude(s).  Can be a scalar value, a vector or
## an nD array.
##
## @item
## (optional) @var{spheroid}: referenceEllipsoid parameter struct: the
## default is wgs84.
##
## @item
## (optional) @var{angleUnit}: string for angular units ('degrees' or 'radians',
## case-insensitive, just the first character will do).  Default is 'degrees'.
## @end itemize
##
## Output
## @itemize
## @item
## @var{phi}: the geodetic latitude(s), same shape as @var{mu}.
## @end itemize
##
## Example
## @example
## rect2geo(44.856)
## ans =  45.000
## @end example
## @seealso{geo2auth, geo2con, geo2iso, geo2rect}
## @end deftypefn

function [phi] = rect2geo (mu, spheroid ="", angleUnit = "degrees")

  if (nargin < 1 || nargin > 3)
    print_usage();
  endif

  if (! isnumeric (mu) || ! isreal (mu))
    error ("rect2geo: numeric input expected");
  endif

  if (isnumeric (spheroid))
    spheroid = num2str (spheroid);
  endif
  E = sph_chk (spheroid);

  if (! ischar (angleUnit))
    error ("rect2geo: character value expected for 'angleUnit'");
  elseif (strncmpi (angleUnit, "degrees", min (length (angleUnit), 7)))
    ## Latitude must be within [-90 ... 90]
    if (any (abs (mu) > 90))
      error ("rect2geo: azimuth value(s) out of acceptable range [-90, 90]")
    endif
    mu = deg2rad (mu);
  elseif (strncmpi (angleUnit, "radians", min (length (angleUnit), 7)))
    ## Latitude must be within [-pi/2 ... pi/2]
    if (any (abs (mu) > pi / 2))
       error("rect2geo: azimuth value(s) out of acceptable range (-pi/2, pi/2)")
    endif
  else
    error ("rect2geo: illegal input for 'angleUnit'");
  endif

  if (isfield (E, "ThirdFlattening") == 1)
    n = E.ThirdFlattening;
  else
    ecc = E.Eccentricity;
    ## From Snyder's "Map Projections-A Working Manual" [pg 17].
    ecc1 = (1 - ecc ^ 2) ^ ( 1 / 2);
    n = (1 - ecc1) / (1 + ecc1);
  endif

  ## From R.E. Deakin "A FRESH LOOK AT THE UTM PROJECTION" [pg 5]
  n2 = n ^ 2;
  n3 = n ^ 3;
  n4 = n ^ 4;
  phi = mu + ...
        (((3 / 2) * n - (27 / 32) * n3) * sin (2 * mu)) + ...
        (((21 / 16) * n2 - (55 / 32) * n4) * sin (4 * mu)) + ...
        (((151 / 48) * n3) * sin (6 * mu)) + ...
        (((1097 / 512) * n4) * sin (8 * mu));

  if (strncmpi (angleUnit, "degrees", length (angleUnit)))
    phi = rad2deg (phi);
  endif

endfunction


%!test
%! mu = [0:15:90];
%! phi = rect2geo (mu);
%! Z = degrees2dm (phi - mu);
%! check = [0,
%!          4.3406136,
%!          7.5100085,
%!          8.6590367,
%!          7.4879718,
%!          4.3185768,
%!          0];
%! assert (Z(:,2), check, 1e-6)

%!error <numeric> rect2geo ("s")
%!error <numeric> rect2geo (5i)

