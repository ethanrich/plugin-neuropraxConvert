## Copyright (C) 2022 The Octave Project Developers
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
## @deftypefn  {} {@var{lat}, @var{lon} =} gcxsc (@var{lat1}, @var{lon1}, @var{az}, @var{lat2}, @var{lon2}, @var{r1})
## @deftypefnx {} {@var{lat}, @var{lon} =} gcxsc (@var{lat1}, @var{lon1}, @var{az}, @var{lat2}, @var{lon2}, @var{r1}, @var{angleUnit})
## Determines the intersection points between a great circle and a small circle.
##
## Input:
## @itemize
## @item
## @var{lat1}, @var{lon1}, @var{az}: latitude, longitude, and azimuth of the
## great circle.  These must be scalar values or vectors of equal length.
## @end item
##
## @item
## @var{lat2}, @var{lon2}, @var{r2}: latitude, longitude, and range of the
## small circle.  These must be scalar values or vectors of equal length.
## @end item
##
## @item
## @var{angleUnit}: string for angular units ('degrees' or 'radians',
## case-insensitive, just the first character will do).  Default is 'degrees'.
## @var{angleUnit} applies to all inputs and outputs.
## @end item
## @end itemize
##
## Outputs:
##
## @itemize
## @item
## @var{lat} and @var{lon} are both Nx2 vectors of latitude(s) and longitude(s)
## of the intersection point(s).  Circle pair(s) that have no intersection
## points or happen to lie on the same axis (identical or antipodal centers)
## NaN values are returned. @*
## If only one output vlues was requested
## @end item
##
## @item
## Optional third output @var{istn}, if present, turns off warnings for
## coinciding circles or no intersections.  It is an Nx1 vector indicating
## the intersection situation of each input pair of circles, with for each
## circle pair the values:
##
## @table @asis
## @item 0
## The pair of circles has two distinct intersection points.
##
## @item 1
## The circles have identical axis, so are either coinciding or don't have
## any intersection points.
##
## @item 2
## The pair of circles have just one common intersection point (tangent).
##
## @item 3
## The pair of circles are disjoint, have no intersection points.
## @end table
## @item
## @end itemize
##
## Example
## @example
## [newlat, newlon] = gcxsc (60, 25, 20, 55, 25, 2.5)
## newlat =
##   53.806   57.286
## newlon =
##   21.226   23.182
## @end example
## @seealso{gc2sc, gcxgc, scxsc}
## @end deftypefn

function [lat, lon, st] = gcxsc (varargin)

  if (nargin < 6)
    print_usage ();
  elseif (nargin == 6)
    angleUnit = "degrees";
  else
    angleUnit = varargin{7};
  endif

  if (! (all (cellfun ("isnumeric", varargin(1:6)) && ...
         all (cellfun ("isreal", varargin(1:6))))))
     error ("gcxsc: numeric values expected for first six inputs");
  endif

  isv = ! cellfun ("isscalar", varargin(1:6));
  if (any (isv))
    ## At least one of the location inputs is a vector. Check sizes
    numval = cellfun ("numel", varargin(isv));
    if (any (diff (numval)))
      error ("gcxgc: all vector inputs must have same lengths");
    endif
    nv = max (numval);
    ## Make sure all inputs are column vectors of same length
    for ii=1:6
      if (isv(ii))
        varargin(ii) = {varargin{ii}(:)};
      else
        varargin(ii) = {(repmat (varargin{ii}, nv, 1))};
      endif
    endfor
  else
    nv = 1;
  endif

  vect = [varargin{1:6}];

  if (! ischar (angleUnit))
    error ("gcxsc: character value expected for 'angleUnit'");
  elseif (strncmpi (angleUnit, "degrees", min (length (angleUnit), 7)))
    ## Latitude must be within (-90, 90)
    if (any (abs (vect(:, [1 4])) >= 90))
       error("gcxsc: latitude value(s) out of acceptable range (-90, 90)")
     endif
  vect = deg2rad (vect);
  elseif (strncmpi (angleUnit, "radians", min (length (angleUnit), 7)))
    ## Latitude must be within (-pi/2, pi/2) as azimuth isn't defined there
    if (any (abs (vect(:, [1 4])) >= pi / 2))
       error("gcxsc: latitude value(s) out of acceptable range (-pi/2, pi/2)")
    endif
  else
    error ("gcxsc: illegal input for 'angleUnit'");
  endif

  [slat, slong, srg] = gc2sc (vect(1), vect(2), vect(3), "r");
  [lat, lon, st] = scxsc (slat, slong, srg, vect(4), vect(5), vect(6), "r");

  if (nargout < 3)
    if (any (st == 3))
      warning ("Octave:coinciding-small-circles", ...
          "scxsc: (some) circle pair(s) coincide.\n");
    endif
    if (any (st == 1))
      warning ("Octave:no-intersecting-circles", ...
               "scxsc: one or more circle pair(s) do not intersect.\n");
    endif
  endif

  if (strncmpi (angleUnit, "degrees", length (angleUnit)))
    lat = rad2deg (lat);
    lon = rad2deg (lon);
  endif

endfunction


%!test
%! [lat, lon] = gcxsc (60, 25, 20, 55, 25, 2.5);
%! assert (lat(1), 53.80564992, 1e-6);
%! assert (lon(1), 21.22598692, 1e-6);

%!error <numeric> gcxsc ("s", 0, 100, 10, 30, 0)
%!error <numeric> gcxsc (3i, 0, 100, 10, 30, 0)
%!error <numeric> gcxsc (50, "s", 100, 10, 30, 0)
%!error <numeric> gcxsc (50, 2i, 10, 10, 30, 0)
%!error <numeric> gcxsc (50, 0, "s", 10, 30, 0)
%!error <numeric> gcxsc (50, 0, 100i, 10, 30, 0)
%!error <numeric> gcxsc (50, 0, 100, "s", 30, 0)
%!error <numeric> gcxsc (50, 0, 100, 10i, 30, 0)
%!error <numeric> gcxsc (50, 0, 100, 10, "s", 0)
%!error <numeric> gcxsc (50, 0, 100, 10, 30i, 0)
%!error <numeric> gcxsc (50, 0, 100, 10, 30, "s")
%!error <numeric> gcxsc (50, 0, 100, 10, 30, 2i)
%!error <illegal> gcxsc (50, 0, 100, 10, 30, 0, "f")
%!error <illegal> gcxsc (50, 0, 100, 10, 30, 0, "degreef")
%!error <latitude value> gcxsc (190, 0, 90, -90.000001, 180, 80);
%!error <latitude value> gcxsc (190, 0, -90.001, -90.000001, 180, 80);
%!error <latitude value> gcxsc (pi/1.999, 0, pi/2, pi/2.0001, 2, 2*pi/3, "r");
