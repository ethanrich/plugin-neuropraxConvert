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
## @deftypefn  {} {@var{xi} =} geo2auth (@var{phi})
## @deftypefnx {} {@var{xi} =} geo2auth (@var{phi}, @var{spheroid})
## @deftypefnx {} {@var{xi} =} geo2auth (@var{phi}, @var{spheroid}, @var{angleUnit})
## Returns the authalic latitude given geodetic latitude @var{phi}
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
## parameter struct: the default is wgs84.
##
## @item
## (optional) @var{angleUnit}: string for angular units ('degrees' or 'radians',
## case-insensitive, just the first charachter will do).  Default is 'degrees'.
## @end itemize
##
## Output
## @itemize
## @item
## @var{xi}: the authalic latitude
## @end itemize
##
## Example
## @example
## geo2auth(45)
## ans =  44.872
## @end example
## @seealso{geo2con, geo2iso, geo2rect}
## @end deftypefn


function [xi] = geo2auth (phi, spheroid ="", angleUnit = "degrees")

  if (nargin < 1 || nargin > 3)
    print_usage();
  endif

  if (! isnumeric (phi) || ! isreal (phi))
    error ("geo2auth: numeric input expected");
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
    error ("geo2auth: character value expected for 'angleUnit'");
  elseif (strncmpi (angleUnit, "degrees", min (length (angleUnit), 7)))
    ## Latitude must be within [-90 ... 90]
    if (any (abs (phi) > 90))
      error ("geo2auth: azimuth value(s) out of acceptable range [-90, 90]")
    endif
    phi = deg2rad (phi);
  elseif (strncmpi (angleUnit, "radians", min (length (angleUnit), 7)))
    ## Latitude must be within [-pi/2 ... pi/2]
    if (any (abs (phi) > pi / 2))
       error ("geo2auth: azimuth value(s) out of acceptable range (-pi/2, pi/2)");
    endif
  else
    error ("geo2auth: illegal input for 'angleUnit'");
  endif


  ecc = E.Eccentricity;

  em = 1 - ecc .^ 2;
  sp = sin (phi);

  q_p = 1 + ((em ./ ecc) .* atanh(ecc));

  q   = (em .* sp) ./ (1 - ecc .^ 2 .* sp .^2) + ...
        ((em ./ ecc) .* atanh(ecc .* sp));

  xi  = asin (q ./ q_p);

  if (strncmpi (angleUnit, "degrees", length (angleUnit)))
    xi = rad2deg (xi);
  endif

endfunction

%!test
%! phi = [0:15:90];
%! xi = geo2auth (phi);
%! Z = degrees2dm(xi - phi);
%! check = [0; ...
%! -3.84258303680237; ...
%! -6.66017793242659; ...
%! -7.69782759396364; ...
%! -6.67286580689009; ...
%! -3.85527095139878; ...
%!           0];
%! assert (Z(:,2), check, 1e-6)

%!error <numeric> geo2auth ("s")
%!error <numeric> geo2auth (5i)

