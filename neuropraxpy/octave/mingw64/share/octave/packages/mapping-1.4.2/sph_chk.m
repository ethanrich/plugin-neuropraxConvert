## Copyright (C) 2021-2022 The Octave Project Developers
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
## @deftypefn {} {@var{ref_ell} =} sph_chk (@var{spheroid})
## @deftypefnx {} {@var{ref_ell} =} sph_chk (@var{spheroid}, @var{req_fields})
## Check validity of iput ellipsoids / spheroids.
##
## Inputs:
## @itemize
## @item
## @var{spheroid}: input ellipsoid or spheroid.  Can be an ellipsoid or
## spheroid name, or ditto code (character string or scalar numeric value), or
## a numeric 2-element vector containing  SemimajorAxis and Eccentricity
## values, or an ellipsoid / spheroid struct.  If omitted a WGS84 ellipsoid
## struct is returned.
##
## @item
## @var{req_fields}: cellstr array of required fields of input ellipsoid /
## spheroid struct; only used/useful when an ellipsoid / spheroid struct
## value is given.  The default required fields are "SemimajorAxis",
## "Flattening" and "LengthUnit". @*
## Note: the validity of the fields input this way isn't checked!
## @end itemize
##
## Output: @*
## Ellipsoid / spheroid struct.
##
## @seealso{}
## @end deftypefn

function [E] = sph_chk (spheroid, req_flds = {"SemimajorAxis", "Flattening", "LengthUnit"})

  if (isempty (spheroid))
    E = wgs84Ellipsoid;
  elseif (isstruct (spheroid))
    E = spheroid;
    ## Check fields
    flds = isfield (E, req_flds);
    if (! all (flds))
      error ("Vital fields missing from ellipsoid: %s", ...
             sprintf ("%s  ", req_flds(! flds)));
    endif
  elseif (isnumeric (spheroid) && isreal (spheroid) && isvector (spheroid))
    if (numel (spheroid) != 2)
      error("sph_chk: 2-element vector expected");
    elseif (spheroid(1) < 1)
      E.Eccentricity = spheroid(1);
      E.SemimajorAxis = spheroid(2);
    elseif (spheroid(2) < 1)
      E.Eccentricity = spheroid(2);
      E.SemimajorAxis = spheroid(1);
    else
      error("sph_chk: eccentricity expected to be between 0 and 1");
    endif
  elseif (ischar (spheroid) || isnumeric (spheroid) && isscalar (spheroid))
    E = referenceEllipsoid (spheroid);
  endif

endfunction

