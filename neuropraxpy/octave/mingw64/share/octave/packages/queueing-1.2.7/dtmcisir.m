## Copyright (C) 2012, 2016, 2018 Moreno Marzolla
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
## @deftypefn {Function File} {[@var{r} @var{s}] =} dtmcisir (@var{P})
##
## @cindex Markov chain, discrete time
## @cindex discrete time Markov chain
## @cindex DTMC
## @cindex irreducible Markov chain
##
## Check if @var{P} is irreducible, and identify Strongly Connected
## Components (SCC) in the transition graph of the DTMC with transition
## matrix @var{P}.
##
## @strong{INPUTS}
##
## @table @code
##
## @item @var{P}(i,j)
## transition probability from state @math{i} to state @math{j}.
## @var{P} must be an @math{N \times N} stochastic matrix.
##
## @end table
##
## @strong{OUTPUTS}
##
## @table @code
##
## @item @var{r}
## 1 if @var{P} is irreducible, 0 otherwise (scalar)
##
## @item @var{s}(i)
## strongly connected component (SCC) that state @math{i} belongs to
## (vector of length @math{N}). SCCs are numbered @math{1, 2, @dots{}}.
## The number of SCCs is @code{max(s)}. If the graph is
## strongly connected, then there is a single SCC and the predicate
## @code{all(s == 1)} evaluates to true
##
## @end table
##
## @end deftypefn

## Author: Moreno Marzolla <moreno.marzolla(at)unibo.it>
## Web: http://www.moreno.marzolla.name/

function [r s] = dtmcisir( P )

  if ( nargin != 1 )
    print_usage();
  endif

  [N err] = dtmcchkP(P);
  if ( N == 0 ) 
    error(err);
  endif
  s = scc(P);
  r = (max(s) == 1);

endfunction
%!test
%! P = [0 .5 0; 0 0 0];
%! fail( "dtmcisir(P)" );

%!test
%! P = [0 1 0; 0 .5 .5; 0 1 0];
%! [r s] = dtmcisir(P);
%! assert( r == 0 );
%! assert( max(s), 2 );
%! assert( min(s), 1 );

%!test
%! P = [.5 .5 0; .2 .3 .5; 0 .2 .8];
%! [r s] = dtmcisir(P);
%! assert( r == 1 );
%! assert( max(s), 1 );
%! assert( min(s), 1 );
