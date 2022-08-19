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
## @defun {@var{m} =} idxmatrix (@var{sz})
## Create matrix of subindexes
##
## Create a matrix with each element correspoding
## to its subindex in the matrix, i.e.
##
## @example
##     @var{m}(i,j,k) = i * 100 + j * 10 + k = ijk
## @end example
##
## The input @var{sz} defines the size of the matrix.
##
## Example:
##
## @example
##
## M = idxmatrix ([2 3 2])
## ans(:,:,1) =
##
##   111   121   131
##   211   221   231
##
##ans(:,:,2) =
##
##   112   122   132
##   212   222   232
## @end example
##
## @seealso{sub2ind}
## @end defun

function M = idxmatrix (sz)

  # Check input
  if (isscalar (sz))

    if (sz == 0)
      M = [];
      return;
    else
      sz = [sz sz];
    endif

  endif

  if (any(sz < 0) || isempty (sz))
    error ('Octave:invalid-input-arg', ...
           'Size should contain non-negative integers');
  endif
  ######

  M = 0;
  n = length (sz);
  for i = (n-1):-1:0;
     M = ( M + 10^i * (1:sz(n-i)) )(:);
  endfor
  M = reshape (M, sz);

endfunction

%!error (idxmatrix ([]))
%!assert (idxmatrix (0), [])
%!assert (idxmatrix (2), idxmatrix ([2 2]))
