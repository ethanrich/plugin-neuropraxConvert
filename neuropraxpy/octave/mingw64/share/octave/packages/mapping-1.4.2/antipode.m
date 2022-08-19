## Copyright (C) 2017-2022 Philip Nienhuis
##
## This program is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program.  If not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {} {@var{lat_o, lon_o} =} antipode (@var{lat_i}, @var{lon_i})
## @deftypefnx {} {@var{lat_o, lon_o} =} antipode (@var{lat_i}, @var{lon_i}, @var{unit})
## Compute antipode (opposite point on globe).
##
## @var{lat_i} and @var{lon_i} (numeric values) are input latitude and
## longitude, optionally vectors.
##
## Optional character argument @var{unit} (case-insensitive) can be one
## of 'Degrees' or 'Radians' and can be used to specify the input
## units.  Just 'd' or 'r' will do.
##
## @end deftypefn

## Author: Philip Nienhuis <pr.nienhuis@users.sf.net>
## Created: 2017-03-02

function [lato, lono] = antipode (lati, loni, unit="")

  if (nargin < 2 || nargout < 2)
    print_usage ();
  elseif (! isnumeric (lati) || ! isnumeric (loni))
    error ("antipode: numeric arguments expected for latitude and longitude\n");
  elseif (! ischar (unit))
    error ("antipode: character argument expected for lat/lon unit\n");
  elseif (nargin >= 3 && ! ismember (lower (unit(1)), {"d", "r"}))
    error ("antipode: units must be one of 'Degrees' of 'Radians'");
  endif

  if (strncmpi (unit, "r", 1))
    convfac = 180.0 / pi;
    lati *= convfac;
    loni *= convfac;
  endif
  lato = -abs (180.0 - wrapTo360 (lati - 90.0)) + 90.0;
  lono = wrapTo180 (loni + 180);
  if (strncmpi (unit, "r", 1))
    lato /= convfac;
    lono /= convfac;
  endif

endfunction

%!test
%! [lato, lono] = antipode (90, 0);
%! assert ([lato, lono], [-90, 180], eps);

%!test
%! [lato, lono] = antipode (43, 15);
%! assert ([lato, lono], [-43, -165], eps);

%!test
%! [lato, lono] = antipode ([-365; -360; -315; -270; -225; -185; -180; -135; -90; -45; 0; 45; 90; 135; 180; 225; 270; 315; 360], ...
%!                          [-361; -359; -315; -270; -225; -185; -180; -135; -90; -45; 0; 45; 90; 135; 180; 225; 270; 315; 360]);
%! assert ([lato, lono], [[5; 0; -45; -90; -45; -5; 0; 45; 90; 45; 0; -45; -90; -45; 0; 45; 90; 45; 0], ...
%!        [179; -179; -135; -90; -45; -5; 0; 45; 90; 135; 180; -135; -90; -45; 0; 45; 90; 135; 180]], eps);

%!error <numeric argument> [a, b] = antipode ("a", 1);
%!error <Invalid call> a = antipode (0, 0);
%!error <Invalid call> [a, b] = antipode (0);
%!error <character argument expected> [a, b] = antipode (0, 0, 0);
%!error <units must be one> [a, b] = antipode (0, 0, "a");
