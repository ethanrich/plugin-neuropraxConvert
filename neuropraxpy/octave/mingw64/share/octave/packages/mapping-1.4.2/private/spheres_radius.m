## Copyright (C) 2013-2022 Carnë Draug <carandraug@octave.org>
##
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; if not, see <http://www.gnu.org/licenses/>.

## private function with mean planet radius

function radius = spheres_radius (obj)
  objects = struct ("sun",      694460,
                    "mercury",  2439,
                    "venus",    6051,
                    "earth",    6371,
                    "moon",     1738,
                    "mars",     3390,
                    "jupiter",  69882,
                    "saturn",   58235,
                    "uranus",   25362,
                    "neptune",  24622,
                    "pluto",    1151);
  obj = tolower (obj);
  if (! isfield (objects, obj))
    stack = dbstack;
    error ("%s: unknown SPHERE object", stack(2).name);
  endif
  radius = objects.(obj);
endfunction
