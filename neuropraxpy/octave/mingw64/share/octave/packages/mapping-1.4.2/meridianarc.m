## Copyright (C) 2019-2022 Philip Nienhuis
##
## This program is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or (at
## your option) any later version.
##
## This program is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSEll. See the GNU
## General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; see the file COPYING.  If not, see
## <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn  {Function File} {@var{s} =}  meridianarc (@var{phi}, @var{phi_2})
## @deftypefnx {Function File} {@var{s} =}  meridianarc (@var{phi}, @var{phi_2}, @var{spheroid})
## @deftypefnx {Function File} {@var{s} =}  meridianarc (@dots{}, @var{angleUnit})
## Returns the meridian arc length given two latitudes @var{phi} and @var{phi_2}.
##
## @var{phi} and @var{phi_2} can be scalars, vectors or arrays of any desired
## size and dimension; but if any is non-scalar, the other must be scalar or
## have the exact same dimensions.  For any @var{phi_2} larger than @var{phi}
## the output value will be negative.
##
## If no spheroid is given the default is wgs84.
##
## @var{angleUnit} can be 'degrees' or 'radians' (the latter is default).
##
## Examples
## Full options:
## @example
## s = meridianarc (0, 56, "int24", "degrees")
## => s =
## 6.2087e+06
## @end example
## Short version:
## @example
## s = meridianarc (0, pi/4)
## => s =
## 4.9849e+06
## @end example
## If want different units:
## @example
## s = meridianarc (0, 56, referenceEllipsoid ("int24", "km"), "degrees")
## => s =
## 6208.7
## @end example
## @seealso{referenceEllipsoid}
## @end deftypefn

## Function supplied by anonymous contributor, see:
## https://savannah.gnu.org/patch/index.php?9720

function s = meridianarc (phi, phi_2, spheroid="", angleUnit="radians")

  persistent intv = "-pi/2, pi/2";
  persistent degintv = "-90, 90";

  if (nargin < 2)
    print_usage ();
  endif

  if (strncmpi (lower (angleUnit), "degrees", numel (angleUnit)) == 1)
    phi = deg2rad (phi);
    phi_2 = deg2rad (phi_2);
    intv = degintv;
  endif
  ## Check on identical input sizes or one scalar
  if (! isscalar (phi))
    if (isscalar (phi_2))
      phi_2 = phi_2 * ones (size (phi));
    elseif (! numel (size (phi) == numel (size (phi_2))) || ...
        ! all (size(phi) == size (phi_2)))
      error ("meridianarc: both inputs must have same size and dimensions");
    endif
  elseif (! isscalar (phi_2))
    if (isscalar (phi))
      phi = phi * ones (size (phi_2));
    elseif (! numel (size (phi) == numel (size (phi_2))) || ...
        ! all (size(phi) == size (phi_2)))
      error ("meridianarc: both inputs must have same size and dimensions");
    endif
  endif
  if (abs (phi) > pi / 2 || abs (phi_2) > pi / 2)
    error ("meridianarc: latitudes must lie in interval [%s]", intv);
  endif

  if (isempty (spheroid))
    E = referenceEllipsoid ("wgs84");
  else
    if (isnumeric (spheroid))
      spheroid = num2str (spheroid);
    endif
    E = sph_chk (spheroid);
  endif


  ## From: Algorithms for global positioning. Kai Borre and Gilbert Strang pg 373
  ## Note: Using integral instead of Taylor Expansion
  if (isstruct (spheroid))
    E = spheroid;
  elseif (ischar (spheroid))
    E = referenceEllipsoid (spheroid);
  else
    error ("meridianarc: spheroid must be a string or a stucture");
  endif

  e_sq = E.Eccentricity ^ 2;
  F = @(x) ((1 - e_sq * sin(x) ^ 2) ^ (-3 / 2));
  s = zeros (size (phi));
  for ii=1:numel (phi)
    s(ii) = E.SemimajorAxis * (1 - e_sq) * quad ( F, phi(ii), phi_2(ii), 1.0e-12);
  end %for

endfunction

%!test
%! s = meridianarc (0, 56, "int24", "degrees");
%! assert (s, 6208700.08662672, 1e-6)

%!test
%! s = meridianarc ([-1/120; 45-1/120; 89+119/120], [1/120; 45+1/120; 90], ...
%!                  "int24", "degrees");
%! assert (s, [1842.92463205; 1852.25585828; 1861.66609497/2], 1e-6);

%!error <latitudes> meridianarc (-2, 2)
%!error <latitudes> meridianarc (-91, 91, "", "d")

