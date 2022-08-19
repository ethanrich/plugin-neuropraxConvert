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
## along with this program.  If not, see
## <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File}  [@var{Xo}, @var{Yo}, ... ] = closePolygonParts (@var{Xi}, @var{Yi}, ...)
## @deftypefnx {Function File} [@var{Xo}, @var{Yo}, ... ] = closePolygonParts (@var{Xi}, @var{Yi}, ..., @var{angunit})
## Ensure that (each part of a multipart) polygon is a closed ring.
##
## For each (part of a) polygon, closePolygonParts checks if the vertices
## of that part form a closed ring, i.e., if first and last vertices coincide.
## If the polygon or polygon parts (the latter separated separated by NaNs) do
## not form a closed ring, the first vertex coordinates of each open part are
## appended after its last vertex.  Input polygons need not be multipart.
##
## @var{Xi} and @var{Yi} (plus optionally, @var{Zi} and/or @var{Mi}) are input
## vectors of X and Y or Longitude and Latitude (plus optionally Z or Height,
## and/or M) vectors of vertex coordinates (and measure values) of an input
## polygon.  If a vector of measures is given as argument, it should always be
## the last vector.
##
## Optional last argument @var{angunit} can be one of 'Degrees' or 'Radians'
## (case-insensitive, only the first 3 characters need to match).  If this
## argument is given and if the first two input vectors are longitude/latitude
## vectors rather than X/Y vectors, it indicates that the longitudes of those
## first and last vectors need only coincide modulo 360 degrees or 2*pi radians.
##
## The number of output vectors @var{Xo}, @var{Yo}, ... matches the number of
## input vectors.
##
## @seealso{isShapeMultiPart}
## @end deftypefn

## Author: Philip Nienhuis <prnienhuis@users.sf.net>
## Created: 2017-11-08

function [varargout] = closePolygonParts (varargin)

  nargs = nargin;
  ang = 0;
  ## Input checks
  if (ischar (varargin{end}))
    ang = find (ismember ({"rad", "deg"}, lower (varargin{end}(1:3))));
    if (isempty (ang))
      error ("closePolygonParts: unknown angle unit: '%s'; must be Degrees or Radians", ...
              varargin{end});
    endif
    --nargs;
  endif
  if (! all (cellfun (@isnumeric, varargin(1:nargs))))
    error ("closePolygonParts: numeric input vectors expected");
  elseif (nargs != nargout)
    error ("closePolygonParts: nr. of input vectors doesn't match nr. of output vectors");
  endif
  ## Check orientation, matching NaN positions and lengths of input vectors
  mp = cell (nargs, 1);
  for ii=1:nargs
    mp(ii) = find (isnan (varargin{ii}));
  endfor
  for ii=2:nargs
    if (numel (varargin{ii-1}) != numel (varargin{ii}))
      error ("closePolygonParts: incompatible input vectors #%d and #%d", ii-1, ii);
    endif
    if (isrow (varargin{ii-1}) != isrow (varargin{ii}))
      error ("closePolygonParts: all input vectors should have same dimension");
    endif
    ## Check NaN positions. M vectors may have more NaNs indicating missing values
    if (! isempty (mp{ii-1}) && ! isempty (mp{ii}) && ...
        numel (mp{ii-1}) == numel (mp{ii}))
      ## The next loop uses ismember() to cope with M vectors with missing values
      if (! all (ismember (mp{ii-1}, mp{ii})))
        error ("closePolygonParts: NaN positions of arg# %d and arg #d don't match", ii-1, ii);
      endif
    endif
  endfor

  ## Input validation done, check for open rings.
  ## Assess extent of each polygon part.
  idn = [ 0 (find (isnan (varargin{1}))) (numel (varargin{1})+1) ];
  ## Process polygons backwards to avoid stale (multipart) idn indices
  for jj=numel (idn)-1 : -1 : 1
    isclosed = true;
    if (ang == 1)
      isclosed = isclosed && ...
                 abs (wrapTo2Pi (varargin{1}(idn(jj)+1)) - wrapTo2Pi (varargin{1}(idn(jj+1)-1))) < eps;
    elseif (ang == 2)
      isclosed = isclosed && ...
                 abs (wrapTo360 (varargin{1}(idn(jj)+1)) - wrapTo360 (varargin{1}(idn(jj+1)-1))) < eps;
    else
      isclosed = isclosed && ...
                 abs (varargin{1}(idn(jj)+1) - varargin{1}(idn(jj+1)-1)) < eps;
    endif
    for ii=2:nargs
      isclosed = isclosed && ...
                 abs (varargin{ii}(idn(jj)+1) - varargin{ii}(idn(jj+1)-1)) < eps;
    endfor
    if (! isclosed)
      for ii=1:nargs
        varargin{ii}(idn(jj+1):end+1) = varargin{ii}(idn(jj+1)-1:end);
        varargin{ii}(idn(jj+1)) = varargin{ii}(idn(jj)+1);
      endfor
    endif
  endfor

  for ii=1:nargs
    varargout{ii} = varargin{ii};
  endfor

endfunction


%!test
%! xi = [ 1 5   6  2 NaN  11 15 16 12 ];
%! yi = [ 1 2   5  6 NaN   1  2  5  6 ];
%! zi = [ 1 3   5  3 NaN  11 13 15 13 ];
%! mi = [ 8 9 NaN -1 NaN NaN -3 -2 NaN];
%! [a, b, c, d] = closePolygonParts (xi, yi, zi, mi);
%! assert (a, [1 5 6 2 1 NaN 11 15 16 12 11], 1e-10);
%! assert (b, [1 2 5 6 1 NaN  1  2  5  6  1], 1e-10);
%! assert (c, [1 3 5 3 1 NaN 11 13 15 13 11], 1e-10);
%! [d, e, f] = closePolygonParts (a, b, c);
%! assert (a, d, 1e-10);
%! assert (b, e, 1e-10);
%! assert (c, f, 1e-10);

%!test
%! xxi = [ 400 405 406 402 NaN 311 315 316 312 671 ];
%! yyi = [   1   2   5   6 NaN   1   2   5   6   1 ];
%! zzi = [   1   3   5   3 NaN  11  13  15  13  11 ];
%! [a, b, c] = closePolygonParts (xxi, yyi, zzi, "deg");
%! assert (a, [400 405 406 402 400 NaN 311 315 316 312 671], 1e-10);
%! assert (b, [  1   2   5   6   1 NaN   1   2   5   6   1], 1e-10);
%! assert (c, [  1   3   5   3   1 NaN  11  13  15  13  11], 1e-10);

%!error <unknown angle unit> a = closePolygonParts ([0 1], "ged");
%!error <numeric input vectors expected> [a, b] = closePolygonParts ([0 1], {"c", "d"})
%!error <nr. of input vectors> a = closePolygonParts ([0 1], [2 3])
%!error <nr. of input vectors> a = closePolygonParts ("radians")
%!error <incompatible input vectors> [a, b] = closePolygonParts ([0 NaN 1], [2 NaN 3 4])
%!error <NaN positions of> [a, b] = closePolygonParts ([0 1 NaN 1], [2 NaN 3 4])
