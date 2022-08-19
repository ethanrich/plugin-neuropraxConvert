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
## @deftypefn{Function File}{[@var{yi} @var{p}] =} tpaps(@var{x}, @var{y}, @var{p}, @var{xi})
## @deftypefnx{Function File}{[@var{coefs} @var{p}] =} tpaps(@var{x}, @var{y}, @var{p}, [])
##
## Thin plate smoothing of scattered values in multi-D @*
## approximately interpolate [@var{x},@var{y}] at @var{xi}
##
## The chosen thin plate spline minimizes the sum of squared deviations from the given points plus a penalty term proportional to the curvature of the spline function
##
## @var{x} should be @var{n} by @var{d} in size, where @var{n} is the number of points and @var{d} the number of dimensions; @var{y} and @var{w} should be @var{n} by 1; @var{xi} should be @var{k} by @var{d}; the points in @var{x} should be distinct
##
## @table @asis
## @item @var{p}=0
##       maximum smoothing: flat surface
## @item @var{p}=1
##       no smoothing: interpolation
## @item @var{p}<0 or not given
##       an intermediate amount of smoothing is chosen (such that the smoothing term and the interpolation term are of the same magnitude)
## @end table
## 
## If @var{xi} is not specified, returns a vector @var{coefs} of the @var{n} + @var{d} + 1 fitted thin plate spline coefficients.
## Given @var{coefs}, the value of the thin-plate spline at any @var{xi} can be determined with @code{tps_val}
##  
## Note: Computes the pseudoinverse of an @var{n} by @var{n} matrix, so not recommended for very large @var{n}
##
## Example usages:
## @example
## x = ([1:10 10.5 11.3])'; y = sin(x); xi = (0:0.1:12)';
## yi = tpaps(x, y, 0.5, xi); 
## plot(x, y, xi, yi)
## @end example
## 
## @example
## x = rand(100, 2)*2 - 1; 
## y = x(:, 1) .^ 2 + x(:, 2) .^ 2;
## scatter(x(:, 1), x(:, 2), 10, y, "filled")
## [x1 y1] = meshgrid((-1:0.2:1)', (-1:0.2:1)');
## xi = [x1(:) y1(:)];
## yi = tpaps(x, y, 1, xi);
## contourf(x1, y1, reshape(yi, 11, 11))
## @end example
## 
## Reference: 
## David Eberly (2011), Thin-Plate Splines, www.geometrictools.com/Documentation/ThinPlateSplines.pdf
## Bouhamidi, A. (2005) Weighted thin plate splines, Analysis and Applications, 3: 297-324
##
## @end deftypefn
## @seealso{csaps, tps_val, tps_val_der}

## Author: Nir Krakauer <nkrakauer@ccny.cuny.edu>

function [ret, p]=tpaps(x,y,p,xi)


  if(nargin < 4)
    xi = [];
    if(nargin < 3) || p < 0
      p = [];
    endif
  endif


  [n d] = size(x); #d: number of dimensions; n: number of points [y should be n*1]

  dist = @(x1, x2) norm(x2 - x1, 2, "rows"); #Euclidian distance between points in d-dimensional space
  
  #form of the Green's function for solutions
  G = @(r) merge(r == 0, 0, r .^ 2 .* log(r));
 
  N = [ones(n, 1) x]; 
  
  if p == 0 #infinite regularization (no curvature allowed), solution is a regression plane
  
    b = N \ y;
    
    a = zeros(n, 1);
    
  else  
  
    #coefficient matrices
    #need pairwise distances between points
    M = zeros(n);
     warn_state = warning ("query", "Octave:broadcast").state;
     warning ("off", "Octave:broadcast"); #turn off warning message for automatic broadcasting when dist is called
     unwind_protect
    for i = 1:(n-1) #M is symmetric, so only need to compute half
      M(i, (i+1):n) = G(dist(x(i, :), x((i+1):n, :)));
    endfor
     unwind_protect_cleanup
     warning (warn_state, "Octave:broadcast");
     end_unwind_protect    
    M = M + M';
    if isempty(p) #choose an intermediate value for the regularization parameter
      lambda = mean(spdiags(M, 1:min(n, 3))(:));
      p = 1 / (lambda + 1);
    else #use the given value
      lambda = (1 - p) / p;
    endif
    
    M = M + lambda*eye(n); #add regularization term
   
    M_inv = pinv(M);
   
    b = pinv(N' * M_inv * N) * N' * M_inv * y;
    
    a = M_inv * (y - N*b);
  
  endif
  
    
  if isempty(xi) #return the coefficients
      ret = [a' b']';
  else #return the thin plate spline values at xi
      k = size(xi, 1);
      ret = [ones(k, 1) xi] * b;
      if p ~= 0     
         warn_state = warning ("query", "Octave:broadcast").state;
         warning ("off", "Octave:broadcast"); #turn off warning message for automatic broadcasting when dist is called
         unwind_protect
        if k > n ##choose from either of two ways of computing the values of the thin plate spline at xi
          for i = 1:n
            ret = ret + a(i)*G(dist(x(i, :), xi));
          endfor
        else
          for i = 1:k
            ret(i) = ret(i) + dot(a, G(dist(x, xi(i, :))));
          endfor
        endif
         unwind_protect_cleanup
         warning (warn_state, "Octave:broadcast");
         end_unwind_protect  
      endif
  endif


endfunction

%!shared x,y
%! x = ([1:10 10.5 11.3])'; y = sin(x);
%!assert (tpaps(x,y,1,x), y, 1E3*eps);
%! x = ((1 ./ (1:100))' - 0.5) * ([0.2 0.6]);
%! y = x(:, 1) .^ 2 + x(:, 2) .^ 2;
%!assert (tpaps(x,y,1,x), y, 1E-10);
