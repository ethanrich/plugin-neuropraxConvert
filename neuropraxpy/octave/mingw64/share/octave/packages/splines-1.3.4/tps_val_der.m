## Copyright (C) 2015 Nir Krakauer
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
## along with this program; If not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn{Function File}{[@var{dyi}] =} tps_val_der(@var{x}, @var{coefs}, @var{xi}, @var{vectorize}=true )
##
## Evaluates the first derivative of a thin plate spline at given points @*
## @var{xi}
## 
## @var{coefs} should be the vector of fitted coefficients returned from @code{tpaps(x, y, [p])}
##
## @var{x} should be @var{n} by @var{d} in size, where @var{n} is the number of points and @var{d} the number of dimensions; @var{coefs} should be (@var{n} + @var{d} + 1) by 1; @var{xi} should be @var{k} by @var{d}
##
## The logical argument @var{vectorize} controls whether @var{k} by @var{n} by @var{d} intermediate arrays are formed to speed up computation (the default) or whether looping is used to economize on memory
##
## The returned @var{dyi} will be @var{k} by @var{d}, containing the first partial derivatives of the thin plate spline at @var{xi}
##
##
## Example usages:
## @example
## x = ([1:10 10.5 11.3])'; y = sin(x); dy = cos(x); xi = (0:0.1:12)';
## coefs = tpaps(x, y, 0.5);
## [dyi] = tps_val_der(x,coefs,xi);
## subplot(1, 1, 1)
## plot(x, dy, 's', xi, dyi)
## legend('original', 'tps')
## @end example
## 
## @example
## x = rand(100, 2)*2 - 1; 
## y = x(:, 1) .^ 2 + x(:, 2) .^ 2;
## [x1 y1] = meshgrid((-1:0.2:1)', (-1:0.2:1)');
## xi = [x1(:) y1(:)];
## coefs = tpaps(x, y, 1);
## dyio = [2*x1(:) 2*y1(:)];
## [dyi] = tps_val_der(x,coefs,xi);
## subplot(2, 2, 1)
## contourf(x1, y1, reshape(dyio(:, 1), 11, 11)); colorbar
## title('original x1 partial derivative')
## subplot(2, 2, 2)
## contourf(x1, y1, reshape(dyi(:, 1), 11, 11)); colorbar
## title('tps x1 partial derivative')
## subplot(2, 2, 3)
## contourf(x1, y1, reshape(dyio(:, 2), 11, 11)); colorbar
## title('original x2 partial derivative')
## subplot(2, 2, 4)
## contourf(x1, y1, reshape(dyi(:, 2), 11, 11)); colorbar
## title('tps x2 partial derivative')
## @end example
## 
## See the documentation to @code{tpaps} for more information
##
## @end deftypefn
## @seealso{tpaps, tpaps_val, tps_val_der}

## Author: Nir Krakauer <nkrakauer@ccny.cuny.edu>

function [dyi]=tps_val_der(x,coefs,xi,vectorize=true)


  [n d] = size(x); #d: number of dimensions; n: number of points
  k = size(xi, 1); #number of points for which to find the spline derivative value

  #derivative of the spline Green's function, divided by radial distance
  dG_scaled = @(r) merge(r == 0, 0, 1 + 2 .* log(r));
 
 a = coefs(1:n);
 b = coefs((n+1):end);

 dyi = ones(k, 1) * b(2:end)'; #derivatives of linear part

  if vectorize
    dists =  reshape(xi, k, 1, d) - reshape(x, 1, n, d);
    dist = sqrt(sumsq(dists, 3)); #Euclidian distance between points in d-dimensional space
    dyi += squeeze(sum(reshape(a, 1, n) .* dG_scaled(dist) .* dists, 2));
  else
   for i = 1:k
    for l = 1:n
      dists = xi(i, :) - x(l, :);
      dist = sqrt(sumsq(dists));    
      dyi(i, :) += a(l) * dG_scaled(dist) * dists;   
    endfor 
   endfor
  endif

endfunction
 




#check with linear functions (derivatives should be constant)
%!shared a,b,x,y,x1,x2,y1,c,dy,dy0
%! a = 2; b = -3; x = ([1:2:10 10.5 11.3])'; y = a*x;
%! c = tpaps(x,y,1);
%!assert (a*ones(size(x)), tps_val_der(x,c,x), 1E3*eps);
%! [x1 x2] = meshgrid(x, x);
%! y1 = a*x1+b*x2;
%! c = tpaps([x1(:) x2(:)],y1(:),0.5);
%! dy = tps_val_der([x1(:) x2(:)],c,[x1(:) x2(:)]);
%! dy0 = tps_val_der([x1(:) x2(:)],c,[x1(:) x2(:)],false);
%!assert (a*ones(size(x1(:))), dy(:, 1), 1E3*eps);
%!assert (b*ones(size(x2(:))), dy(:, 2), 1E3*eps); 
%!assert (dy0, dy, 1E3*eps);
