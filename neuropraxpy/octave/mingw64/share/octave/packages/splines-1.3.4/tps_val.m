## Copyright (C) 2013 Nir Krakauer
##
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2 of the License, or
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
## @deftypefn{Function File}{[@var{yi}] =} tps_val(@var{x}, @var{coefs}, @var{xi}, @var{vectorize}=true)
##
## Evaluates a thin plate spline at given points @*
## @var{xi}
## 
## @var{coefs} should be the vector of fitted coefficients returned from @code{tpaps(x, y, [p])}
##
## @var{x} should be @var{n} by @var{d} in size, where @var{n} is the number of points and @var{d} the number of dimensions; @var{coefs} should be @var{n} + @var{d} + 1 by 1; @var{xi} should be @var{k} by @var{d}
##
## The logical argument @var{vectorize} controls whether an @var{k} by @var{n} by @var{d} intermediate array is formed to speed up computation (the default) or whether looping is used to economize on memory
##
## The returned @var{yi} will be @var{k} by 1
##
## See the documentation to @code{tpaps} for more information
##
## @end deftypefn
## @seealso{tpaps, tps_val_der}

## Author: Nir Krakauer <nkrakauer@ccny.cuny.edu>

function [yi]=tps_val(x,coefs,xi,vectorize=true)


  [n d] = size(x); #d: number of dimensions; n: number of points
  k = size(xi, 1); #number of points for which to find the spline function value

  #form of the Green's function for solutions
  G = @(r) merge(r == 0, 0, r .^ 2 .* log(r));
 
 a = coefs(1:n);
 b = coefs((n+1):end);

 
 yi = [ones(k, 1) xi] * b;
 if vectorize
   if d == 1
    yi = yi + G(abs(x' - xi)) * a;
   else
    yi = yi + G(sqrt(sumsq((reshape(x, 1, n, d) - reshape(xi, k, 1, d)), 3))) * a;
   endif
 else
   dist = @(x1, x2) norm(x2 - x1, 2, "rows"); #Euclidian distance between points in d-dimensional space
   warn_state = warning ("query", "Octave:broadcast").state;
   warning ("off", "Octave:broadcast"); #turn off warning message for automatic broadcasting when dist is called
   unwind_protect
  if k > n ##choose from either of two ways of computing the values of the thin plate spline at xi
    for i = 1:n
      yi = yi + a(i)*G(dist(x(i, :), xi));
    endfor
  else
    for i = 1:k
      yi(i) = yi(i) + dot(a, G(dist(x, xi(i, :))));
    endfor
  endif
   unwind_protect_cleanup
   warning (warn_state, "Octave:broadcast");
   end_unwind_protect
 endif


endfunction

%!shared x,y,c,xi
%! x = ([1:10 10.5 11.3])'; y = sin(x);
%! c = tpaps(x,y,1);
%!assert (tpaps(x,y,1,x), tps_val(x,c,x), 100*eps);
%! x = ((1 ./ (1:100))' - 0.5) * ([0.2 0.6]);
%! y = x(:, 1) .^ 2 + x(:, 2) .^ 2;
%! c = tpaps(x,y,1);
%!assert (tpaps(x,y,1,x), tps_val(x,c,x), 100*eps);
%!assert (tps_val(x,c,x,true), tps_val(x,c,x,false), 100*eps);
