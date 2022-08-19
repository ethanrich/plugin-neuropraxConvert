## Copyright (C) 2007 Muthiah Annamalai <muthiah.annamalai@uta.edu>
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
## @deftypefn {Function File} {@var{x} =} reduce (@var{function}, @var{sequence},@var{initializer})
## @deftypefnx {Function File} {@var{x} =} reduce (@var{function}, @var{sequence})
## Implements the 'reduce' operator like in Lisp, or Python.
## Apply function of two arguments cumulatively to the items of sequence, 
## from left to right, so as to reduce the sequence to a single value. For example,
## reduce(@@(x,y)(x+y), [1, 2, 3, 4, 5]) calculates ((((1+2)+3)+4)+5).
## The left argument, x, is the accumulated value and the right argument, y, is the 
## update value from the sequence. If the optional initializer is present, it is 
## placed before the items of the sequence in the calculation, and serves as
## a default when the sequence is empty. If initializer is not given and sequence
## contains only one item, the first item is returned.
##
## @example
##  reduce(@@plus,[1:10])
##  @result{} 55
##      reduce(@@(x,y)(x*y),[1:7]) 
##  @result{} 5040  (actually, 7!)
## @end example
##
## @end deftypefn

## Parts of documentation copied from the "Python Library Reference, v2.5"

function rv = reduce (func, lst, init)
  if (nargin < 2 || nargin > 3)
    print_usage ();
  elseif (! isa (func, "function_handle"))
    error ("reduce: FUNCTION must be a function handle");
  elseif (nargin < 3 && isempty (lst))
    error ("reduce: LST must not be empty when INIT is undefined");
  endif

  start = 1;
  if (nargin == 2)
    init = lst(1);
    start = 2;
  endif

  rv = init;
  for i = start:numel(lst)
    rv = func (rv, lst(i));
  endfor

endfunction

%!assert(reduce(@(x,y)(x+y),[],-1),-1)
%!assert(reduce(@(x,y)(x+y),[+1],-1),0)
%!assert(reduce(@(x,y)(x+y),[-10:-1]),-55)
%!assert(reduce(@(x,y)(x+y),[-10:-1],+55),0)
%!assert(reduce(@(x,y)(y*x),[1:4],5),120)
