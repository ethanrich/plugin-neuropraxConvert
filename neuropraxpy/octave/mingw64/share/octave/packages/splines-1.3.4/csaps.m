## Copyright (C) 2012-2015 Nir Krakauer
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
## @deftypefn{Function File}{[@var{yi} @var{p} @var{sigma2} @var{unc_yi} @var{df}] =} csaps(@var{x}, @var{y}, @var{p}, @var{xi}, @var{w}=[])
## @deftypefnx{Function File}{[@var{pp} @var{p} @var{sigma2}] =} csaps(@var{x}, @var{y}, @var{p}, [], @var{w}=[])
##
## Cubic spline approximation (smoothing)@*
## approximate [@var{x},@var{y}], weighted by @var{w} (inverse variance of the @var{y} values; if not given, equal weighting is assumed), at @var{xi}
##
## The chosen cubic spline with natural boundary conditions @var{pp}(@var{x}) minimizes @var{p} * Sum_i @var{w}_i*(@var{y}_i - @var{pp}(@var{x}_i))^2  +  (1-@var{p}) * Int @var{pp}''(@var{x}) d@var{x}
##
## Outside the range of @var{x}, the cubic spline is a straight line
##
## @var{x} and @var{w} should be n by 1 in size; @var{y} should be n by m; @var{xi} should be k by 1; the values in @var{x} should be distinct and in ascending order; the values in @var{w} should be nonzero
##
## @table @asis
## @item @var{p}=0
##       maximum smoothing: straight line
## @item @var{p}=1
##       no smoothing: interpolation
## @item @var{p}<0 or not given
##       an intermediate amount of smoothing is chosen @*
##       and the corresponding @var{p} between 0 and 1 is returned @*
##       (such that the smoothing term and the interpolation term are of the same magnitude) @*
##       (csaps_sel provides other methods for automatically selecting the smoothing parameter @var{p}.)
## @end table
##
## @var{sigma2} is an estimate of the data error variance, assuming the smoothing parameter @var{p} is realistic
##
## @var{unc_yi} is an estimate of the standard error of the fitted curve(s) at the @var{xi}.
## Empty if @var{xi} is not provided.
##
## @var{df} is an estimate of the degrees of freedom used in the spline fit (2 for @var{p}=0, n for @var{p}=1)
## 
##
## References:  @*
## Carl de Boor (1978), A Practical Guide to Splines, Springer, Chapter XIV  @*
## Grace Wahba (1983), Bayesian ``confidence intervals'' for the cross-validated smoothing spline, Journal of the Royal Statistical Society, 45B(1):133-150
##
## @end deftypefn
## @seealso{spline, splinefit, csapi, ppval, dedup, bin_values, csaps_sel}

## Author: Nir Krakauer <nkrakauer@ccny.cuny.edu>

function [ret,p,sigma2,unc_yi,df]=csaps(x,y,p,xi,w)

warning ("off", "Octave:broadcast", "local");

  if(nargin < 5)
    w = [];
    if(nargin < 4)
      xi = [];
      if(nargin < 3)
	      p = [];
      endif
    endif
  endif

  if(columns(x) > 1)
    x = x';
    y = y';
    w = w';
  endif

  if any (isnan ([x y w](:)) )
    error('NaN values in inputs; pre-process to remove them')
  endif

  h = diff(x);
  if !all(h > 0) && !all(h < 0)
	  error('x must be strictly monotone; pre-process to achieve this')
  endif


  [n m] = size(y); #should also be that n = numel(x);
  
  if isempty(w)
    w = ones(n, 1);
  end


  R = spdiags([h(2:end) 2*(h(1:end-1) + h(2:end)) h(1:end-1)], [-1 0 1], n-2, n-2);

  QT = spdiags([1 ./ h(1:end-1) -(1 ./ h(1:end-1) + 1 ./ h(2:end)) 1 ./ h(2:end)], [0 1 2], n-2, n);
  
## if not given, choose p so that trace(6*(1-p)*QT*diag(1 ./ w)*QT') = trace(p*R)
  if isempty(p) || (p < 0)
  	r = full(6*trace(QT*diag(1 ./ w)*QT') / trace(R));
  	p = r ./ (1 + r);
  endif

## solve for the scaled second derivatives u and for the function values a at the knots
## (if p = 1, a = y; if p = 0, cc(:) = dd(:) = 0)
## QT*y can also be written as (y(3:n, :) - y(2:(n-1), :)) ./ h(2:end) - (y(2:(n-1), :) - y(1:(n-2), :)) ./ h(1:(end-1))
  u = (6*(1-p)*QT*diag(1 ./ w)*QT' + p*R) \ (QT*y);
  a = y - 6*(1-p)*diag(1 ./ w)*QT'*u;
  
## derivatives for the piecewise cubic spline  
  aa = bb = cc = dd = zeros (n+1, m);
  aa(2:end, :) = a;
  cc(3:n, :) = 6*p*u; #second derivative at endpoints is 0 [natural spline]
  dd(2:n, :) = diff(cc(2:(n+1), :)) ./ h;
  bb(2:n, :) = diff(a) ./ h - (h/3) .* (cc(2:n, :) + cc(3:(n+1), :)/2);

## add knots to either end of spline pp-form to ensure linear extrapolation
  dx_minus = eps(x(1));
  dx_plus = eps(x(end));
  xminus = x(1) - dx_minus;
  xplus = x(end) + dx_plus;
  x = [xminus; x; xplus];  
  slope_minus = bb(2, :);
  slope_plus = bb(n, :) + cc(n, :)*h(n-1) + (dd(n, :)/2)*h(n-1)^2;
  bb(1, :) = slope_minus; #linear extension of splines
  bb(n + 1, :) = slope_plus;
  aa(1, :) = a(1, :) - dx_minus*bb(1, :);
  
  ret = mkpp (x, cat (2, dd'(:)/6, cc'(:)/2, bb'(:), aa'(:)), m);
  clear a aa bb cc dd slope_minus slope_plus u #these values are no longer needed
  
  if ~isempty (xi)
    ret = ppval (ret, xi);
  endif

  if (isargout (4) && isempty (xi))
    unc_yi = [];
  endif
    
  if isargout (3) || (isargout (4) && ~isempty (xi)) || isargout (5)

    if p == 1 #interpolation assumes no error in the given data
      sigma2 = 0;
      if isargout (4) && ~isempty (xi)
        unc_yi = zeros(numel(xi), 1);
      endif
      df = n;
      return
    endif

    [U D V] = svd (diag(1 ./ sqrt(w))*QT'*sqrtm(inv(R)), 0); D = diag(D).^2;
    #influence matrix for given p
    A = speye(n) - U * diag(D ./ (D + (p / (6*(1-p))))) * U';
    A = diag (1 ./ sqrt(w)) * A * diag(sqrt(w)); #rescale to original units; a = A*y
    MSR = mean (w .* (y - (A*y)) .^ 2); #mean square residual
    df = trace (A);
    sigma2 = mean (MSR(:)) * (n / (n-df)); #estimated data error variance (wahba83)
        
    if isargout (4) && ~isempty (xi)
      ni = numel (xi);
     #dependence of spline values on each given point (to compute uncertainty)
      C = 6 * p * full ((6*(1-p)*QT*diag(1 ./ w)*QT' + p*R) \ QT); #cc(3:n, :) = C*y [sparsity is lost]
      D = diff ([zeros(n, 1) C' zeros(n, 1)]') ./ h; #dd(2:n, :) = D*y
      B = diff (A) ./ h - (h/3) .* ([zeros(n, 1) C']' + [C' zeros(n, 1)]' / 2); #bb(2:n, :) = B*y
    #add end-points
      C = [zeros(n, 2) C' zeros(n, 1)]';
      D = [zeros(n, 1) D' zeros(n, 1)]';
      B = [B(1, :)' B' B(end, :)' + C(n, :)'*h(n-1) + (D(n, :)'/2)*h(n-1)^2]';
      A = [A(1, :)'-eps(x(1))*B(1, :)' A']';
    #sum the squared dependence on each data value y at each requested point xi
      unc_yi = zeros (ni, 1);
      for i = 1:n
        unc_yi += (ppval (mkpp (x, cat (2, D(:, i)/6, C(:, i)/2, B(:, i), A(:, i))), xi(:))) .^ 2;
      endfor
      unc_yi = sqrt (sigma2 * unc_yi); #not exactly the same as unc_y as calculated in csaps_sel even if xi = x, but fairly close
      endif  
  endif      


endfunction

%!shared x,y,xi,yi,p,sigma2,unc_yi,df
%! x = ([1:10 10.5 11.3])'; y = sin(x); xi = linspace(min(x), max(x), 30)';
%!assert (csaps(x,y,1,x), y, 10*eps);
%!assert (csaps(x,y,1,x'), y', 10*eps);
%!assert (csaps(x',y',1,x'), y', 10*eps);
%!assert (csaps(x',y',1,x), y, 10*eps);
%!assert (csaps(x,[y 2*y],1,x)', [y 2*y], 10*eps);
%! [yi,p,sigma2,unc_yi,df] = csaps(x,y,1,xi);
%!assert (yi, ppval(csape(x, y, "variational"), xi), eps);
%!assert (p, 1);
%!assert (unc_yi, zeros(size(xi)));
%!assert (sigma2, 0);
%!assert (df, numel(x));
%! [yi,p,~,~,df] = csaps(x,y,0,xi);
%!assert (yi, polyval(polyfit(x, y, 1), xi), 10*eps);
%!assert (p, 0);
%!assert (df, 2, 100*eps);

%{
test weighted smoothing:
n = 500;
a = 0; b = pi;
f = @(x) sin(x);
x = a + (b-a)*sort(rand(n, 1));
w = rand(n, 1);
y = f(x) + randn(n, 1) ./ sqrt(w);
xi = linspace(a, b, n)';
yi_target = f(xi);
[~,p_sel] = csaps_sel(x, y, xi, w, 1);
[yi,~,sigma2,unc_yi] = csaps(x,y,p_sel,xi,w);
rmse = rms((yi - yi_target));
rmse_weighted = rms((yi - yi_target) ./ unc_yi);
#worse results without the (correct) weighting:
[~,p_sel] = csaps_sel(x, y, xi, []);
[yi,~,sigma2,unc_yi] = csaps(x,y,p_sel,xi,[]);
rmse_u = rms((yi - yi_target));
rmse_u_weighted = rms((yi - yi_target) ./ unc_yi);
%}
