## Copyright (C) 2008, 2009, 2010, 2011, 2012, 2016, 2018 Moreno Marzolla
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
## @deftypefn {Function File} {@var{H} =} qncmnpop (@var{N})
##
## @cindex population mix
## @cindex closed network, multiple classes
##
## Given a network with @math{C} customer classes, this function
## computes the number of @math{k}-mixes @code{@var{H}(r,k)} that can
## be constructed by the multiclass MVA algorithm by allocating
## @math{k} customers to the first @math{r} classes.
## @xref{doc-qncmpopmix} for the definition of @math{k}-mix.
##
## @strong{INPUTS}
##
## @table @code
##
## @item @var{N}(c)
## number of class-@math{c} requests in the system. The total number
## of requests in the network is @code{sum(@var{N})}.
## 
## @end table
##
## @strong{OUTPUTS}
##
## @table @code
##
## @item @var{H}(r,k)
## is the number of @math{k} mixes that can be constructed allocating
## @math{k} customers to the first @math{r} classes.
##
## @end table
##
## @strong{REFERENCES}
##
## @itemize
## @item Zahorjan, J. and Wong, E. @cite{The solution of separable queueing
## network models using mean value analysis}. SIGMETRICS
## Perform. Eval. Rev. 10, 3 (Sep. 1981), 80-85. DOI
## @uref{http://doi.acm.org/10.1145/1010629.805477, 10.1145/1010629.805477}
## @end itemize
##
## @seealso{qncmmva,qncmpopmix}
##
## @end deftypefn

## Author: Moreno Marzolla <moreno.marzolla(at)unibo.it>
## Web: http://www.moreno.marzolla.name/

function H = qncmnpop( N )
  (isvector(N) && all( N > 0 ) ) || ...
      error( "N must be a vector of strictly positive integers" );
  N = N(:)'; # make N a row vector
  Ns = sum(N);
  R = length(N);
  
  ## In the implementation below we initialize the variable
  ## @code{TOTAL_POP} variable to 0 instead of @code{@var{N}(1)} as in
  ## the paper. Moreover, we increment @code{TOTAL_POP}
  ## @code{@var{N}(r)} at each iteration, instead of
  ## @code{@var{N}(r-1)} as in the paper.
  
  total_pop = N(1);
  H = zeros(R, Ns+1);
  H(1,1:N(1)+1) = 1;
  for r=2:R
    total_pop += N(r);
    for n=0:total_pop
      range = max(0,n-N(r)) : n;
      H(r,n+1) = sum( H(r-1, range+1 ) );
    endfor
  endfor
endfunction
%!test
%! H = qncmnpop( [1 2 2] );
%! assert( H, [1 1 0 0 0 0; 1 2 2 1 0 0; 1 3 5 5 3 1] );
