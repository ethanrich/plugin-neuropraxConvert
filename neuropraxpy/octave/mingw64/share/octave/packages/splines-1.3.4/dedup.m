## Copyright (C) 2013 Nir Krakauer
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
## @deftypefn{Function File}{[@var{x_new} @var{y_new} @var{w_new}] =} dedup(@var{x}, @var{y}, @var{w}, @var{tol}, @var{nan_remove}=true)
##
## De-duplication and sorting to facilitate spline smoothing@*
## Points are sorted in ascending order of @var{x}, with each set of duplicates (values with the same @var{x}, within @var{tol}) replaced by a weighted average.
## Any NaN values are removed (if the flag @var{nan_remove} is set).
##
## Useful, for example, as a preprocessor to spline smoothing
##
## Inputs:@*
## @var{x}: @var{n}*1 real array@*
## @var{y}: @var{n}*@var{m} array of values at the coordinates @var{x}@*
## @var{w}: @var{n}*1 array of positive weights (inverse error variances); @code{ones(size(x))} by default@*
## @var{tol}: if the difference between two @var{x} values is no more than this scalar, merge them; 0 by default
##
## Outputs:
## De-duplicated and sorted @var{x}, @var{y}, @var{w}
## @end deftypefn
## @seealso{csaps, bin_values}

## Author: Nir Krakauer

function [x, y, w] = dedup(x, y, w=ones(size(x)), tol=0, nan_remove=true)

warning ("off", "Octave:broadcast", "local");

if isempty(w)
  w = ones(size(x));
endif

if isempty(tol)
  tol = 0;
endif

if nan_remove
  #remove any rows with missing entries
  notnans = !any (isnan ([x y w]) , 2);
  x = x(notnans);
  y = y(notnans, :);
  w = w(notnans);
endif

[x,i] = sort(x);
y = y(i, :);
w = w(i);

h = diff(x);

if any(h <= tol)
	hh = ones(size(x));
	hh(2:end) = cumsum(h > tol) + 1; #any elements tol or less apart are placed in the same equivalence class
 
	#replace original points with equivalence classes, using weighted averages
	wnew = accumarray(hh, w);
	x = accumarray(hh, x .* w) ./ wnew;
	y = accumdim(hh, y .* w, 1) ./ wnew;
	w = wnew;
endif

%!shared x, y, w
%! x = [1; 2; 2; 3; 4];
%! y = [0 0; 1 1; 2 1; 3 4; 5 NaN];
%! w = [1; 0.1; 1; 0.5; 1];
%!assert (nthargout(1:3, @dedup, x, y, ones(size(x))), nthargout(1:3, @dedup, x, y))
%! [x y w] = dedup(x, y, w);
%!assert (x, [1; 2; 3]);
%!assert (y, [0 0; 21/11 1; 3 4], 10*eps);
%!assert (w, [1; 1.1; 0.5]);
