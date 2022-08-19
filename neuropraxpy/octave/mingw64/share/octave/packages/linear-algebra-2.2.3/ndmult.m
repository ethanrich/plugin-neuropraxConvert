## Copyright (C) 2013 - Juan Pablo Carbajal
##
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program. If not, see <http://www.gnu.org/licenses/>.

## Author: Juan Pablo Carbajal <ajuanpi+dev@gmail.com>

## -*- texinfo -*-
## @deftypefn {Function File} {@var{C} =} ndmult (@var{A},@var{B},@var{dim})
## Multidimensional scalar product
##
## Given multidimensional arrays @var{A} and @var{B} with entries
## A(i1,12,@dots{},in) and B(j1,j2,@dots{},jm) and the 1-by-2 dimesion array @var{dim}
## with entries [N,K]. Assume that
##
## @example
## shape(@var{A},N) == shape(@var{B},K)
## @end example
##
## Then the function calculates the product
##
## @example
## @group
##
## C (i1,@dots{},iN-1,iN+1,@dots{},in,j1,@dots{},jK-1,jK+1,@dots{},jm) =
##  = sum_over_s A(i1,@dots{},iN-1,s,iN+1,@dots{},in)*B(j1,@dots{},jK-1,s,jK+1,@dots{},jm)
##
## @end group
## @end example
##
## For example if @command{size(@var{A}) == [2,3,4]} and @command{size(@var{B}) == [5,3]}
## then the @command{@var{C} = ndmult(A,B,[2,2])} produces @command{size(@var{C}) == [2,4,5]}.
##
## This function is useful, for example,  when calculating grammian matrices of a set of signals
## produced from different experiments.
## @example
##   nT      = 100;
##   t       = 2 * pi * linspace (0,1,nT).';
##   signals = zeros (nT,3,2); % 2 experiments measuring 3 signals at nT timestamps
##
##   signals(:,:,1) = [sin(2*t) cos(2*t) sin(4*t).^2];
##   signals(:,:,2) = [sin(2*t+pi/4) cos(2*t+pi/4) sin(4*t+pi/6).^2];
##
##   sT(:,:,1) = signals(:,:,1).';
##   sT(:,:,2) = signals(:,:,2).';
##   G = ndmult (signals, sT, [1 2]);
##
## @end example
## In the example G contains the scalar product of all the signals against each other.
## This can be verified in the following way:
## @example
##   s1 = 1 e1 = 1; % First signal in first experiment;
##   s2 = 1 e2 = 2; % First signal in second experiment;
##   [G(s1,e1,s2,e2)  signals(:,s1,e1)'*signals(:,s2,e2)]
## @end example
## You may want to re-order the scalar products into a 2-by-2 arrangement (representing pairs of experiments)
## of gramian matrices. The following command @command{G = permute(G,[1 3 2 4])} does it.
##
## @end deftypefn

function M = ndmult (A,B,dim)

  dA = dim(1);
  dB = dim(2);

  sA   = size (A);
  nA   = length (sA);
  perA = [1:(dA-1) (dA+1):(nA-1) nA dA](1:nA);
  Ap = permute (A, perA);
  Ap = reshape (Ap, prod (sA(perA(1:end-1))), sA(perA(end)));

  sB   = size (B);
  nB   = length (sB);
  perB = [dB 1:(dB-1) (dB+1):(nB-1) nB](1:nB);
  Bp   = permute (B, perB);
  Bp   = reshape (Bp, sB(perB(1)), prod (sB(perB(2:end))));

  M  = Ap * Bp;
  s  = [sA(perA(1:end-1)) sB(perB(2:end))];
  M  = squeeze (reshape (M, s));

endfunction

%!demo
%! A =@(l)[1 l; 0 1];
%! N = 5;
%! p = linspace (-1,1,N);
%! T = zeros (2,2,N);
%! # A book of x-shears, one transformation per page.
%! for i=1:N
%!   T(:,:,i) = A(p(i));
%! endfor
%!
%! # The unit square
%! P = [0 0; 1 0; 1 1; 0 1];
%!
%! C = ndmult (T,P,[2 2]);
%! # Re-order to get a book of polygons
%! C = permute (C,[3 1 2]);
%!
%! try
%!   pkg load geometry
%!   do_plot = true;
%! catch
%!   printf ("Geometry package needed to plot this demo\n.");
%!   do_plot = false;
%! end
%! if do_plot
%!   clf
%!   drawPolygon (P,"k","linewidth",2);
%!   hold on
%!   c = jet(N);
%!   for i=1:N
%!     drawPolygon (C(:,:,i),":","color",c(i,:),"linewidth",2);
%!   endfor
%!   axis equal
%!   set(gca,"visible","off");
%!   hold off
%! endif
%!
%! # -------------------------------------------------
%! # The handler A describes a parametrized planar geometrical
%! # transformation (shear in the x-direction).
%! # Choosing N values of the parameter we obtain a 2x2xN matrix.
%! # We can apply all these transformations to the poligon defined
%! # by matrix P in one operation.
%! # The poligon resulting from the i-th parameter value is stored
%! # in C(:,:,i).
%! # You can plot them using the geometry package.
