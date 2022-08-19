## Copyright (C) 2014-2022 Carnë Draug <carandraug@octave.org>
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
## @deftypefn {Function File} {[@var{deg1}, @var{deg2}, @dots{}] =} toDegrees (@var{fromUnit}, @var{a1}, @var{a2}, @dots{})
## Convert angles into degrees.
##
## Converts any number of input arguments, @var{a1}, @var{a2}, @dots{}
## with angles in @var{fromUnit}, into degrees.  @var{fromUnit} may be
## @qcode{"radians"} or @qcode{"degrees"}.
##
## @example
## @group
## [deg1, deg2] = toDegrees ("radians", pi, [pi 2*pi])
## @result{deg1}  [ 180 ]
## @result{deg2}  [ 180  360 ]
## @end group
## @end example
##
## @seealso{fromDegrees, fromRadians, rad2deg, toRadians, unitsratio}
## @end deftypefn

## Author: Carnë Draug <carandraug@octave.org>

function varargout = toDegrees (fromUnit, varargin)

  if (nargin < 1)
    print_usage ();
  endif

  valid_unit = validatestring (fromUnit, {"radians", "degrees"}, "toDegrees", "FROMUNIT");
  switch (valid_unit(1))
    case {"r"}
      varargout = cellfun (@rad2deg, varargin, "UniformOutput", false);
    case {"d"}
      varargout = varargin;
  endswitch

endfunction

%!test
%! rad{1} = pi;
%! rad{2} = [pi 2*pi];
%! rad{3} = [0 pi; 2*pi 0];
%! deg{1} = 180;
%! deg{2} = [180 360];
%! deg{3} = [0 180; 360 0];
%! for i=1:3
%!   assert (toDegrees ("degrees", deg{i}), deg{i})
%!   assert (toDegrees ("radians", rad{i}), deg{i})
%! endfor
%!
%! ## test multiple angles same time
%! assert (nthargout (1:3, @toDegrees, "radians", rad{:}), deg)
%! assert (nthargout (1:2, @toDegrees, "radians", rad{:}), deg(1:2))
%!
%! ## test abbreviations of degrees
%! assert (nthargout (1:3, @toDegrees, "radian", rad{:}), deg)
%! assert (nthargout (1:3, @toDegrees, "rad", rad{:}), deg)
%! assert (nthargout (1:3, @toDegrees, "r", rad{:}), deg)

%!error toRadians ("INVALID")
