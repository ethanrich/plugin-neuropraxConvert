## Copyright (C) 2007-2019 Andreas Stahel <Andreas.Stahel@bfh.ch>
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


## -*- texinfo -*-
## @deftypefn {Function File} {} LinearRegression (@var{F}, @var{y})
## @deftypefnx {Function File} {} LinearRegression (@var{F}, @var{y}, @var{w})
## @deftypefnx {Function File} {[@var{p}, @var{e_var}, @var{r}, @var{p_var}, @var{fit_var}] =} LinearRegression (@dots{})
##
##
## general linear regression
##
## determine the parameters p_j  (j=1,2,...,m) such that the function
## f(x) = sum_(j=1,...,m) p_j*f_j(x) is the best fit to the given values
## y_i by f(x_i) for i=1,...,n, i.e. minimize
## sum_(i=1,...,n)(y_i-sum_(j=1,...,m) p_j*f_j(x_i))^2 with respect to p_j
##
## parameters:  
## @itemize
## @item @var{F} is an n*m matrix with the values of the basis functions at
## the support points. In column j give the values of f_j at the points
## x_i  (i=1,2,...,n)
## @item @var{y} is a column vector of length n with the given values
## @item @var{w} is a column vector of length n with the weights of
## the data points. 1/w_i is expected to be proportional to the
## estimated uncertainty in the y values. Then the weighted expression
## sum_(i=1,...,n)(w_i^2*(y_i-f(x_i))^2) is minimized.
## @end itemize
##
## return values:
## @itemize
## @item @var{p} is the vector of length m with the estimated values
## of the parameters
## @item @var{e_var} is the vector of estimated variances of the
## provided y values. If weights are provided, then the product
## e_var_i * w^2_i is assumed to be constant.
## @item @var{r} is the weighted norm of the residual
## @item @var{p_var} is the vector of estimated variances of the parameters p_j
## @item @var{fit_var} is the vector of the estimated variances of the
## fitted function values f(x_i)
## @end itemize
##
## To estimate the variance of the difference between future y values
## and fitted y values use the sum of @var{e_var} and @var{fit_var}
##
## Caution:  
## do NOT request @var{fit_var} for large data sets, as a n by n matrix is
## generated
##
## @c Will be cut out in optims info file and replaced with the same
## @c refernces explicitely there, since references to core Octave
## @c functions are not automatically transformed from here to there.
## @c BEGIN_CUT_TEXINFO
## @seealso{ols,gls,regress,leasqr,nonlin_curvefit,polyfit,wpolyfit,expfit}
## @c END_CUT_TEXINFO
##  @end deftypefn

function [p, e_var, r, p_var, fit_var] = LinearRegression (F, y, weight)

  if (nargin < 2 || nargin >= 4)
    print_usage ();
  endif

  [rF, cF] = size (F);
  [ry, cy] = size (y);
  
  if (rF != ry || cy > 1)
    error ('LinearRegression: incorrect matrix dimensions');
  endif

  if (nargin == 2)  # set uniform weights if not provided
    weight = ones (size (y));
  else
    weight = weight(:);
  endif

  wF = diag (weight) * F;  # this is efficent with the diagonal matrix

  [Q, R] = qr (wF, 0);       # estimate the values of the parameters
  p = R \ (Q' * (weight .* y));

  ## Compute the residual vector and its weighted norm
  residual = F * p - y;
  r = norm (weight .* residual);

  weight2 = weight.^2;
  ## If the variance of data y is sigma^2 / weight.^2, var is an
  ## unbiased estimator of sigma^2
  var = residual.^2' * weight2 / (rF - cF);
  ## Estimated variance of data y
  e_var = var ./ weight2;

  ## Compute variance of parameters, only if requested
  if (nargout > 3)

    M = R \ (Q' * diag (weight));

    ## compute variance of the fitted values, only if requested
    if (nargout > 4)
      ## WARNING the nonsparse matrix M2 is of size rF by rF, rF =
      ## number of data points
      M2 = (F * M).^2;
      fit_var =  M2 * e_var;  # variance of the function values
    endif
    
    p_var = M.^2 * e_var;  # variance of the parameters
    
  endif

endfunction

%!demo
%! n = 50;
%! x = sort (rand (n,1) * 5 - 1);
%! y = 1 + 0.05 * x + 0.1 * randn (size (x));
%! F = [ones(n, 1), x(:)];
%! [p, e_var, r, p_var, fit_var] = LinearRegression (F, y);
%! yFit = F * p;
%! figure ()
%! plot(x, y, '+b', x, yFit, '-g',...
%!      x, yFit + 1.96 * sqrt (e_var), '--r',...
%!      x, yFit + 1.96 * sqrt (fit_var), '--k',...
%!      x, yFit - 1.96 * sqrt (e_var), '--r',...
%!      x, yFit - 1.96 * sqrt (fit_var), '--k')
%! title ('straight line fit by linear regression')
%! legend ('data','fit','+/-95% y values','+/- 95% fitted values','location','northwest')
%! grid on

%!demo
%! n = 100;
%! x = sort (rand (n, 1) * 5 - 1);
%! y = 1 + 0.5 * sin (x) + 0.1 * randn (size (x));
%! F = [ones(n, 1), sin(x(:))];
%! [p, e_var, r, p_var, fit_var] = LinearRegression (F, y);
%! yFit = F * p;
%! figure ()
%! plot (x, y, '+b', x, yFit, '-g', x, yFit + 1.96 * sqrt (fit_var),
%!       '--r', x, yFit - 1.96 * sqrt (fit_var), '--r')
%! title ('y = p1 + p2 * sin (x) by linear regression')
%! legend ('data', 'fit', '+/-95% fitted values')
%! grid on

%!demo
%! n = 50;
%! x = sort (rand (n, 1) * 5 - 1);
%! y = 1 + 0.5 * x;
%! dy = 1 ./ y;  # constant relative error is assumed
%! y = y + 0.1 * randn (size (x)) .* y;  # straight line with relative size noise
%! F = [ones(n, 1), x(:)];
%! [p, e_var, r, p_var, fit_var] = LinearRegression (F, y, dy); # weighted regression
%! fitted_parameters_and_StdErr = [p, sqrt(p_var)]
%! yFit = F * p;
%! figure ()
%! plot(x, y, '+b', x, yFit, '-g',...
%!      x, yFit + 1.96 * sqrt (e_var), '--r',...
%!      x, yFit + 1.96 * sqrt (fit_var), '--k',...
%!      x, yFit - 1.96 * sqrt (e_var), '--r',...
%!      x, yFit - 1.96 * sqrt (fit_var), '--k')
%! title ('straight line by weighted linear regression')
%! legend ('data','fit','+/-95% y values','+/- 95% fitted values','location','northwest')
%! grid on

