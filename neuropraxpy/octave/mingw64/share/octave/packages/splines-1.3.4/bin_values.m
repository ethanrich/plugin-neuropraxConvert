## Copyright (C) 2011-2013 Nir Krakauer
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

# -*- texinfo -*-
## @deftypefn{Function File}{[@var{x_bin} @var{y_bin} @var{w_bin} @var{n_bin}] =} bin_values(@var{x}, @var{y}, @var{k})
##
## Average values over ranges of one variable@*
## Given @var{x} (size @var{n}*1) and @var{y} (@var{n}*@var{m}), this function splits the range of @var{x} into up to @var{k} intervals (bins) containing approximately equal numbers of elements, and for each part of the range computes the mean of y.
##
## Any NaN values are removed.
##
## Useful for detecting possible nonlinear dependence of @var{y} on @var{x} and as a preprocessor for spline fitting.
## E.g., to make a plot of the average behavior of y versus x: @code{errorbar(x_bin, y_bin, 1 ./ sqrt(w_bin)); grid on}
##
## Inputs:@*
## @var{x}: @var{n}*1 real array@*
## @var{y}: @var{n}*@var{m} array of values at the coordinates @var{x}@*
## @var{k}: Desired number of bins, @code{floor(sqrt(n))} by default
##
## Outputs:@*
## @var{x_bin}, @var{y_bin}: Mean values by bin (ordered by increasing @var{x}) @*
## @var{w_bin}: Weights (inverse standard error of each element in @var{y_bin}; note: will be NaN or Inf where @var{n_bin} = 1)@*
## @var{n_bin}: Number of elements of @var{x} per bin
## @end deftypefn
## @seealso{csaps, dedup}

## Author: Nir Krakauer

function [x_bin y_bin w_bin n_bin] = bin_values(x, y, k=[])

#remove any rows with missing entries
notnans = !any (isnan ([x y]) , 2);
x = x(notnans);
y = y(notnans, :);

[n, m] = size(y);
#x should be n by 1

if isempty(k)
	k = floor(sqrt(n)); #reasonable default
end

if k <= 1 #only a single bin
	x_bin_mean = mean(x);
	y_bin_mean = mean(y);
	w = n / var(y_bin_mean);
	n_bin = n;
	return
end

#arrange values in increasing order of x
[x, i] = sort (x);
y = y(i, :);

#decide where to separate bins
bound_inds = 1 + (n-1)*(1:(k-1))/k;
bound_x = unique(interp1((1:n)', x, bound_inds));

#assign each point an index corresponding to its bin
idx = lookup(bound_x, x);
#get number of elements in each bin
[ids, ~, j] = unique(idx); #k = numel(ids);

#calculate the desired outputs
n_bin = accumarray(j, 1);
x_bin = accumarray(j, x, [], @mean);
y_bin = accumdim(j, y, 1, [], @mean);
f = @(x, dim) var(x, [], dim);
warning ("off", "Octave:broadcast", "local");
w_bin = n_bin ./ accumdim(j, y, 1, [], f);


%!shared x, y, x_bin, y_bin, w_bin, n_bin
%! x = [1; 2; 2; 3; 4];
%! y = [0 0; 1 1; 2 1; 3 4; 5 NaN];
%! [x_bin y_bin w_bin n_bin] = bin_values(x, y);
%!assert (x_bin, [1; 7/3]);
%!assert (y_bin, [0 0; 2 2]);
%!assert (!any(isfinite(w_bin(1, :))));
%!assert (w_bin(2, :), [3 1]);
%!assert (n_bin, [1; 3]);


