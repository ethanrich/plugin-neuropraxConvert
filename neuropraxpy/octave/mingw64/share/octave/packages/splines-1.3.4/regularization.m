## Copyright (C) 2019 Andreas Stahel
## 
## This program is free software: you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation, either version 3 of the License, or
## (at your option) any later version.
## 
## This program is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
## 
## You should have received a copy of the GNU General Public License
## along with this program.  If not, see
## <https://www.gnu.org/licenses/>.

## -*- texinfo -*- 
## @deftypefn {Function File} {[@var{grid},@var{u}] =} regularization (@var{data}, @var{interval}, @var{N}, @var{F1})
## @deftypefnx {Function File} {[@var{grid},@var{u}] =} regularization (@var{data}, @var{interval}, @var{N}, @var{F1}, @var{F2})
##
## Apply a Tikhonov regularization, the functional to be minimized is@*
## @var{F} = @var{FD} + @var{lambda1}*@var{F1} + @var{lambda2}*@var{F2} @*
##  = sum_(i=1)^M (y_i-u(x_i))^2
## + @var{lambda1}*int_a^b (u'(x)  - @var{g1}(x))^2 dx
## + @var{lambda2}*int_a^b (u''(x) - @var{g2}(x))^2 dx
##
## With @var{lambda1} = 0 and @var{G2}(x) = 0 this leads to a smoothing spline.
##
## Parameters:
## @itemize
## @item @var{data} is a M*2 matrix with the x values in the first column and the y values in the second column.
## @item @var{interval} = [a,b] is the interval on which the regularization is applied.
## @item @var{N} is the number of subintervals of equal length. @var{grid} will consist of @var{N+1} grid points.
## @item @var{F1} is a structure containing the information on the first regularization term, integrating the square of the first derivative.
## @itemize
## @item @var{F1.lambda} is the value of the regularization parameter @var{lambda1}>=0.
## @item @var{F1.g} is the function handle for the function @var{g1(x)}. If not provided @var{G1=0} is used.
## @end itemize
## @item @var{F2} is a structure containing the information on the second regularization term, integrating the square of the second derivative. If @var{F2} is not provided @var{lambda2}=0 is assumed.
## @itemize
## @item @var{F2.lambda} is the value of the regularization parameter @var{lambda2}>=0.
## @item @var{F2.g} is the function handle for the function @var{g2(x)}. If not provided @var{G2=0} is used.
## @end itemize
## @end itemize
##
## Return values:
## @itemize
## @item @var{grid} is the grid on which @var{u} is evaluated. It consists of @var{N+1} equidistant points on the @var{interval}.
## @item @var{u} are the values of the regularized approximation to the @var{data} evaluated at @var{grid}.
## @end itemize
## @seealso{csaps, regularization2D, demo regularization}
## @end deftypefn

## Author: Andreas Stahel <sha1@bfh.ch>
## Created: 2019-03-26

function [grid,u] = regularization (data, interval, N, F1, F2)
  a = interval (1);  b = interval (2);
  grid = linspace (a, b, N + 1)';
  dx = grid (2) - grid (1);
  x = data (:, 1);
  ## select points in interval only
  ind = find ((x >= a) .* (x <= b));
  x = x (ind);
  y = data (:, 2);  y = y (ind);
  M = length (x);
  Interp = sparse (M, N + 1);  ## interpolation matrix
  pos = floor ((x - a) / dx) + 1;
  theta = mod ((x - a) / dx, 1);
  for ii = 1:M
    if theta (ii) > 10*eps
      Interp (ii, pos (ii)) = 1 - theta (ii);
      Interp (ii, pos (ii) + 1) = theta (ii);
    else
      Interp (ii, pos (ii)) = 1;
    endif
  endfor
  mat = Interp' * Interp;
  rhs = (Interp' * y);
  if isfield (F1, 'lambda')
    A1 = spdiags ([-ones(N, 1), +ones(N, 1)], [0, 1], N, N + 1) / dx;
    mat = mat + F1.lambda * dx * A1' * A1;
    if isfield (F1, 'g')
      g1 = F1.g (grid (1:end - 1) + dx / 2);
      rhs = rhs + F1.lambda * dx * A1' * g1;
    endif
  endif
  if exist ('F2')
    A2 = spdiags (ones (N, 1) * [1, -2, 1], [0, 1, 2], N - 1, N + 1) / dx^2;
    mat = mat + F2.lambda * dx * A2' * A2;
    if isfield (F2, 'g')
      g2 = F2.g (grid (2:end - 1));
      rhs = rhs + F2.lambda * dx * A2' * g2;
      endif
  endif
  u = mat \ rhs;
endfunction

%!demo
%! N = 100;   interval = [0,10];
%! x = [3.2,4,5,5.2,5.6]'; y = x;
%!
%! clear F1 F2
%! %% regularize towards slope 0.1, no smoothing
%! F1.lambda = 1e-2;   F1.g = @(x)0.1*ones(size(x));
%! [grid,u1] = regularization([x,y],interval,N,F1);
%! %% regularize towards slope 0.1, with some smoothing
%! F2.lambda = 1*1e-3;
%! [grid,u2] = regularization([x,y],interval,N,F1,F2);
%!
%! figure(1)
%! plot(grid,u1,'b',grid,u2,'g',x,y,'*r')
%! xlabel('x'); ylabel('solution');
%! legend('regular1','regular2','data','location','northwest')

%!demo
%! N = 1000;   interval = [0,pi];
%! x = linspace( pi/4,3*pi/4,15)';   y = sin(x)+ 0.03*randn(size(x));
%!
%! clear F1 F2
%! %% regularize by smoothing only
%! F1.lambda = 0;  F2.lambda = 1e-3;
%! [grid,u1] = regularization([x,y],interval,N,F1,F2);
%! %% regularize by smoothing and aim for slope 0
%! F1.lambda = 1*1e-2;
%! [grid,u2] = regularization([x,y],interval,N,F1,F2);
%! 
%! figure(1)
%! plot(grid,u1,'b',grid,u2,'g',x,y,'*r')
%! xlabel('x'); ylabel('solution');
%! legend('regular1','regular2','data','location','northwest')

%!demo
%! interval = [0,1];
%! N = 400;
%! x = rand(200,1);
%! %% generate the data on four line segments, add some noise
%! y = 2 - 2*x + (x>0.25) - 2*(x>0.5).*(x<0.65)+ 0.1*randn(length(x),1);
%! clear F1
%! %% apply regularization with three different parameters
%! F1.lambda = 1e-3; [grid,u1] = regularization([x,y],interval,N,F1);
%! F1.lambda = 1e-1; [grid,u2] = regularization([x,y],interval,N,F1);
%! F1.lambda = 3e+0; [grid,u3] = regularization([x,y],interval,N,F1);
%! 
%! figure(1); plot(grid,u1,'b',grid,u2,'g',grid,u3,'m',x,y,'+r')
%!            xlabel('x'); ylabel('solution')
%!            legend('\lambda_1=0.001','\lambda_1=0.1','\lambda_1=3','data')

%!demo
%! %% generate a smoothing spline, see also csaps() in the package splines
%! N = 1000;  interval = [0,10.3];
%! x = [0 3 4 6 10]';  y = [0 1 0 1 0]';
%! clear F2
%! F2.lambda = 1e-2;
%! %% apply regularization, the result is a smoothing spline
%! [grid,u] = regularization([x,y],interval,N,0,F2);
%! 
%! figure(1);
%! plot(grid,u,'b',x,y,'*r')
%! legend('spline','data')
%! xlabel('x'); ylabel('solution')


%!test
%! data = [0,0;1,1;2,2];
%! F1.lambda = 0.0; F2.lambda = 0.1;
%! [grid,u] = regularization(data,[0,1],10,F1,F2);
%! assert(norm(grid-u),0,1e-12)

%!test
%! x = linspace(-1,1,11); 
%! F1.lambda = 0.01;F2.g = @(x) 2*ones(size(x)); F2.lambda = 0.01;
%! [grid,u] = regularization([x;x.^2]',[-2,2],20,F1,F2);
%! assert(u(11),7.330959483903200e-03,1e-8)

