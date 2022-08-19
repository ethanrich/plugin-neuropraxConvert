## Copyright (C) 2021 Andreas Stahel
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
## @deftypefn {Function File} {[@var{grid},@var{u},@var{data_valid}] =} regularization2D (@var{data}, @var{box}, @var{N}, @var{lambda1},@var{lambda2})
##
## Apply a Tikhonov regularization, the functional to be minimized is@*
## @var{F} = @var{FD} + @var{lambda1} * @var{F1} + @var{lambda2} * @var{F2} @*
##   = sum_(i=1)^M (y_i-u(x_i))^2 +@*
##  + @var{lambda1} * dintegral (du/dx)^2+(du/dy)^2 dA +@*
##  + @var{lambda2} * dintegral (d^2u/dx^2)^2+(d^2u/dy^2)^2+2*(d^2u/dxdy) dA
##
## With @var{lambda1} = 0 and @var{lambda2}>0 this leads to a thin plate smoothing spline.
##
## Parameters:
## @itemize
## @item @var{data} is a M*3 matrix with the (x,y) values in the first two columns and the y values in the third column.@*
## Only data points strictly inside the @var{box} are used
## @item @var{box} = [x0,x1;y0,y1] is the rectangle x0<x<x1 and y0<y<y1 on which the regularization is applied.
## @item @var{N} = [N1,N2] determines the number of subintervals of equal length. @var{grid} will consist of (@var{N1+1})x(@var{N2+1}) grid points.
## @item @var{lambda1} >= 0 is the value of the first regularization parameter
## @item @var{lambda2} > 0 is the value of the secondregularization parameter
## @end itemize
##
## Return values:
## @itemize
## @item @var{grid} is the grid on which @var{u} is evaluated. It consists of
## (@var{N1+1})x(@var{N2}+1) equidistant points on the the rectangle @var{box}.
## @item @var{u} are the values of the regularized approximation to the @var{data} evaluated on the @var{grid}.
## @item @var{data_valid} returns the values data points used and the values of the regularized function at these points
## @end itemize
## @seealso {tpaps, regularization, demo regularization2D}
## @end deftypefn

## Author: Andreas Stahel <sha1@bfh.ch>
## Created: 2021-01-13

function [grid,u,data_valid] = regularization2D (data, box, N, lambda1, lambda2)
%% generate the grid
  N = N+1;  %%%  now N is the number of grid points in either direction
  x = linspace(box(1,1),box(1,2),N(1));
  y = linspace(box(2,1),box(2,2),N(2));
  [xx,yy] = meshgrid(x,y);
  dx = diff(box(1,:))/(N(1)-1);  dy = diff(box(2,:))/(N(2)-1);
  grid.x  = xx;
  grid.y  = yy;
  x = data (:,1); y = data(:,2); z = data(:,3); 
  ## select points in box only
  ind = find ((x > box(1,1)) .* (x < box(1,2)) .* (y > box(2,1)) .* (y < box(2,2)));
  x = x (ind); y = y (ind); z = z (ind);
  %% generate the sparse interpolation matrix
  M = length (x);
  x_ind = floor((x-box(1,1))/dx);
  %% xi = mod(x,dx)/dx;
  xi = (x-box(1,1)-x_ind*dx)/dx;
  y_ind = floor((y-box(2,1))/dy);
  %%nu = mod(y,dy)/dy;
  nu = (y-box(2,1)-y_ind*dy)/dy;
  row = ones(4,1)*[1:M]; 
  index_base = N(2)*x_ind+y_ind+1;
  index = index_base + [0,N(2),1,N(2)+1]; index = index';
  coeff = [(1-xi).*(1-nu),xi.*(1-nu),(1-xi).*nu,xi.*nu]; coeff = coeff';
  Interp = sparse(row(:),index(:),coeff(:),M,N(1)*N(2));
  mat = Interp' * Interp;
  rhs = (Interp' * z);
  
%%% derivative with respect to x
  Dx = kron(spdiags(ones(N(1),1)*[-1 1],[0 1],N(1)-1,N(1))/dx,speye(N(2)));
  Wx = ones(N(2),1); Wx(1) = 1/2; Wx(N(2)) = 1/2;
  Wx = kron(speye(N(1)-1),diag(Wx))*dx*dy;
%%% derivative with respect to y
 
  Wy = ones(N(1),1); Wy(1) = 1/2; Wy(N(1)) = 1/2;
  Wy = kron(diag(Wy),speye(N(2)-1))*dx*dy;
  if lambda1 > 0
    Dy = kron(speye(N(1)),spdiags(ones(N(2),1)*[-1 1],[0 1],N(2)-1,N(2))/dy);
    mat += lambda1*(Dx'*Wx*Dx + Dy'*Wy*Dy);
  endif

%%% second derivative with respect to x
  Dxx = spdiags(ones(N(1),1)*[1 -1 -1 1],[-1 0 1 2],N(1)-1,N(1));
  Dxx(1,1:4) = [3 -7 5  -1]; Dxx(N(1)-1,N(1)-3:N(1)) = [-1 5 -7 3];
  Dxx = Dxx/(2*dx^2);
  Dxx = kron(Dxx,speye(N(2)));
%%% second derivative with respect to y
  Dyy = spdiags(ones(N(2),1)*[1 -1 -1 1],[-1 0 1 2],N(2)-1,N(2));
  Dyy(1,1:4) = [3 -7 5  -1]; Dyy(N(2)-1,N(2)-3:N(2)) = [-1 5 -7 3];
  Dyy = Dyy/(2*dy^2);
  Dyy = kron(speye(N(1)),Dyy);
%%% mixed second derivative
  Dy2 = kron(speye(N(1)-1),spdiags(ones(N(2),1)*[-1 1],[0 1],N(2)-1,N(2))/dy);
  Dxy = Dy2*Dx*sqrt(dx*dy);
  mat += lambda2*(Dxx'*Wx*Dxx + Dyy'*Wy*Dyy + 2*Dxy'*Dxy);

%%% solve
  u = reshape(mat\rhs,N(2),N(1));
  if nargout>2
    data_valid =[x,y,Interp*u(:)];
  endif

endfunction

%!demo
%! M = 100;
%! lambda1 = 0; lambda2 = 0.05;
%! x = 2*rand(M,1)-1;     y = 2*rand(M,1)-1;
%! z = x.*y + 0.1*randn(M,1);
%! data = [x,y,z];
%! [grid,u] = regularization2D(data,[-1 1;-1 1],[50 50],lambda1,lambda2);
%! figure()
%! mesh(grid.x, grid.y,u)
%! xlabel('x'); ylabel('y');
%! hold on
%! plot3(data(:,1),data(:,2),data(:,3),'*b','Markersize',2)
%! hold off
%! view([30,30]);

%!demo
%! lambda1 = 0; lambda2 = 0.01;
%! M = 4;  angles = [1:M]/M*2*pi;  
%! data = zeros(M+1,3);  data(M+1,3) = 1;
%! data(1:M,1) = cos(angles); data(1:M,2) = sin(angles);
%! [grid,u] = regularization2D(data,[-1.5 1.5;-1.5 1.5],[50 50],lambda1,lambda2);
%! figure()
%! mesh(grid.x, grid.y,u)
%! xlabel('x'); ylabel('y');
%! hold on
%! plot3(data(:,1),data(:,2),data(:,3),'*b','Markersize',2)
%! hold off

%!test
%! data = [0,0,0;1,2,3;2,0,2;0,2,2];  % data on z = x+y
%! lambda1 = 0.0 ; lambda2 = 0.1;
%! [grid,u,u_valid] = regularization2D(data,[-0.2 2.2; -0.2,2.2],[11,12],lambda1,lambda2);
%! assert(norm(data-u_valid),0,1e-12)
%! assert(norm(grid.x(:) + grid.y(:) - u(:)),0,1e-10)

%!test
%! data = [0,0,0;1,1,3;2,1,2;0,2,-2;-1.5,-1,0;-2,2,0];
%! lambda1 = 0.001 ; lambda2 = 0.01;
%! [grid,u,u_valid] = regularization2D(data,[-2.1 2.1;-2.1,2.1],[40,50],lambda1,lambda2);
%!  value_at_data = [   1.233351091378741e-01
%!   2.694454049778803e+00
%!   2.102786670571836e+00
%!  -1.870655633783656e+00
%!  -1.635243922246946e-02
%!  -3.356775648311422e-02];
%! assert(norm(value_at_data-u_valid(:,3)),0,1e-12)
