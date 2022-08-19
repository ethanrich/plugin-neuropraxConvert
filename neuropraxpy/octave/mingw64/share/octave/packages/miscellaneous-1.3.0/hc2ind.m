## Copyright (C) 2017 - Juan Pablo Carbajal
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
## @deffn {@var{k}} = hc2ind (@var{Z})
## @deffnx {@var{k}} = hc2ind (@var{X},@var{Y})
## Converts Hilbert curve to linear matrix indices.
## 
## @example
## [x,y] = hilbert_curve (2);
## hc2ind (x, y);
## ans =
##   1
##   2
##   4
##   3
## @end example
## 
## @end deffn

function [k,I,J] = hc2ind (x, y)

  # convert the coords to subindexes
  # blocks in row-major order (with u-d flips)
  I = y + 1;
  J = x + 1;

  # convert the subs to indices
  sz = sqrt (length (x)) * [1 1];
  k  = sub2ind (sz, I, J);

endfunction

%!demo
%! M      = idxmatrix (4)
%! [x, y] = hilbert_curve (4);
%! ind    = hc2ind (x, y);
%! M(ind)
