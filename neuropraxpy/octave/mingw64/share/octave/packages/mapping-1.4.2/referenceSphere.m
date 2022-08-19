## Copyright (C) 2022 John W. Eaton
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
## @deftypefn {Function File} {} referenceSphere (@var{name}, @var{unit})
## Return the parameters of the named spherical object.
##
## Valid names are "Unit Sphere", "Sun", "Sun", "Mercury", "Venus",
## "Earth", "Moon", "Mars", "Jupiter", "Saturn", "Uranus", "Neptune",
## and "Pluto".  Case is not important.
##
## @var{unit} can be the name of any unit accepted by function
## validateLengthUnit.m.  Also here case is not important.
##
## The output consists of a scalar struct with fields "Name", "LengthUnit",
## "Radius", "SemimajorAxis", "SemiminorAxis", "InverseFlattening",
## "Eccentricity", "Flattening", "ThirdFlattening", "MeanRadius",
## "SurfaceArea", and "Volume".
##
## Examples:
##
## @example
## >> E = referenceSphere ()
## E =
##
##   scalar structure containing the fields:
##
##     Name = Unit Sphere
##     LengthUnit =
##     Radius = 1
##     SemimajorAxis = 1
##     SemiminorAxis = 1
##     InverseFlattening = Inf
##     Eccentricity = 0
##     Flattening = 0
##     ThirdFlattening = 0
##     MeanRadius = 1
##     SurfaceArea = 12.566
##     Volume = 4.1888
## @end example
##
## @example
## >> E = referenceSphere ("Earth", "km")
## E =
##
##   scalar structure containing the fields:
##
##     Name = Earth
##     LengthUnit = km
##     Radius = 6371
##     SemimajorAxis = 6371
##     SemiminorAxis = 6371
##     InverseFlattening = Inf
##     Eccentricity = 0
##     Flattening = 0
##     ThirdFlattening = 0
##     MeanRadius = 6371.0
##     SurfaceArea = 5.1006e+08
##     Volume = 1.0832e+12
## @end example
##
## @seealso{validateLengthUnit, referenceEllipsiod}
## @end deftypefn

## Parts of this function were adapted from referenceEllipsoid.

function Sph = referenceSphere (name = "unit", unit = "")

  if (! ischar (name))
    error ("referenceSphere: NAME must be a string");
  endif

  if (! ischar (unit))
    error ("referenceSphere: units name expected for input arg. #2");
  endif

  switch (lower (name))
    case "sun"
      Name = "Sun";
      Radius = 694460000;

    case "mercury"
      Name = "Mercury";
      Radius = 2439000;

    case "venus"
      Name = "Venus";
      Radius = 6051000;

    case "earth"
      Name = "Earth";
      Radius = 6371000;

    case "moon"
      Name = "Moon";
      Radius = 1738000;

    case "mars"
      Name = "Mars";
      Radius = 3390000;

    case "jupiter"
      Name = "Jupiter";
      Radius = 69882000;

    case "saturn"
      Name = "Saturn";
      Radius = 58235000;

    case "uranus"
      Name = "Uranus";
      Radius = 25362000;

    case "neptune"
      Name = "Neptune";
      Radius = 24622000;

    case "pluto"
      Name = "Pluto";
      Radius = 1151000;

    case "unit"
      Name = "Unit Sphere";
      Radius = 1.0;

    otherwise
      error ("referenceSphere: unrecognized sphere: %s", name);

  endswitch

  if (! strcmpi (name, "unit") && isempty (unit))
    if (nargin == 2)
      error ("referenceSphere: UNIT may not be empty for %s", Name);
    else
      unit = "Meters";
    endif
  endif

  Sph = param_calc (Name, Radius, unit);

endfunction


function sph = param_calc (Name, Radius, unit)

  if (! isempty (unit))
    ratio = unitsratio (unit, "Meters");
    Radius = Radius * ratio;
  endif

  sph.Name              = Name;
  sph.LengthUnit        = unit;
  sph.Radius            = Radius;
  sph.SemimajorAxis     = Radius;
  sph.SemiminorAxis     = Radius;
  sph.InverseFlattening = Inf;
  sph.Eccentricity      = 0;
  sph.Flattening        = 0;
  sph.ThirdFlattening   = 0;
  sph.MeanRadius        = Radius;
  sph.SurfaceArea       = 4 * pi * Radius^2;
  sph.Volume            = (4 * pi) / 3 * Radius^3;

endfunction


%!test
%! U = referenceSphere ("Unit");
%! assert (U.LengthUnit, "");
%! assert (U.Radius, 1);
%! assert (U.SemimajorAxis, 1);
%! assert (U.SemiminorAxis, 1);
%! assert (U.InverseFlattening, Inf);
%! assert (U.Eccentricity, 0);
%! assert (U.Flattening, 0);
%! assert (U.ThirdFlattening, 0);
%! assert (U.MeanRadius, 1);
%! assert (U.SurfaceArea, 4*pi);
%! assert (U.Volume, 4*pi/3);

%!error <NAME must be a string> referenceSphere (7i)
%!error <unrecognized sphere> referenceSphere ("yy")
%!error <unknown unit> referenceSphere ("Unit", "##not a unit@@")
