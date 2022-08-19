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
## @deftypefn {Function File} {@var{C} =} erlangc (@var{A}, @var{m})
##
## @cindex Erlang-C formula
##
## Compute the steady-state probability of delay in the Erlang delay model.
##
## The Erlang-C formula @math{E_C(A, m)} gives the probability that an
## open queueing system with @math{m} identical servers, infinite
## wating space, arrival rate @math{\lambda}, individual service rate
## @math{\mu} and offered load @math{A = \lambda / \mu} has all the
## servers busy. This is the waiting probability in an
## @math{M/M/m/\infty} system with @math{m} servers and an infinite
## queue.
##
## @tex
## @math{E_C(A, m)} is defined as:
##
## $$
## E_C(A, m) = \displaystyle{ {A^m \over m!} {1 \over 1-\rho} \left( \sum_{k=0}^{m-1} {A^k \over k!} + {A^m \over m!} {1 \over 1 - \rho} \right) ^{-1}}
## $$
##
## where @math{\rho = A / m = \lambda / (m \mu)}.
## @end tex
##
## @strong{INPUTS}
##
## @table @code
##
## @item @var{A}
## Offered load. @math{A = \lambda / \mu} where
## @math{\lambda} is the mean arrival rate and @math{\mu} the mean
## service rate of each individual server (real, @math{0 < A < m}).
##
## @item @var{m}
## Number of identical servers (integer, @math{m @geq{} 1}).
## Default @math{m = 1}
##
## @end table
##
## @strong{OUTPUTS}
##
## @table @code
##
## @item @var{B}
## The value @math{E_C(A, m)}
##
## @end table
##
## @var{A} or @var{m} can be vectors, and in this case, the results will
## be vectors as well.
##
## @strong{REFERENCES}
##
## @itemize
## @item
## G. Zeng, @cite{Two common properties of the Erlang-B function, Erlang-C function, and Engset blocking function}, Mathematical and Computer Modelling, Volume 37, Issues 12-13, June 2003, Pages 1287-1296
## @end itemize
##
## @seealso{erlangb,engset,qsmmm}
##
## @end deftypefn

## Author: Moreno Marzolla <moreno.marzolla(at)unibo.it>
## Web: http://www.moreno.marzolla.name/
function C = erlangc(A, m)
  if ( nargin < 1 || nargin > 2 )
    print_usage();
  endif

  ( isnumeric(A) && all(A(:) > 0) ) || error("A must be positive");
   
  if ( nargin == 1 )
    m = 1;
  else
    ( isnumeric(m) && all( fix(m(:)) == m(:)) && all( m(:) > 0 ) ) || error("m must be a positive integer");
  endif
  
  [err A, m] = common_size(A, m);
  if ( err )
    error("parameters are not of common size");
  endif
  
  all( A(:) < m(:) ) || error("A must be < m");
   
  rho = A ./ m;
  B = erlangb(A, m);
  C = B ./ (1 - rho .* (1 - B));
endfunction

%!test
%! fail("erlangc('foo',1)", "positive");
%! fail("erlangc(1,'bar')", "positive");
