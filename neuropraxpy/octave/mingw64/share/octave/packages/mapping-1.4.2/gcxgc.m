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
## @deftypefn  {} {@var{lat}, @var{lon} =} gcxgc (@var{lat1}, @var{lon1}, @var{az1}, @var{lat2}, @var{lon2}, @var{az2})
## @deftypefnx {} {@var{lat}, @var{lon} =} gcxgc (@var{lat1}, @var{lon1}, @var{az1}, @var{lat2}, @var{lon2}, @var{az2}, @var{angleUnit})
## @deftypefnx {} {@var{lat}, @var{lon}, @var{idl} =} gcxgc (@dots{})
## @deftypefnx {} {@var{latlon} =} gcxgc (@dots{})
## Determines the intersection points between two great circles.
##
## Input:
## @itemize
## @item
## @var{lat1}, @var{lon1}, @var{az1}: latitude, longitude, and azimuth of
## great circle #1.  These must be scalar values or vectors of equal length.
## @end item
##
## @item
## @var{lat2}, @var{lon2}, @var{az2}: latitude, longitude, and azimuth of
## great circle #2.  These must be scalar values or vectors of equal length.
## @end item
##
## @item
## @var{angleUnit}: string for angular units ('degrees' or 'radians',
## case-insensitive, just the first character will do).  Default is 'degrees'.
## @var{angleUnit} applies to all inputs and outputs.
## @end item
## @end itemize
##
## Output: @*
## The shape of the output depends on the number of requested outputs.
##
## @itemize
## @item
## If two outputs were requested:
## If scalar values have been input, @var{lat} and @var{lon} are both 1x2
## vectors.  If vectors have been input @var{lat} and @var{lon} are Nx2 arrays
## where N is the number of great circle pairs.  The results for multiple
## great circle pairs are concatenated vertically no matter the orientation of
## input vectors.
## @end item
##
## @item
## If just one output was requested, the @var{lat} and @var{lon} values are
## concatenated into an Nx4 array, where N is 1 in case of scalar inputs and
## in case in input vector(s) N is the size of them.
## @end item
##
## @item
## If three outputs were requested the first two output are @var{lat} and
## @var{lon}, third output @var{st} lists pairs of coinciding great circles,
## if any.  In this case warnings for coinciding circles are suppressed.
## @end item
## @end itemize
##
## Example:
## @example
## lat1 = 51.8853;
## lon1 = 0.2545;
## az1  = 108.55;
## lat2 = 49.0034;
## lon2 =  2.5735;
## az2  =  32.44;
## [newlat, newlon] = gcxgc (lat1, lon1, az1, lat2, lon2, az2)
## newlat =
##   50.908  -50.908
## newlon =
##     4.5086  -175.4914
## @end example
## @end deftypefn


function [lat, lon, idl] = gcxgc (varargin)

  if (nargin < 6)
    print_usage();
  elseif (nargin == 6)
    angleUnit = "degrees";
  else
    angleUnit = varargin{7};
  endif

  if (! (all (cellfun ("isnumeric", varargin(1:6)) && ...
         all (cellfun ("isreal", varargin(1:6))))))
     error ("gcxgc: numeric values expected for first six inputs");
  endif

  isv = ! cellfun ("isscalar", varargin(1:6));
  if (any (isv))
    ## At least one of the location inputs is a vector. Check sizes
    numval = cellfun ("numel", varargin(isv));
    if (any (diff (numval)))
      error ("gcxgc: all vector inputs must have same lengths");
    endif
    nv = numval(1);
    ## Make sure all inputs are column vectors of same length
    for ii=1:6
      if (isv(ii))
        varargin(ii) = {varargin{ii}(:)};
      else
        varargin(ii) = {(repmat (varargin{ii}, numval(1), 1))};
      endif
    endfor
  else
    nv = 1;
  endif
  vect = [varargin{1:6}];

  if (! ischar (angleUnit))
    error ("gcxgc: character value expected for 'angleUnit'");
  elseif (strncmpi (angleUnit, "degrees", min (length (angleUnit), 7)))
    ## Latitude must be within (-90, 90) as azimuth isn't defined there
    if (any (abs (vect(:, [1 4])) >= 90))
       error("gcxgc: azimuth value(s) out of acceptable range (-90, 90)")
    endif
  vect = deg2rad (vect);
  elseif (strncmpi (angleUnit, "radians", min (length (angleUnit), 7)))
    ## Latitude must be within (-pi/2, pi/2) as azimuth isn't defined there
    if (any (abs (vect(:, [1 4])) >= pi / 2))
       error("gcxgc: azimuth value(s) out of acceptable range (-pi/2, pi/2)")
    endif
  else
    error ("gcxgc: illegal input for 'angleUnit'");
  endif

  [lat, lon] = get_intscs (vect);

  ## Check for coinciding great circles. Done by comparing Longitudes where
  ## they cross the equator.
  ## 1. Find circles with azimuth = lat == 0 (as those ARE on equator)
  iaz0 = double (abs (rem (vect(:, [3 6]) + pi/2, pi)) < 2 * eps & ...
                 abs (vect(:, [1 4])) < 2 * eps);
  iaz0 = (iaz0(1:nv) + iaz0(nv+1:end))';     # Sum iaz0 by rows
  ## vect(iaz0==2, :) => two great circles equaling equators => set to NaN & skip
  lat(iaz0 > 1.5, :) = NaN;
  lon(iaz0 > 1.5, :) = NaN;
  ## vect(iaz0==1, :) => just one circle = equator => no coinciding pair => skip too
  nv -= numel (find (iaz0 > 0));
  iazx = find (! iaz0);
  ## 2. Intersections with equator for all other pairs
  [~, loni1] = ...
   get_intscs ([(zeros (nv, 2)), (pi / 2 * ones (nv, 1)), vect(iazx, 1:3)]);
  [~, loni2] = ...
   get_intscs ([(zeros (nv, 2)), (pi / 2 * ones (nv, 1)), vect(iazx, 4:6)]);
  ## Just comparing longitudes of intersections on one hemisphere, plus
  ## azimuth values will do.
  ## 3. First select those
  id1 = loni1(:, 1) <= 0;
  loni1(id1, 1) = loni1(id1, 2);
  id2 = loni2(:, 1) <= 0;
  loni2(id2, 1) = loni2(id2, 2);
  ## 4. Find out which loni's coincide
  idl = (abs (loni1(:, 1) - loni2(:, 1)) < 2 * eps)(:, 1) & abs (id1 - id2);
  ## 5. Set output relating to coinciding great circles to NaN, NaN
  lat(iazx(idl), :) = NaN;
  lon(iazx(idl), :) = NaN;
  idl = sort ([(find (iaz0 > 1.5)) iazx(find (idl))]);
  if (nargout < 3)
    if (! isempty (idl))
      warning ("Octave:coinciding-great-circles", ...
               "gcxgc: non-unique intersection(s).\n")
    endif
  endif

  if (strncmpi (angleUnit, "degrees", length (angleUnit)))
    lat = rad2deg (lat);
    lon = rad2deg (lon);
  endif

  if (nargout <= 1)
    lat = [lat lon];
  endif

endfunction


function [lat, lon] = get_intscs (vect)

  ## Algorithm from https://www.movable-type.co.uk/scripts/latlong-vectors.html#intersection
  c1(:, 1) =  sin (vect(:, 2)) .* cos (vect(:, 3)) - sin (vect(:, 1)) .* ...
              cos (vect(:, 2)) .* sin (vect(:, 3));

  c1(:, 2) = -cos (vect(:, 2)) .* cos (vect(:, 3)) - sin (vect(:, 1)) .* ...
              sin (vect(:, 2)) .* sin (vect(:, 3));

  c1(:, 3) =  cos (vect(:, 1)) .* sin (vect(:, 3));

  c2(:, 1) =  sin (vect(:, 5)) .* cos (vect(:, 6)) - sin (vect(:, 4)) .* ...
              cos (vect(:, 5)) .* sin (vect(:, 6));

  c2(:, 2) = -cos (vect(:, 5)) .* cos (vect(:, 6)) - sin (vect(:, 4)) .* ...
              sin (vect(:, 5)) .* sin (vect(:, 6));

  c2(:, 3) =  cos (vect(:, 4)) .* sin (vect(:, 6));

  N = cross (c1, c2, 2);

  lat3 = atan2 (N(:, 3), hypot (N(:, 1), N(:, 2)));
  if (sind (rad2deg (vect(:, 3))) == 0 && sind (rad2deg (vect(:, 6))) == 0)
    ## Note: use sind because sin (pi) != 0
    lon3 = zeros (size (vect, 1));
  else
    lon3 = atan2 (N(:, 2), N(:, 1));
  endif

  [alat3 alon3] = antipode (lat3, lon3, "r");

  lat = [lat3 alat3];
  lon = [lon3 alon3];

endfunction


%!test
%! [lat3, lon3] = gcxgc ( 51.8853, 0.2545, 108.55, 49.0034, 2.5735, 32.44);
%! assert (degrees2dms (lat3(1)), [50 54 27.387002], 10e-5);
%! assert (degrees2dms (lon3(1)), [04 30 30.868724], 10e-5);

%!test
%! [lat3, lon3] = gcxgc (20, -5, 45, 30, 5, 15);
%! assert (lat3(1), 28.062035, 10e-5);
%! assert (lon3(1), 4.4120504, 10e-5);

%!test
%! latlon = gcxgc (45, 45, 90, 0, 0, 90);
%! assert (latlon, [0, 0, 135, -45], 10e-10);

%!test
%! warning ("off", "Octave:coinciding-great-circles");
%! [~, ~, idl] = gcxgc (45, [0:45:360], 45, -45, -135, -45);
%! warning ("on", "Octave:coinciding-great-circles");
%! assert (idl, 2, 1e-10);

## Watch out, state of warnings and errors ignored (as usual in BIST tests)
%!warning <non-unique> gcxgc (0, 0, 45, 0, 180, -45);
%!error <numeric> gcxgc ("s", 0, 100, 10, 30, 0)
%!error <numeric> gcxgc (3i, 0, 100, 10, 30, 0)
%!error <numeric> gcxgc (50, "s", 100, 10, 30, 0)
%!error <numeric> gcxgc (50, 2i, 10, 10, 30, 0)
%!error <numeric> gcxgc (50, 0, "s", 10, 30, 0)
%!error <numeric> gcxgc (50, 0, 100i, 10, 30, 0)
%!error <numeric> gcxgc (50, 0, 100, "s", 30, 0)
%!error <numeric> gcxgc (50, 0, 100, 10i, 30, 0)
%!error <numeric> gcxgc (50, 0, 100, 10, "s", 0)
%!error <numeric> gcxgc (50, 0, 100, 10, 30i, 0)
%!error <numeric> gcxgc (50, 0, 100, 10, 30, "s")
%!error <numeric> gcxgc (50, 0, 100, 10, 30, 2i)
%!error <illegal> gcxgc (50, 0, 100, 10, 30, 0, "f")
%!error <illegal> gcxgc (50, 0, 100, 10, 30, 0, "degreef")
%!error <azimuth value> gcxgc (190, 0, 90, -90.000001, 180, 80);
%!error <azimuth value> gcxgc (190, 0, -90.001, -90.000001, 180, 80);
%!error <azimuth value> gcxgc (pi/1.999, 0, pi/2, pi/2.0001, 2, 2*pi/3, "r");
%!error <all vector inputs must> gcxgc ([50 0], 0, 0, 0, 0, [1 2 3])

