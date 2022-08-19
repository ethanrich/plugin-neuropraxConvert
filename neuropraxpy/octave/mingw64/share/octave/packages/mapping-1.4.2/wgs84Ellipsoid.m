## Copyright (C) 2018-2022 Philip Nienhuis
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
## @deftypefn {Function File} {} wgs84Ellipsoid (@var{unit})
##
## Returns the parameters of the wgs84 ellipsoid. Argument @var{unit} is
## optional and if given, should be one of the units recognized by function
## validateLengthUnit().
##
## Example:
## @example
## >> E = wgs84Ellipsoid
## E =
##
##  scalar structure containing the fields:
##
##    Code =  7030
##    Name = World Geodetic System 1984
##    LengthUnit = meter
##    SemimajorAxis =  6378137
##    SemiminorAxis =    6.3568e+06
##    InverseFlattening =  298.26
##    Eccentricity =  0.081819
##    Flattening =  0.0033528
##    ThirdFlattening =  0.0016792
##    MeanRadius =    6.3710e+06
##    SurfaceArea =    5.1007e+14
##    Volume =    1.0832e+21
## @end example
##
## A unit argument is also accepted:
## @example
## >> E = wgs84Ellipsoid ("km")
## E =
##
##  scalar structure containing the fields:
##
##    Code =  7030
##    Name = World Geodetic System 1984
##    LengthUnit = km
##    SemimajorAxis =  6378.1
##    SemiminorAxis =  6356.8
##    InverseFlattening =  298.26
##    Eccentricity =  0.081819
##    Flattening =  0.0033528
##    ThirdFlattening =  0.0016792
##    MeanRadius =  6371.0
##    SurfaceArea =    5.1007e+08
##    Volume =    1.0832e+12
## @end example
## @seealso{referenceEllipsoid, validateLengthUnit}
## @end deftypefn

## Function supplied by anonymous contributor, see:
## https://savannah.gnu.org/patch/index.php?9634

function Ell = wgs84Ellipsoid (unit)

  if ! nargin 
    unit = "meter";
  end
  
  Ell = referenceEllipsoid ("wgs84", unit);

endfunction
