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
## @deftypefn {Function File} {@var{n} =} numel (@var{q})
## @deftypefnx {Function File} {@var{n} =} numel (@var{q}, @var{idx1}, @var{idx2}, @dots{})
## For internal use only, use @code{prod(size(q))} or @code{numel (q.w)} instead.
## For technical reasons, this method must return the number of elements which are
## returned from cs-list indexing, no matter whether it is called with one or more
## arguments.
## @end deftypefn

## Author: Lukas Reichlin <lukas.reichlin@gmail.com>
## Created: February 2015
## Version: 0.1

function ret = numel (q, varargin)

  ret = builtin ("numel", q, varargin{:});

endfunction


%!test
%! assert (numel (quaternion (eye (3))), 1);
