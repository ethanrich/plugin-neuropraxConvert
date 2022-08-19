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
## @deftypefn {Function File} {[@var{a1}, @var{a2}, @dots{}] =} fromRadians (@var{toUnit}, @var{rad1}, @var{rad2}, @dots{})
## Convert angles from radians.
##
## Converts any number of input arguments, @var{rad1}, @var{rad2}, @dots{}
## with angles in radians, into @var{toUnit} which may be @qcode{"radians"} or
## @qcode{"degrees"}.
##
## @example
## @group
## [a1, a2] = fromRadians ("degrees", pi, [pi 2*pi])
## @result{a1}  [ 180 ]
## @result{a2}  [ 180  360 ]
## @end group
## @end example
##
## @seealso{fromDegrees, rad2deg, toDegrees, toRadians, unitsratio}
## @end deftypefn

## Author: Carnë Draug <carandraug@octave.org>

function varargout = fromRadians (toUnit, varargin)

  if (nargin < 1)
    print_usage ();
  endif

  valid_unit = validatestring (toUnit, {"radians", "degrees"}, "fromRadians", "TOUNIT");
  switch (valid_unit(1))
    case {"d"}
      varargout = cellfun (@rad2deg, varargin, "UniformOutput", false);
    case {"r"}
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
%!   assert (fromRadians ("degrees", rad{i}), deg{i})
%!   assert (fromRadians ("radians", rad{i}), rad{i})
%! endfor
%!
%! ## test multiple angles same time
%! assert (nthargout (1:3, @fromRadians, "degrees", rad{:}), deg)
%! assert (nthargout (1:2, @fromRadians, "degrees", rad{:}), deg(1:2))
%!
%! ## test abbreviations of degrees
%! assert (nthargout (1:3, @fromRadians, "degree", rad{:}), deg)
%! assert (nthargout (1:3, @fromRadians, "deg", rad{:}), deg)
%! assert (nthargout (1:3, @fromRadians, "d", rad{:}), deg)

%!error fromRadians ("INVALID")
