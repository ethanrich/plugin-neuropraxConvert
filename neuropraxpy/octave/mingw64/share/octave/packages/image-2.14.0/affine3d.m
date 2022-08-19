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

classdef affine3d < affine

## -*- texinfo -*-
## @deftypefn   {Function File} {@var{tform} =} affine3d (@var{T})
## @deftypefnx  {Function File} {@var{tform} =} affine3d ()
## tform is a representation of an affine 3D transform.
## Calling affine3D without parameters, (@code{affine3d ()}) produces the identity
## transformation.
##
## affine3d takes a transpose of the affine matrix as described in
## standard literature it performs the transformation as follows:
## v = (u*T)(1:3)
## where u = [x y z 1] and T = [a b c 0; d e f 0; g h i 0; j k l 1]
## [a b c; d e f; g h i] is a transposed rotation\shear matrix,
## [j k l] is the translation vector, where j = dx, k = dy, l = dz.
##
## affine3d methods:
## invert:
##     @code{invert (tform)} - produces the inverse transform of affine3d transform
## isRigid:
##     @code{isRigid (tform)} - checks if transform tform is only rotation or translation.
## isSimilarity:
##     @code{isSimilarity (tform)} - checks if transform tform is only homogeneous scaling,
##     rotation, reflection or translation.
## isTranslation:
##     @code{isTranslation (tform)} - checks if transform tform is is a pure translation
## outputLimits:
##     @code{outputLimits (tform, xlims, ylims, zlims)} - given a bounding cube corner
##     coordinates in xlims, ylims and zlims (top left front, right bottom back) -
##     returns the new bounding cube after transformation.
## transformPointsForward:
##     @code{transformPointsForward(tform, u, v, w)} - apply transformation tform
##     on the set of u, v, w points (1xn vectors)
##     @code{transformPointsForward(tform, U)} - apply transformation tform
##     on U (3xn matrix)
## transformPointsInverse:
##     @code{transformPointsInverse(tform, u, v, w)} - apply the inverse transformation
##     of tform on the set of u, v, w points (1xn vectors)
##     @code{transformPointsInverse(tform, U)} - apply the inverse transformation
##      of tform on U (3xn matrix)
##
## @seealso{affine2d}
## @end deftypefn

  methods
    function this = affine3d (T)
      if (nargin > 1)
        error ("affine3d: usage - affine3d(T), where T is a 4x4 matrix")
      endif
      if (nargin == 0)
        T = eye(4);
      endif
      this@affine (T);
    endfunction

    ## given a bounding cube corner coordinates in xlims, ylims and
    ## zlims (top left front, right bottom back) - return the new
    ## bounding cube after transformation.
    function [limitsX, limitsY, limitsZ] = outputLimits (this, xlims, ylims,
                                                         zlims)
     if (nargin ~= 4)
        error ("outputLimits usage: outputLimits (tform, xlims, ylims, zlims)")
      endif

      xlims2 = [xlims(:); xlims(:); xlims(:); xlims(:)];
      ylims2 = [ylims(:); ylims(end:-1:1)(:); ylims(:); ylims(end:-1:1)(:)];
      zlims2 = [zlims(:); zlims(:); zlims(end:-1:1)(:); zlims(end:-1:1)(:)];
      temp = [xlims2 ylims2 zlims2 ones(8,1)];
      temp = temp*this.T;
      limitsX = [min(temp(1:8,1)), max(temp(1:8,1))];
      limitsY = [min(temp(1:8,2)), max(temp(1:8,2))];
      limitsZ = [min(temp(1:8,3)), max(temp(1:8,3))];
    endfunction
  endmethods
endclassdef

%!test
%! Sx = 1.2;
%! Sy = 1.6;
%! Sz = 2.4;
%! A = [Sx 0 0 0; 0 Sy 0 0; 0 0 Sz 0; 0 0 0 1];
%! tform = affine3d (A);
%! [X, Y, Z] = transformPointsForward (tform, 5, 10, 3);
%! assert ([X Y Z], [6 16 7.2], 5*eps)
%! [U, V, W] = transformPointsInverse (tform, X, Y, Z);
%! assert ([U V W], [5 10 3], eps)
%! assert (! isRigid (tform))
%! assert (! isTranslation (tform))
%! assert (! isSimilarity (tform))

%!test
%! A = [3 1 2 0; 4 5 8 0; 6 2 1 0; 0 0 0 1];
%! tform = affine3d (A);
%! [X, Y, Z] = transformPointsForward (tform, 2, 3, 5);
%! assert (X, 48, eps)
%! assert (Y, 27, eps)
%! assert (Z, 33, eps)
%! [U, V, W] = transformPointsInverse (tform, X, Y, Z);
%! assert (U, 2, 50*eps)
%! assert (V, 3, 50*eps)
%! assert (W, 5, 50*eps)
%! assert (! isRigid (tform))
%! assert (! isTranslation (tform))
%! assert (! isSimilarity (tform))

%!test
%! A = [1 0 0 0; 0 1 0 0; 0 0 1 0; 5 10 1 1];
%! tform = affine3d (A);
%! X = transformPointsForward (tform, [1 2 3; 4 5 6; 7 8 9]);
%! assert (round (X), [6, 12, 4; 9, 15, 7; 12, 18, 10])
%! U = transformPointsInverse (tform, X);
%! assert (round (U), [1 2 3; 4 5 6; 7 8 9])
%! assert (isRigid (tform))
%! assert (isTranslation (tform))
%! assert (isSimilarity (tform))

%!test
%! Sx = 1.2;
%! Sy = 1.6;
%! Sz = 2.4;
%! A = [Sx 0 0 0; 0 Sy 0 0; 0 0 Sz 0; 0 0 0 1];
%! tform = affine3d (A);
%! [xlim, ylim, zlim] = outputLimits (tform, [1 128], [1 128], [1 27]);
%! assert (xlim, [ 1.2000  153.6000],1e-8)
%! assert (ylim, [1.6000  204.8000], 1e-8)
%! assert (zlim, [2.4000   64.8000], 1e-8)

%!error <affine3d> affine3d (1, 2)
%!error <outputLimits usage> outputLimits (affine2d())

%!test
%! a = 23;
%! M = [cosd(a) 0 sind(a) 0;
%!      0       1      0  0;
%!     -sind(a) 0 cosd(a) 0;
%!      0       0      0  1];
%! tform = affine3d (M);
%! tform2 = invert (tform);
%! assert (tform.T * tform2.T, diag([1 1 1 1]), eps);

%!test
%! tform = affine3d;
%! assert (tform.T, eye (4))
%! assert (tform.Dimensionality, 3)
