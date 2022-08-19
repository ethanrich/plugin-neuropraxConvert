## Copyright (C) 2012-2017 (C) Juan Pablo Carbajal
## 
## This program is free software; you can redistribute it and/or modify it under
## the terms of the GNU General Public License as published by the Free Software
## Foundation; either version 3 of the License, or (at your option) any later
## version.
## 
## This program is distributed in the hope that it will be useful, but WITHOUT
## ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
## FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
## details.
## 
## You should have received a copy of the GNU General Public License along with
## this program; if not, see <http://www.gnu.org/licenses/>.

## Author: Juan Pablo Carbajal <ajuanpi+dev@gmail.com>

## -*- texinfo -*-
## @deftypefn {Function File} { [@var{a}, @var{ccw}]=} shapeArea (@var{pp})
## Calculate the area of a 2D shape defined with piecewise smooth polynomials.
##
## Shape is defined with piecewise smooth polynomials. @var{pp} is a
## cell where each elements is a 2-by-(poly_degree+1) array containing a pair of
## polynomials.
##
## @code{px(i,:) = pp@{i@}(1,:)} and @code{py(i,:) = pp@{i@}(2,:)}.
##
## The returned area is always positive even if the shape is parametrized
## in a clockwise direction. If the case of a clockwise parametrized shape
## @code{@var{ccw} == -1} otherwise @code{@var{ccw} == 1}.
##
## @seealso{shapeCentroid, shape2polygon, plotShape}
## @end deftypefn

function [A ccw] = shapeArea (shape)

  A   = sum (cellfun (@Aint, shape));
  ccw = sign (A);
  if (A < 0)
    warning ('geom2d:cw-shape', ...
         ['Shape has negative area. ' ...
          'Assuming this is due to a clockwise parametrization of the boundary']);
    A = ccw * A;
  end

endfunction

function dA = Aint (x)

    px = x(1,:);
    py = x(2,:);

    P = polyint (conv (px, polyder(py)));

    dA = diff (polyval (P,[0 1]));

end

%!demo # non-convex piece-wise polynomial shape
%! boomerang = {[ 0 -2 1; ...
%!               -4  4 0]; ...
%!              [0.25 -1; ...
%!               0     0]; ...
%!              [ 0 1.5 -0.75; ...
%!               -3 3    0];
%!              [0.25 0.75; ...
%!               0 0]};
%! A = shapeArea (boomerang)

%!test
%! warning('off', 'geom2d:cw-shape', 'local');
%! triangle = {[1 0; 0 0]; [-0.5 1; 1 0]; [-0.5 0.5; -1 1]};
%! A = shapeArea (triangle);
%! assert (0.5, A);

%!test
%! warning('off', 'geom2d:cw-shape', 'local');
%! circle = {[1.715729  -6.715729    0   5; ...
%!            -1.715729  -1.568542   8.284271    0]; ...
%!            [1.715729   1.568542  -8.284271    0; ...
%!             1.715729  -6.715729    0   5]; ...
%!            [-1.715729   6.715729    0  -5; ...
%!             1.715729   1.568542  -8.284271    0]; ...
%!            [-1.715729  -1.568542   8.284271    0; ...
%!            -1.715729   6.715729    0  -5]};
%! A = shapeArea (circle);
%! assert (pi*5^2, A, 5e-2);
