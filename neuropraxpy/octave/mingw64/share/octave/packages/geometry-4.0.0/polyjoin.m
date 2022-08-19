## Copyright (C) 2016 Amr Mohamed
## Copyright (C) 2017 Piyush Jain
## Copyright (C) 2017-2018 Philip Nienhuis
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
## @deftypefn {} [@var{xo}, @var{yo}] = polyjoin (@var{xi}, @var{yi})
## @deftypefnx {} {@var{xyo} =} polyjoin (@var{xi})
## Convert cell arrays of multipart polygon coordinates to numeric
## vectors with polygon parts separated by NaNs.
##
## @var{xi} and @var{yi} are cell vectors where each cell contains a
## numeric vector of X and Y coordinates, resp.  Alternatively, @var{xi}
## can be a cell array wih each cell containing Nx2 or Nx3 matrices
## constituting XY or XYZ coordinates of polygon part vertices and yi
## can be omitted.
##
## @var{xo} and @var{yo} are vectors of X and Y coordinates of polygon
## vertices where polygon parts are separated by NaNs.  If @var{xi} and
## @var{yi} either were row vectors or contained row vectors, @var{xo}
## and @var{yo} will be returned as row vectors, otherwise as column
## vectors.
##
## If @var{xi} contained Nx2 or Nx3 matrices, @var{xo} will be a Nx2
## or Nx3 matrix where polygon parts are separetd by NaN rows.  @var{yo}
## will be empty.
##
## polyjoin ultimately calls function joinPolygons in the Geometry package.
##
## @end deftypefn

## Author: Philip Nienhuis <prnienhuis@users.sf.net>
## Created: 2017-11-19

function [xo, yo] = polyjoin (xi, yi)

  ## Input checks
  if (nargin < 1)
    print_usage ();
  elseif (! iscell (xi))
    error ("Octave:invalid-input-arg", ...
           "polyjoin: input cell array or vectors expected");
  elseif (nargin == 1 && (! iscell (xi) || 
          (isnumeric (xi{1}) && size (xi{1}, 2) < 2)))
    error ("Octave:invalid-input-arg", ...
           "polyjoin: Nx2 or Nx3 matrix expected for arg. #1");
  elseif (nargin > 1 && ! iscell (yi))
    error ("Octave:invalid-input-arg", ...
           "polyjoin: expected 2 cell arrays of coordinate vectors");
  elseif (nargin > 1 && nargout < 2)
    warning ("Octave:invalid-input-arg", ...
             ["polyjoin: nr. of input arguments doesn't match nr. of output" ...
             " arguments"]);
  endif

  ## Remember input vector orientation; does not apply to input matrices
  ir = 0;

  if (isvector (xi{1}))
    if (nargin == 1)
      yi = {};
    endif
    if (isrow (xi{1}))
      ## Transpose
      ir = 1;
      xi = cellfun (@transpose, xi, "uni", 0);
      yi = cellfun (@transpose, yi, "uni", 0);
    endif
    if (isrow (xi) && ! isscalar (xi))
      ir = 1;
      xi = xi';
      yi = yi';
    endif
    yo = joinPolygons (yi);
  else
    yo = [];
  endif

##  if (numel (xi) > 1)
    xo = joinPolygons (xi);
##  else
##    xo = cell2mat (xi);
##  endif

  if (ir)
    ## Convert back to row vectors
    xo = xo';
    yo = yo';
  endif

endfunction

%!demo
%! x = {[1 2]'; [3 4]'} 
%! y = {[10 20]'; [30 40]'}
%! [vecx, vecy] = polyjoin (x, y)

%!test
%! x = {[1 2]'; [3 4]'}; y = {[10 20]'; [30 40]'};
%! [vecx, vecy] = polyjoin (x, y);
%! assert (vecx, [1; 2; NaN; 3; 4]);
%! assert (vecy, [10; 20; NaN; 30; 40]);

%!test
%! x = {[1;2]; [3;4]; [3]}; y = {[10;20]; [30;40]; [10]};
%! [vecx, vecy] = polyjoin (x, y);
%! assert (vecx, [1; 2; NaN; 3; 4; NaN; 3]);
%! assert (vecy, [10; 20; NaN; 30; 40; NaN; 10]);

%!test
%! x = {[1 2 3]'; 4; [5 6 7 8 NaN 9]'};
%! y = {[9 8 7]'; 6; [5 4 3 2 NaN 1]'};
%! [vecx, vecy] = polyjoin (x, y);
%! assert (vecx, [1; 2; 3; NaN; 4; NaN; 5; 6; 7; 8; NaN; 9]);
%! assert (vecy, [9; 8; 7; NaN; 6; NaN; 5; 4; 3; 2; NaN; 1]);

## Test 2D input matrices
%!test
%! xyi = {[0 0; 0 10; 10, 10; 10, 0; 0, 0]; [1 5; 2 5; 2 6; 1 6; 1 5]};
%! xyo = polyjoin (xyi);
%! assert (polyjoin (xyi), [0 0; 0 10; 10 10; 10 0; 0 0; NaN, NaN; 1 5; 2 5; 2 6; 1 6; 1 5], eps);

## Test 3D input matrices
%!test
%! xyi = {[0 0 1; 0 10 2; 10, 10 3; 10, 0 2; 0, 0 1]; [1 5 1.5; 2 5 2; 2 6 2.5; 1 6 2; 1 5 1.5]};
%! xyo = polyjoin (xyi);
%! assert (polyjoin (xyi), [0 0 1; 0 10 2; 10 10 3; 10 0 2; 0 0 1; NaN, NaN NaN; 1 5 1.5; 2 5 2; 2 6 2.5; 1 6 2; 1 5 1.5], eps);

## Corner case of just one point
%!test
%! assert (polyjoin ({[2, 3]}), [2, 3], eps);

%!error <input cell array or vectors expected> polyjoin (1);
%!error <Nx2 or Nx3 matrix expected> polyjoin ({2});
%!error <Nx2 or Nx3 matrix expected> polyjoin ({2, 3});
%!error <expected 2 cell arrays> polyjoin ({1; 2}, [3 4]);
%!warning <nr. of input arguments doesn't match> polyjoin ({1; 2}, {3 4});
