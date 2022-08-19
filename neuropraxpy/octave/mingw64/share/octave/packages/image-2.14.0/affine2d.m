## Copyright (C) 2017 Carnë Draug <carandraug@octave.org>
## Copyright (C) 2015 Motherboard <cantfind@gmail.com>
##
## This program is free software: you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation, either version 3 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program.  If not, see <http://www.gnu.org/licenses/>.

classdef affine2d < affine

## -*- texinfo -*-
## @deftypefn   {Function File} {@var{tform} =} affine2d (@var{T})
## @deftypefnx  {Function File} {@var{tform} =} affine2d ()
## tform is a representation of an affine 2D transform.
## Calling affine2D without parameters, (@code{affine2d ()}) produces the identity
## transformation.
##
## affine2d takes a transpose of the affine matrix as described in
## standard literature it performs the transformation as follows:
## v = (u*T)(1:2)
## where u = [x y 1] and T = [a b 0; c d 0; e f 1] [a b; c d] is a
## transposed rotation\shear matrix, [e f] is the translation vector,
## where e = dx, f = dy.
##
## affine2d methods:
## invert:
##     @code{invert (tform)} - produces the inverse transform of affine2d transform
## isRigid:
##     @code{isRigid (tform)} - checks if transform tform is only rotation or translation.
## isSimilarity:
##     @code{isSimilarity (tform)} - checks if transform tform is only homogeneous scaling,
##     rotation, reflection or translation.
## isTranslation:
##     @code{isTranslation (tform)} - checks if transform tform is is a pure translation
## outputLimits:
##     @code{outputLimits (tform, xlims, ylims)} - given a bounding box corner
##     coordinates in xlims and ylims (top left, right bottom) - returns the new
##     bounding box after transformation.
## transformPointsForward:
##     @code{transformPointsForward(tform, u, v)} - apply transformation tform
##     on the set of u, v points (1xn vectors)
##     @code{transformPointsForward(tform, U)} - apply transformation tform
##     on U (2xn matrix)
## transformPointsInverse:
##     @code{transformPointsInverse(tform, u, v)} - apply the inverse transformation
##     of tform on the set of u, v points (1xn vectors)
##     @code{transformPointsInverse(tform, U)} - apply the inverse transformation
##      of tform on U (2xn matrix)
##
## @seealso{affine3d}
## @end deftypefn

  methods
    function this = affine2d (T)
      if (nargin > 1)
        error ("affine2d: usage - affine2d(T), where T is a 3x3 matrix")
      endif
      if (nargin == 0)
        T = eye(3);
      endif
      this@affine (T);
    endfunction

    ## Given a bounding box corner coordinated in xlims and ylims (top
    ## left, right bottom) - return the new bounding box after
    ## transformation.
    function [limitsX, limitsY] = outputLimits (this, xlims, ylims)
      if (nargin ~= 3)
        error ("outputLimits usage: outputLimits (tform, xlims, ylims)")
      endif

      xlims2 = [xlims(:); xlims(:)];
      ylims2 = [ylims(:); ylims(end:-1:1)(:)];
      temp = [xlims2 ylims2 ones(4,1)];
      temp = temp*this.T;
      limitsX = [min(temp(1:4,1)), max(temp(1:4,1))];
      limitsY = [min(temp(1:4,2)), max(temp(1:4,2))];
    endfunction
  endmethods
endclassdef

%!test
%! theta = 10;
%! A = [cosd(theta)  -sind(theta)  0
%!      sind(theta)   cosd(theta)  0
%!               0             0   1];
%! tform = affine2d (A);
%! [X, Y] = transformPointsForward (tform, 5, 10);
%! assert (X, 6.6605, 1.e-4)
%! assert (Y, 8.9798, 1.e-4)
%!
%! [U, V] = transformPointsInverse (tform, X, Y);
%! assert (U, 5, 5*eps)
%! assert (V, 10, 5*eps)
%! assert (isRigid (tform))
%! assert (! isTranslation (tform))
%! assert (isSimilarity (tform))

%!test
%! theta = 30;
%! tform = affine2d([ cosd(theta)  sind(theta) 0
%!                   -sind(theta)  cosd(theta) 0
%!                             0            0  1]);
%! assert (tform.T, [ 0.86603 0.5     0
%!                   -0.5     0.86603 0
%!                    0       0       1], 1.e-5);
%! invtform = invert(tform);
%! assert (invtform.T, [ 0.86603 -0.5     0
%!                    0.5      0.86603 0
%!                    0        0       1], 1.e-5);
%! assert (isRigid (tform))
%! assert (! isTranslation (tform))
%! assert (isSimilarity (tform))

%!test
%! tform = affine2d ([1 0 0; 0 1 0; 5 10 1]);
%! [X, Y] = transformPointsForward (tform, [1 2; 3 4; 5 6; 7 8]);
%! assert (round (X), [6; 8; 10; 12])
%! assert (round (Y), [12; 14; 16; 18])
%!
%! [U, V] = transformPointsInverse (tform, X, Y);
%! assert (round (U), [1; 3; 5; 7])
%! assert (round (V), [2; 4; 6; 8])
%! assert (isRigid (tform))
%! assert (isTranslation (tform))
%! assert (isSimilarity (tform))

%!test
%! tform = affine2d ([1 1e-16 0; 1e-16 1 0; 5 10 1]);
%! assert (isRigid (tform))
%! tform = affine2d ([2 1e-16 0; 1e-16 1 0; 5 10 1]);
%! assert (! isRigid (tform))

%!test
%! theta = 10;
%! A = [cosd(theta)  -sind(theta) 0
%!      sind(theta)   cosd(theta) 0
%!               0             0  1];
%! tform = affine2d (A);
%! [xlim, ylim] = outputLimits (tform, [1 240], [1 291]);
%! assert (xlim, [1.1585 286.8855], 1.e-4)
%! assert (ylim, [-40.6908  286.4054], 1.e-4)

%!test
%! A = [1  0  0
%!      0  1  0
%!      40 40 1];
%! tform = affine2d (A);
%! assert (isRigid (tform));
%! assert (isSimilarity (tform));
%! assert (isTranslation (tform));

%!test
%! a = invert (affine2d ([1 2 0; 3 4 0; 10 20 1]));
%! b = affine2d(a.T);
%! assert (b.T, [-2, 1, 0; 1.5, -0.5, 0; -10, 0, 1], 5*eps)

%!assert (isTranslation (affine2d ([1, 0, 0; 0, 1, 0; 40, 40, 1])))
%!assert (! isTranslation (affine2d ([1 0 0; 0 -1 0; 0 0 1])))
%!assert (! isRigid (affine2d ([1 0 0; 0 -1 0; 0 0 1])))

%!error <must be an affine transform matrix> affine2d ([0 0 0; 0 0 0])
%!error <must be an affine transform matrix> affine2d ([0 0 0  0 0 0  0 0 1])
%!error <must be an affine transform matrix> affine2d ([0 0 0; 0 0 0; 0 0 0])
%!error <must be an affine transform matrix> affine2d ([1 0 0; 0 1 1; 0 0 1])
%!error <must not be a singular matrix> affine2d ([0 0 0; 0 0 0; 0 0 1])
%!error <affine2d> affine2d (1, 2)
%!error <outputLimits usage> outputLimits (affine2d())

%!test
%! tform = affine2d;
%! assert (tform.T, eye (3))
%! assert (tform.Dimensionality, 2)
