## Copyright (C) 2017-2019 Philip Nienhuis
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
## @deftypefn {Function File} [@var{VXo}, @var{VYo}] = polybool (@var{op}, @var{VX1}, @var{VY1}, @var{VX2}, @var{VY2})
## @deftypefnx {Function File} [@var{MXYZ}] = polybool (@var{op}, @var{MSP}, @var{MCP})
## @deftypefnx {Function File} [@var{MXYZ}] = polybool (@dots{}, @var{library})
## Perform boolean operation(s) on polygons.
##
## The subject and clip polygons can each be represented by two separate
## input vectors.  The subject polygon X and Y coordinates would be @var{VX1}
## and @var{VY1}, resp., and the clip polygon(s) X and Y coordinates would be
## @var{VX2} and @var{VY2}.  All these vectors can be row or column vectors,
## numeric or cell, and the output format will match that of @var{VX1} and
## @var{VY1}.
##
## Alternatively, the subject and clip polygons can be represented by 2D or
## 3D matrices (@var{MSP} and @var{MCP}, respectively) of X, Y, and
## -optionally- Z values, where each row constitues the coordinates of one
## vertex.  The Z values of clip polygon(s) are ignored.  Z-values of newly
## created vertices in the output polygon(s) are copied from the nearest
## vertex in the subject polygon(s).
##
## In any case the input polygons can be multipart, where subpolygons are
## separated by NaN values (or NaN rows in case of matrix input).  By
## convention, in case of nested polygons the outer polygon should have a
## clockwise winding direction, inner polygons constituting "holes" should
## have a counterclockwise winding direction; polygons nested in holes
## should again be clockwise, and so on.
##
## Every polygon part should comprise at least different 3 vertices.  As
## polygons are implicitly assumed to be closed, no need to repeat the first
## vertex as last closing vertex.
##
## Likewise, output polygons returned in @var{VXo} and @var{VYo} (in case
## of vector input) or @var{MXYZ} (in case of matrix input) can be multipart
## and if so also have NaNs or NaN row(s) separating subpolygons.
##
## @var{op} is the requested operation and can be one of the following (for
## character values only the first letter is required, case-independent):
##
## @table @asis
## @item 0 (numeric)
## @itemx "subtraction"
## @itemx "minus" @*
## Subtract the clip polygon(s) from the subject polygon(s).
##
## @item 1 (numeric)
## @itemx "intersection"
## @itemx "and" @*
## Return intersection(s) of subject and clip polygon(s).
## 
## @item 2 (numeric)
## @itemx "exclusiveor"
## @itemx "xor" @*
## Return ExclusiveOr(s) of subject and clip polygon(s); this is the
## complement of the 'and' operation or the result of subtracting the output
## of 'and' from 'or' operations on both polygons.
##
## @item 3 (numeric)
## @itemx "union"
## @itemx "or" @*
## Return the union of both input polygons.
## @end table
##
## @seealso{ispolycw,isShapeMultiPart}
## @end deftypefn

## Author: Philip Nienhuis <prnienhuis@users.sf.net>
## Created: 2017-11-12

function [xo, yo] = polybool (op, varargin)

  ## Input checks
  if (nargin < 3)
    ## For matrices we need at least 3 args. For vectors we'll check later.
    print_usage ();
  elseif (! ischar (op) && (isnumeric (op) && (op < 0 || op > 3)))
    error ("Octave:invalid-input-arg", ...
           "polybool: char value or numeric value [0-3] expected for arg. #1");
  endif

  ## Check subject polygon class and type.
  ## itype = 1 (column vectors), 2 (row vectors), -1 (matrix),
  ##         3 (cell column vectors), 4 (cell row vectors)
  if (isnumeric (varargin{1}) && isnumeric (varargin{2}))
    sza1 = size (varargin{1});
    if (isvector (varargin{1}))
      ## Separate numeric vector input (ML compatible). Make it a Nx2 matrix
      itype = 1;
      X1 = varargin{1};
      Y1 = varargin{2};
    elseif (numel (sza1) == 2 && prod (sza1) > max (sza1) &&  ...
            sza1(1) >= 3 && sza1(1) >= sza1(2))
      ## Matrix input (makes Z-values possible), X,Y{,Z] in columns
      itype = -1;
      inpol = varargin{1};
    else
      error ("Octave:invalid-input-arg", ...
             "polybool: Nx2 or Nx3 (with N > 2) numeric input expected for arg #2");
    endif
  elseif (iscell (varargin{1}) && iscell (varargin{2}))
    ## Always assume (ML-compatible) vector input
    itype = 3;
    [X1, Y1] = polyjoin (varargin{1}, varargin{2});
  else
    error ("Octave:invalid-input-arg", ...
           "polybool: X1, Y1 input vectors must be same class");
  endif
  if (itype != -1)
    ## X1 and X2 are assumed numeric vectors now
    if (numel (X1) != numel (Y1))
      error ("Octave:invalid-input-arg", ...
             "polybool: X1, Y1 input vectors must be same length");
    endif
    if (isrow (X1) !=  isrow (Y1))
      error ("Octave:invalid-input-arg", ...
             "polybool: X1 and Y1 should have same dimension");
    endif    ## Convert vector input into a Nx2 matrix
    if (isrow (X1))
      ++itype;
      inpol = [X1; Y1]';
    else
      inpol = [X1 Y1];
    endif
  endif
  if (size (inpol, 1) < 3)
    ## Not a polygon
      error ("Octave:invalid-input-arg", ...,
             "polybool: input 'polygon' has less than 3 vertices");
  endif

  ## Check clip polygon class and type.
  ## ctype = 1 (column vectors), 2 (row vectors), -1 (matrix),
  ##         3 (cell column vectors), 4 (cell row vectors)
  if (itype == -1)
    ## Matrix input
    sza2 = size (varargin{2});
    if (numel (sza2) == 2 && prod (sza2) > max (sza2) && ...
        sza2(1) >= 3 && sza2(1) >= sza2(2))
      ctype = -1;
      clpol = varargin{2};
    else
      error ("Octave:invalid-input-arg", ...,
             "polybool: Nx3 matrix input (with N > 2) expected for arg #3");
    endif
  elseif (nargin < 5)
    # For vector input we need at least 5 args
    print_usage ();
  else
    if (isnumeric (varargin{3}) && isnumeric (varargin{4}))
      ctype = 1;
      X2 = varargin{3};
      Y2 = varargin{4};
    elseif (iscell (varargin{3}) && iscell (varargin{4}))
      ctype = 3;
      [X2, Y2] = polyjoin (varargin{3}, varargin{4});
    else
      error ("Octave:invalid-input-arg", ...
             "polybool: X2, Y2 input vectors must be same class");
    endif
    if (isrow (X2) !=  isrow (Y2))
      error ("Octave:invalid-input-arg", ...
      "polybool: X2 and Y2 should have same dimension");
    endif
    if (numel (X2) != numel (Y2))
      error ("Octave:invalid-input-arg", ...
             "polybool: X2, Y2 input vectors must be same length");
    endif
    ## Turn clip poygon into matrix
    if (isrow (X2))
      ++ctype;
      clpol = [X2; Y2]';
    else
      clpol = [X2 Y2];
    endif
  endif
  if (size (inpol, 1) < 3)
    ## Not a polygon
      error ("Octave:invalid-input-arg", ...,
             "polybool: clip 'polygon' has less than 3 vertices");
  endif

  ## Boolean operation library
  ichar = 0;
  blib = "clipper";
  ## Find out arg no. of library name
  if (itype == -1 && nargin > 3)
    ichar = 3;
  elseif (nargin > 5)
    ichar = 5;
  endif
  if (ichar)
    if (ischar (varargin{ichar}))
      blib = lower (varargin{ichar});
      if (! ismember (blib, {"clipper", "mrf"}))
        error ("Octave:invalid-input-arg", ...,
               "polybool: unknown polygon library - %s", blib);
      endif
    elseif (! ischar (varargin{ichar}))
      print_usage ();
    endif
  endif
 
  if (ischar (op))
    switch (lower (op(1)))
      case {"s", "m", "-"}
        ## Subtraction
        op = 0;
      case {"i", "a", "&"}
        ## Intersection / And
        op = 1;
      case {"e", "x"}
        ## ExclusiveOR
        op = 2;
      case {"u", "o", "|", "+", "p"}
        ## Union / Or
        op = 3;
      otherwise
        error ("Octave:invalid-input-arg", ...
               "polybool: unknown operation '%s'", op);
    endswitch
  endif

  ## Call clipPolygon (geometry pkg) to do the work
  try
    if (strcmp (blib, "clipper"))
      [outpol, npol] = clipPolygon_clipper (inpol, clpol, op);
    else
      [outpol, npol] = clipPolygon_mrf (inpol, clpol, op);
    endif
  catch
    error ("polybool: internal error, possibly invalid geometric input");
  end_try_catch

  ## Postprocess output to match input formats
  switch itype
    case 1
      ## Numeric column input
      xo = outpol(:, 1);
      yo = outpol(:, 2);
    case 2
      ## Numeric row input
      xo = outpol(:, 1)';
      yo = outpol(:, 2)';
    case 3
      ## cell column input
      xo = {outpol(:, 1)};
      yo = {outpol(:, 2)};
    case 4
      ## Cell row input
      xo = {outpol(:, 1)'};
      yo = {outpol(:, 2)'};
    case -1
      ## Matrix input
      xo = outpol;
      yo = [];
    otherwise
  endswitch

endfunction

%!shared ipol, cpol, ix, iy, cx, cy, xi, yi, xc, yc
%! ipol = [0 0; 3 0; 3 3; 0 3; 0 0];
%! cpol = [2, 1; 5, 1; 5, 4; 2, 4; 2, 1];
%! ix = {ipol(:, 1)'};
%! iy = {ipol(:, 2)'};
%! cx = {cpol(:, 1)'};
%! cy = {cpol(:, 2)'};
%! xi = {ipol(:, 1)};
%! yi = {ipol(:, 2)};
%! xc = {cpol(:, 1)};
%! yc = {cpol(:, 2)};

%% Subtraction - matrix input
%!test
%! opol = polybool (0, ipol, cpol);
%! assert (size (opol), [7, 2]);
%! assert (polygonArea (opol), 7);

%% Subtraction - row vector input input
%!test
%! [ox, oy] = polybool (0, ix, iy, cx, cy);
%! opol = [ox{1}', oy{1}'];
%! assert (size (opol), [7, 2]);
%! assert (polygonArea (opol), 7);

%% Subtraction - column vector input input
%!test
%! [ox, oy] = polybool (0, xi, yi, xc, yc);
%! opol = [ox{1}, oy{1}];
%! assert (size (opol), [7, 2]);
%! assert (polygonArea (opol), 7);

%!test
%! opol = polybool (1, cpol, ipol);
%! assert (size (opol), [5, 2]);
%! assert (polygonArea (opol), 2);

%!test
%! [ox, oy] = polybool (1, ix, iy, cx, cy);
%! opol = [ox{1}', oy{1}'];
%! assert (size (opol), [5, 2]);
%! assert (polygonArea (opol), 2);

%!test
%! opol = polybool (2, cpol, ipol);
%! assert (size (opol), [15, 2]);
%! assert (polygonArea (opol), 14);

%!test
%! [ox, oy] = polybool (2, ix, iy, cx, cy);
%! opol = [ox{1}', oy{1}'];
%! assert (size (opol), [15, 2]);
%! assert (polygonArea (opol), 14);

%!test
%! opol = polybool (3, cpol, ipol);
%! assert (size (opol), [9, 2]);
%! assert (polygonArea (opol), 16);

%!test
%! [ox, oy] = polybool (3, ix, iy, cx, cy);
%! opol = [ox{1}', oy{1}'];
%! assert (size (opol), [9, 2]);
%! assert (polygonArea (opol), 16);

%!error<input 'polygon' has less than 3 vertices> polybool ("a", 1, 2, 3 ,4);
%!error<char value or numeric value> polybool (-1, 1, 2);
%!error<char value or numeric value> polybool (-1, [1 1; 2 2; 3 3], [2 2; 3 3; 4 4]);
%!error<Nx3 matrix> polybool (1, [0 0 0; 2 2 2; 5 5 5], [1 1 1; 3 3 3]);
%!error<internal error> polybool (1, [0 0 0; 2 2 2; 5 5 5], [1 1 1; 3 3 3; 6 6 7]);
%!error<X1, Y1 input vectors must be same class> polybool (1, {1, 2}, [1, 2]);
%!error<X1, Y1 input vectors must be same length> polybool (1, {[1, 2, 3]}, {[1, 2, 3, 4]});
%!error<X2, Y2 input vectors must be same length> polybool (1, {[1, 2, 3]}, {[1, 2, 3]}, {[1, 2, 3]}, {[1, 2, 4, 5]});
%!error<unknown operation 'z'> polybool ('z', {[1, 2, 3]}, {[1, 2, 3]}, {[1, 2, 3]}, {[1, 2, 4]});
%!error<unknown polygon library> polybool (1, [1 1; 2 2; 3 3], [2 2; 3 3; 4 4], "abc")