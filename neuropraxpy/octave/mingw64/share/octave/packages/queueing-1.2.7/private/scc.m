## Copyright (C) 2018, 2020 Moreno Marzolla
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
## @deftypefn {Function File} {@var{s} =} scc (@var{G})
##
## Compute the Strongly Connected Components (SCC) of a graph with
## adjacency matrix @var{G}. Any positive value in @var{G} denotes
## an edge; zero or negative values denote the absence of an edge.
##
## @end deftypefn
function s = scc( G )

  ## It might be possible to use a different algorithm for SCC (e.g.,
  ## http://pmtksupport.googlecode.com/svn/trunk/gaimc1.0-graphAlgo/scomponents.m

  assert(issquare(G));
  N = rows(G);
  GF = (G>0);
  GB = (G'>0);
  s = zeros(N,1);
  c=1;
  for n=1:N
    if (s(n) == 0)
      fw = __dfs(GF,n);
      bw = __dfs(GB,n);
      r = (fw & bw);
      s(r) = c++;
    endif
  endfor
endfunction

## This is essentially the same code from qncmvisits.m
function v = __dfs(G, s)
  assert( issquare(G) );
  N = rows(G);
  v = stack = zeros(1,N); ## v(i) == 1 iff node i has been visited
  q = 1; # first empty slot in queue
  stack(q++) = s; v(s) = 1;
  while( q>1 )
    n = stack(--q);
    ## explore neighbors of n: all f in G(n,:) such that v(f) == 0
    
    ## The following instruction is equivalent to:
    ##    for f=find(G(n,:))
    ##      if ( v(f) == 0 )
    for f = find ( G(n,:) & (v==0) )
      stack(q++) = f;
      v(f) = 1;
    endfor
  endwhile
endfunction
