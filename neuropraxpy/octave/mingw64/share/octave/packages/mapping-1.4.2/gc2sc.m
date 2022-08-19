## Copyright (C) 2020-2022  The Octave Project Developers
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
## @deftypefn {Function File} {[@var{lato}, @var{lono}, @var{radius}] = } {gc2sc (@var{lati}, @var{loni}, @var{az})}
## @deftypefnx {Function File} {[@var{lato}, @var{lono}] = } {gc2sc (@var{lati}, @var{loni}, @var{az}, @var{units})}
## @deftypefnx {Function File} { @var{mat} = } gc2sc (@var{lati}, @var{loni}, @var{az})
## @deftypefnx {Function File} { @var{mat} = } gc2sc (@var{lati}, @var{loni}, @var{az}, @var{units})
##
## Converts a great circle to small circle notation.
##
## Input:
## @itemize
## @item
## @var{lat}, @var{lon}, @var{az}: latitude, longitude, and azimuth of
## great circle.  These must be scalar values or vectors of equal length.
## @end item
##
## @item
## @var{angleUnit} (optional): string for angular units ('degrees' or 'radians',
## case-insensitive, just the first character will do).  Default is 'degrees'.
## @var{angleUnit} applies to all inputs and outputs.
## @end item
## @end itemize
##
## Output
## @itemize
## @item
## If separate outpts were requested, @var{lat}, @var{lon} are scalars (or
## column vectors) of the small circle(s)' centerpoint(s) and @var{radius} is
## a scalar (or column vector) of the small circle(s) radius (radii) which will
## always be 90 degrees.
## @end item
##
## @item
## Alternatively, if just one output was requested the result will be an Nx3
## matrix with columns @var{lato}, @var{lono} and @var{radius}, respectively.
## @end item
## @end itemize
##
## Example
## @example
## [lat, lon, radius] = gc2sc( 60, 25, 60)
## lat = -25.659
## lon =  58.690
## radius =  90
## @end example
##
## For the equator a 0 will be returned for the longitude.
## @example
## [lat, lon, radius] = gc2sc (0, 45, 90)
## lat = -90
## lon = 0
## radius =  90
## @end example
## @seealso{gcxgc, gcxsc, scxsc}
## @end deftypefn

function [lat, lon, radius] = gc2sc (varargin);

  if (nargin < 3)
    print_usage ();
  elseif (nargin == 3)
    angleUnit = "degrees";
  else
    angleUnit = varargin{4};
  endif

  if (! (all (cellfun ("isnumeric", varargin(1:3)) && ...
         all (cellfun ("isreal", varargin(1:3))))))
     error ("gc2sc: numeric values expected for first three inputs");
  endif

  isv = ! cellfun ("isscalar", varargin(1:3));
  if (any (isv))
    ## At least one of the location inputs is a vector. Check sizes
    numval = cellfun ("numel", varargin(isv));
    if (any (diff (numval)))
      error ("gc2sc: all vector inputs must have same lengths");
    endif
    ## Make sure all inputs are column vectors of same length
    for ii=1:3
      if (isv(ii))
        varargin(ii) = {varargin{ii}(:)};
      else
        varargin(ii) = {(repmat (varargin{ii}, numval(1), 1))};
      endif
    endfor
  endif
  vect = [varargin{1:3}];

  if (! ischar (angleUnit))
    error ("gc2sc: character value expected for 'angleUnit'");
  elseif (strncmpi (angleUnit, "degrees", min (length (angleUnit), 7)))
    if (any (abs (vect(1)) > 90))
       error("gc2sc: latitude value out of acceptable range (-90, 90)")
    endif
    vect = deg2rad (vect);
  elseif (strncmpi (angleUnit, "radians", min (length (angleUnit), 7)))
    if (any (abs (vect(1)) > pi / 2))
       error("gc2sc: latitude value out of acceptable range (-pi/2, pi/2)")
    endif
  else
    error ("gc2sc: illegal input for 'angleUnit'")
  endif

  range = pi / 2;
  radius = repmat (range, size (vect(:, 1)));
  [lat, lon] = reckon (vect(:, 1), vect(:, 2), range, vect(:, 3) + range, "radians");

  if (abs (abs (lat) - pi / 2) < (4 * eps))
    ## NOTE: You are at the pole many longitudes so NaN should be used
    ## However for computations use 0
    lon = 0;
  endif

  if (strncmpi (angleUnit, "degrees", length (angleUnit)))
    lat    = rad2deg (lat);
    lon    = rad2deg (lon);
    radius = rad2deg (radius);
  endif

  if (nargout == 1)
    lat = [lat, lon, radius];
  endif

endfunction

%!test
%! [lat, lon, radius] = gc2sc (60, 25, 60);
%! assert (lat, -25.6589, 1e-5)
%! assert (lon, 58.69006, 1e-5)

%!test
%! [lat, lon, radius] = gc2sc (0, 45, 90);
%! assert (lat, -90, 1e-5)
%! assert (lon, 0, 1e-5)

%! m = gc2sc (45, [0:45:360], 45);
%! assert (m(:, 1), repmat (-30.0, 9, 1), 1e-10);
%! assert (m(:, 2), [  54.73561031725;   99.73561031725;  144.73561031725; ...
%!                   -170.26438968276; -125.26438968276;  -80.26438968276; ...
%!                    -35.26438968276;    9.73561031725;   54.73561031725], 1e-10);
%! assert (m(:, 3), repmat (90.0, 9, 1), 1e-10);

%!error <numeric> gc2sc ("s", 0, 100)
%!error <numeric> gc2sc (3i, 0, 100)
%!error <numeric> gc2sc (50, "s", 100)
%!error <illegal> gc2sc (50, 0, 100, "f")
%!error <illegal> gc2sc (50, 0, 100, "degreef")
%!error <latitude value> gc2sc (190, 0, 90);
%!error <latitude value> gc2sc (-91, 0, -90.001);
%!error <latitude value> gc2sc (pi/1.999, 0, pi/2, "r");

