## Copyright (C) 2012, 2016, 2018, 2020 Moreno Marzolla
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
## @deftypefn {Function File} {[@var{Xl}, @var{Xu}, @var{Rl}, @var{Ru}] =} qncmaba (@var{N}, @var{D})
## @deftypefnx {Function File} {[@var{Xl}, @var{Xu}, @var{Rl}, @var{Ru}] =} qncmaba (@var{N}, @var{S}, @var{V})
## @deftypefnx {Function File} {[@var{Xl}, @var{Xu}, @var{Rl}, @var{Ru}] =} qncmaba (@var{N}, @var{S}, @var{V}, @var{m})
## @deftypefnx {Function File} {[@var{Xl}, @var{Xu}, @var{Rl}, @var{Ru}] =} qncmaba (@var{N}, @var{S}, @var{V}, @var{m}, @var{Z})
##
## @cindex bounds, asymptotic
## @cindex asymptotic bounds
## @cindex closed network
## @cindex multiclass network, closed
## @cindex closed multiclass network
##
## Compute Asymptotic Bounds for closed, multiclass networks
## with @math{K} service centers and @math{C} customer classes.
## Single-server and infinite-server nodes are supported.
## Multiple-server nodes and general load-dependent servers are not
## supported.
##
## @strong{INPUTS}
##
## @table @code
##
## @item @var{N}(c)
## number of class @math{c} requests in the system
## (vector of length @math{C}, @code{@var{N}(c) @geq{} 0}).
##
## @item @var{D}(c, k)
## class @math{c} service demand
## at center @math{k} (@math{C \times K} matrix, @code{@var{D}(c,k) @geq{} 0}).
##
## @item @var{S}(c, k)
## mean service time of class @math{c}
## requests at center @math{k} (@math{C \times K} matrix, @code{@var{S}(c,k) @geq{} 0}).
##
## @item @var{V}(c,k)
## average number of visits of class @math{c}
## requests to center @math{k} (@math{C \times K} matrix, @code{@var{V}(c,k) @geq{} 0}).
##
## @item @var{m}(k)
## number of servers at center @math{k}
## (if @var{m} is a scalar, all centers have that number of servers). If
## @code{@var{m}(k) < 1}, center @math{k} is a delay center (IS);
## if @code{@var{m}(k) = 1}, center @math{k} is a M/M/1-FCFS server.
## This function does not support multiple-server nodes. Default
## is 1.
##
## @item @var{Z}(c)
## class @math{c} external delay
## (vector of length @math{C}, @code{@var{Z}(c) @geq{} 0}). Default is 0.
##
## @end table
##
## @strong{OUTPUTS}
##
## @table @code
##
## @item @var{Xl}(c)
## @itemx @var{Xu}(c)
## Lower and upper bounds for class @math{c} throughput.
##
## @item @var{Rl}(c)
## @itemx @var{Ru}(c)
## Lower and upper bounds for class @math{c} response time.
##
## @end table
##
## @strong{REFERENCES}
##
## @itemize
## @item
## Edward D. Lazowska, John Zahorjan, G.  Scott Graham, and Kenneth
## C. Sevcik, @cite{Quantitative System Performance: Computer System
## Analysis Using Queueing Network Models}, Prentice Hall,
## 1984. @url{http://www.cs.washington.edu/homes/lazowska/qsp/}. In
## particular, see section 5.2 ("Asymptotic Bounds").
## @end itemize
##
## @seealso{qncsaba}
##
## @end deftypefn

## Author: Moreno Marzolla <moreno.marzolla(at)unibo.it>
## Web: http://www.moreno.marzolla.name/

function [Xl Xu Rl Ru] = qncmaba( varargin )

  if ( nargin<2 || nargin>5 )
    print_usage();
  endif

  [err N S V m Z] = qncmchkparam( varargin{:} );
  isempty(err) || error(err);

  all(m<=1) || ...
      error("Multiple-server nodes are not supported");

  if ( sum(N) == 0 ) # handle trivial case of empty network
    Xl = Xu = Rl = Ru = zeros(size(S));
  else
    D = S .* V;
    
    Dc_single = sum(D(:,(m==1)),2)'; # class c demand on single-server nodes
    Dc_delay = sum(D(:,(m<1)),2)'; # class c demand on delay centers
    Dc = sum(D,2)'; # class c total demand
    Dcmax = max(D,[],2)'; # maximum class c demand at any server
    Xl = N ./ ( dot(N,Dc_single) .+ Dc_delay .+ Z);
    Xu = min( 1./Dcmax, N ./ (Dc .+ Z) );
    Rl = N ./ Xu .- Z;
    Ru = N ./ Xl .- Z;
  endif
endfunction

%!test
%! fail("qncmaba([],[])", "nonempty");
%! fail("qncmaba([1 0], [1 2 3])", "2 rows");
%! fail("qncmaba([1 0], [1 2 3; 4 5 -1])", "nonnegative");
%! fail("qncmaba([1 2], [1 2 3; 4 5 6], [1 2 3])", "2 x 3");
%! fail("qncmaba([1 2], [1 2 3; 4 5 6], [1 2 3; 4 5 -1])", "nonnegative");
%! fail("qncmaba([1 2], [1 2 3; 1 2 3], [1 2 3; 1 2 3], [1 1])", "3 elements");
%! fail("qncmaba([1 2], [1 2 3; 1 2 3], [1 2 3; 1 2 3], [1 1 2])", "not supported");
%! fail("qncmaba([1 2], [1 2 3; 1 2 3], [1 2 3; 1 2 3], [1 1 -1],[1 2 3])", "2 elements");
%! fail("qncmaba([1 2], [1 2 3; 1 2 3], [1 2 3; 1 2 3], [1 1 -1],[1 -2])", "nonnegative");

%!test
%! [Xl Xu Rl Ru] = qncmaba([0 0], [1 2 3; 1 2 3]);
%! assert( all(Xl(:) == 0) );
%! assert( all(Xu(:) == 0) );
%! assert( all(Rl(:) == 0) );
%! assert( all(Ru(:) == 0) );

%!demo
%! S = [10 7 5 4; ...
%!      5  2 4 6];
%! NN=20;
%! Xl = Xu = Rl = Ru = Xmva = Rmva = zeros(NN,2);
%! for n=1:NN
%!   N=[n,10];
%!   [a b c d] = qncmaba(N,S);
%!   Xl(n,:) = a; Xu(n,:) = b; Rl(n,:) = c; Ru(n,:) = d;
%!   [U R Q X] = qncmmva(N,S,ones(size(S)));
%!   Xmva(n,:) = X(:,1)'; Rmva(n,:) = sum(R,2)';
%! endfor
%! subplot(2,2,1);
%! plot(1:NN,Xl(:,1), 1:NN,Xu(:,1), 1:NN,Xmva(:,1), ";MVA;", "linewidth", 2);
%! ylim([0, 0.2]);
%! title("Class 1 throughput"); legend("boxoff");
%! subplot(2,2,2);
%! plot(1:NN,Xl(:,2), 1:NN,Xu(:,2), 1:NN,Xmva(:,2), ";MVA;", "linewidth", 2);
%! ylim([0, 0.2]);
%! title("Class 2 throughput"); legend("boxoff");
%! subplot(2,2,3);
%! plot(1:NN,Rl(:,1), 1:NN,Ru(:,1), 1:NN,Rmva(:,1), ";MVA;", "linewidth", 2);
%! ylim([0, 700]);
%! title("Class 1 response time"); legend("location", "northwest"); legend("boxoff");
%! subplot(2,2,4);
%! plot(1:NN,Rl(:,2), 1:NN,Ru(:,2), 1:NN,Rmva(:,2), ";MVA;", "linewidth", 2);
%! ylim([0, 700]);
%! title("Class 2 response time"); legend("location", "northwest"); legend("boxoff");



