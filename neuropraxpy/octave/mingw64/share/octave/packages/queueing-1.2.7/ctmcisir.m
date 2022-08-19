## Copyright (C) 2018 Moreno Marzolla
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
## @deftypefn {Function File} {[@var{r} @var{s}] =} ctmcisir (@var{P})
##
## @cindex Markov chain, continuous time
## @cindex continuous time Markov chain
## @cindex CTMC
## @cindex irreducible Markov chain
##
## Check if @var{Q} is irreducible, and identify Strongly Connected
## Components (SCC) in the transition graph of the DTMC with infinitesimal
## generator matrix @var{Q}.
##
## @strong{INPUTS}
##
## @table @code
##
## @item @var{Q}(i,j)
## Infinitesimal generator matrix. @var{Q} is a @math{N \times N} square
## matrix where @code{@var{Q}(i,j)} is the transition rate from state
## @math{i} to state @math{j}, for @math{1 @leq{} i, j @leq{} N},
## @math{i \neq j}.
##
## @end table
##
## @strong{OUTPUTS}
##
## @table @code
##
## @item @var{r}
## 1 if @var{Q} is irreducible, 0 otherwise.
##
## @item @var{s}(i)
## strongly connected component (SCC) that state @math{i} belongs to.
## SCCs are numbered @math{1, 2, @dots{}}. If the graph is strongly
## connected, then there is a single SCC and the predicate @code{all(s == 1)}
## evaluates to true.
##
## @end table
##
## @end deftypefn

## Author: Moreno Marzolla <moreno.marzolla(at)unibo.it>
## Web: http://www.moreno.marzolla.name/

function [r s] = ctmcisir( Q )

  if ( nargin != 1 )
    print_usage();
  endif

  [N err] = ctmcchkQ(Q);

  ( N > 0 ) || ...
    error(err);

  s = scc(Q);
  r = (max(s) == 1);

endfunction
%!test
%! Q = [-.5 .5 0; 1 0 0];
%! fail( "ctmcisir(Q)" );

%!test
%! Q = [-1 1 0; .5 -.5 0; 0 0 0];
%! [r s] = ctmcisir(Q);
%! assert( r == 0 );
%! assert( max(s), 2 );
%! assert( min(s), 1 );

%!test
%! Q = [-.5 .5 0; .2 -.7 .5; .2 0 -.2];
%! [r s] = ctmcisir(Q);
%! assert( r == 1 );
%! assert( max(s), 1 );
%! assert( min(s), 1 );
