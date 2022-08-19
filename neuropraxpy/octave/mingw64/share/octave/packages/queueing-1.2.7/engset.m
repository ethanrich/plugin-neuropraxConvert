## Copyright (C) 2014, 2019 Moreno Marzolla
##
## This file is part of the queueing toolbox.
##
## The queueing toolbox is free software: you can redistribute it and/or
## modify it under the terms of the GNU General Public License as
## published by the Free Software Foundation, either version 3 of the
## License, or (at your option) any later version.
##
## The queueing toolbox is distributed in the hope that it will be
## useful, but WITHOUT ANY WARRANTY; without even the implied warranty
## of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
## General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with the queueing toolbox. If not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
##
## @deftypefn {Function File} {@var{B} =} engset (@var{A}, @var{m}, @var{n})
##
## @cindex Engset loss formula
##
## Evaluate the Engset loss formula.
##
## The Engset formula computes the blocking probability
## @math{P_b(A,m,n)} for a system with a finite population of @math{n}
## users, @math{m} identical servers, no queue, individual service
## rate @math{\mu}, individual arrival rate @math{\lambda} (i.e., the
## time until a user tries to request service is exponentially
## distributed with mean @math{1/\lambda}), and offered load
## @math{A=\lambda/\mu}.
## 
## @tex
## @math{P_b(A, m, n)} is defined for @math{n > m} as:
##
## $$
## P_b(A, m, n) = {{\displaystyle{A^m {n \choose m}}} \over {\displaystyle{\sum_{k=0}^m A^k {n \choose k}}}}
## $$
##
## and is 0 if @math{n @leq{} m}.
## @end tex
##
## @strong{INPUTS}
##
## @table @code
##
## @item @var{A}
## Offered load, defined as @math{A = \lambda / \mu} where
## @math{\lambda} is the mean arrival rate and @math{\mu} the mean
## service rate of each individual server (real, @math{A > 0}).
##
## @item @var{m}
## Number of identical servers (integer, @math{m @geq{} 1}). Default @math{m = 1}
##
## @item @var{n}
## Number of requests (integer, @math{n @geq{} 1}). Default @math{n = 1}
##
## @end table
##
## @strong{OUTPUTS}
##
## @table @code
##
## @item @var{B}
## The value @math{P_b(A, m, n)}
##
## @end table
##
## @var{A}, @var{m} or @math{n} can be vectors, and in this case, the
## results will be vectors as well.
##
## @strong{REFERENCES}
##
## @itemize
## @item
## G. Zeng, @cite{Two common properties of the Erlang-B function, Erlang-C function, and Engset blocking function}, Mathematical and Computer Modelling, Volume 37, Issues 12-13, June 2003, Pages 1287-1296
## @end itemize
##
## @seealso{erlangb, erlangc}
##
## @end deftypefn

## Author: Moreno Marzolla <moreno.marzolla(at)unibo.it>
## Web: http://www.moreno.marzolla.name/
function P = engset(A, m, n)
  if ( nargin < 1 || nargin > 3 )
    print_usage();
  endif

  ( isnumeric(A) && all( A(:) > 0 ) ) || error("A must be positive");
  
  if ( nargin < 2 )
    m = 1;
  else
    ( isnumeric(m) && all( fix(m(:)) == m(:)) && all( m(:) > 0 ) ) || error("m must be a positive integer");
  endif

  if ( nargin < 3 )
    n = 1;
  else
    ( isnumeric(n) && all( fix(n(:)) == n(:)) && all( n(:) > 0 ) ) || error("n must be a positive integer");
  endif
  
  [err A m n] = common_size(A, m, n);
  if ( err )
    error("parameters are not of common size");
  endif

  P = arrayfun( @__engset_compute, A, m, n);
endfunction

## Compute P_b(A,m,n) recursively
function P = __engset_compute(A, m, n)
  if ( m >= n )
    P = 0.0;
  else
    P = 1.0;
    for i = 1:m
      P=(A*(n-i)*P)/(i+A*(n-i)*P);
    endfor
  endif
endfunction

%!test
%! fail("erlangb(1, -1)", "positive");
%! fail("erlangb(-1, 1)", "positive");
%! fail("erlangb(1, 0)", "positive");
%! fail("erlangb(0, 1)", "positive");
%! fail("erlangb('foo',1)", "positive");
%! fail("erlangb(1,'bar')", "positive");
%! fail("erlangb([1 1],[1 1 1])","common size");

