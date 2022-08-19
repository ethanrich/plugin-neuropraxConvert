## Copyright (C) 2010-2015   Lukas F. Reichlin
##
## This program is free software: you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation, either version 3 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program.  If not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## End indexing for quaternions.
## Used by Octave for "q(1:end)".

## Author: Lukas Reichlin <lukas.reichlin@gmail.com>
## Created: December 2013
## Version: 0.1

function ret = end (q, k, n)

  ## error: end: no method for class double
  ## octave 3.6.4 raises an error for the following 4 variants:
  ## ret = end (q.w, k, n);
  ## ret = feval ("end", q.w, k, n);
  ## ret = feval (@end, q.w, k, n);
  ## ret = builtin ("end", q.w, k, n);
  
  if (n == 1)               # q(idx), note that ndims (q.w) >= 2
    ret = numel (q.w);
  else                      # q(idx1, idx2), q(idx1, idx2, idx3), ...
    ret = size (q.w, k);
  endif

endfunction


%!test
%! w = eye (3);
%! q = quaternion (w);
%! assert (q(end).w, w(end));
%! assert (q(end,1).w, w(end,1));
%! assert (q(1,end).w, w(1,end));
