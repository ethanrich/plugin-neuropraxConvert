## Copyright (C) 2017-2022 Philip Nienhuis
##
## This program is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or (at
## your option) any later version.
##
## This program is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
## General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; see the file COPYING.  If not, see
## <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} {} earthRadius (@var{unit})
## Converts the Earth's radius into other units.
##
## Input argument @var{units} can be one of the units of validateLengthUnit.
## The default is meters.
##
## @example
## earthRadius ('km')
## => ans = 6371
## @end example
##
## @seealso{validateLengthUnit,unitsratio}
## @end deftypefn

function R = earthRadius (unit)

  radius = spheres_radius ("earth") * 1000;    ## This is the default in meters
  if (nargin == 0)
    R = radius; 
  elseif (nargin > 1)
    print_usage ();
  elseif ( ! ischar( unit ) )
    error ("earthRadius: string value expected");
  else
    ratio = unitsratio (unit , "Meters");
    R = radius * ratio;
  endif

endfunction

%!test
%! radius = earthRadius / 1000;;
%! assert (earthRadius ("km"), radius);
