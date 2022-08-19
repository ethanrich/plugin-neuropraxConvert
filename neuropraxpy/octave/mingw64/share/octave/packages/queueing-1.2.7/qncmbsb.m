## Copyright (C) 2012, 2016, 2020 Moreno Marzolla
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
## @deftypefn {Function File} {[@var{Xl}, @var{Xu}, @var{Rl}, @var{Ru}] =} qncmbsb (@var{N}, @var{D})
## @deftypefnx {Function File} {[@var{Xl}, @var{Xu}, @var{Rl}, @var{Ru}] =} qncmbsb (@var{N}, @var{S}, @var{V})
##
## @cindex bounds, balanced system
## @cindex balanced system bounds
## @cindex multiclass network, closed
## @cindex closed multiclass network
##
## Compute Balanced System Bounds for closed, multiclass networks
## with @math{K} service centers and @math{C} customer classes.
## Only single-server nodes are supported.
##
## @strong{INPUTS}
##
## @table @code
##
## @item @var{N}(c)
## number of class @math{c} requests in the system (vector of length
## @math{C}).
##
## @item @var{D}(c, k)
## class @math{c} service demand  at center @math{k} (@math{C \times K}
## matrix, @code{@var{D}(c,k) @geq{} 0}).
##
## @item @var{S}(c, k)
## mean service time of class @math{c}
## requests at center @math{k} (@math{C \times K} matrix, @code{@var{S}(c,k) @geq{} 0}).
##
## @item @var{V}(c,k)
## average number of visits of class @math{c}
## requests to center @math{k} (@math{C \times K} matrix, @code{@var{V}(c,k) @geq{} 0}). 
##
## @end table
##
## @strong{OUTPUTS}
##
## @table @code
##
## @item @var{Xl}(c)
## @itemx @var{Xu}(c)
## Lower and upper class @math{c} throughput bounds (vector of length @math{C}).
##
## @item @var{Rl}(c)
## @itemx @var{Ru}(c)
## Lower and upper class @math{c} response time bounds (vector of length @math{C}).
##
## @end table
##
## @seealso{qncsbsb}
##
## @end deftypefn

## Author: Moreno Marzolla <moreno.marzolla(at)unibo.it>
## Web: http://www.moreno.marzolla.name/

function [Xl Xu Rl Ru] = qncmbsb( varargin )

  if ( nargin<2 || nargin>5 )
    print_usage();
  endif

  [err N S V m Z] = qncmchkparam( varargin{:} );
  isempty(err) || error(err);

  all(m<=1) || ...
      error("Multiple-server nodes are not supported");

  all(Z == 0 ) || ...
      error("This function only supports Z=0");

  if ( sum(N) == 0 ) # handle trivial case of empty network
    Xl = Xu = Rl = Ru = zeros(size(S));
  else
    D = S .* V;
    K = columns(S);
    
    ## Equations from T. Kerola, The Composite Bound Method (CBM) for
    ## Computing Throughput Bounds in Multiple Class Environments},
    ## Technical Report CSD-TR-475, Department of Computer Sciences,
    ## Purdue University, mar 13 1984 (Revisted aug 27, 1984), available
    ## at http://docs.lib.purdue.edu/cstech/395/

    Dc = sum(D,2)';
    D_max = max(D,[],2)';
    D_min = min(D,[],2)';
    Xl = N ./ (Dc .+ (sum(N)-1) .* D_max);
    Xu = min( 1./D_max, N ./ ((K+sum(N)-1) .* D_min));
    Rl = N ./ Xu;
    Ru = N ./ Xl;
  endif
endfunction

%!test
%! fail("qncmbsb([],[])", "nonempty");
%! fail("qncmbsb([1 0], [1 2 3])", "2 rows");
%! fail("qncmbsb([1 0], [1 2 3; 4 5 -1])", "nonnegative");
%! fail("qncmbsb([1 2], [1 2 3; 4 5 6], [1 2 3])", "2 x 3");
%! fail("qncmbsb([1 2], [1 2 3; 4 5 6], [1 2 3; 4 5 -1])", "nonnegative");
%! fail("qncmbsb([1 2], [1 2 3; 1 2 3], [1 2 3; 1 2 3], [1 1])", "3 elements");
%! fail("qncmbsb([1 2], [1 2 3; 1 2 3], [1 2 3; 1 2 3], [1 1 2])", "not supported");
%! fail("qncmbsb([1 2], [1 2 3; 1 2 3], [1 2 3; 1 2 3], [1 1 -1],[1 2 3])", "2 elements");
%! fail("qncmbsb([1 2], [1 2 3; 1 2 3], [1 2 3; 1 2 3], [1 1 -1],[1 -2])", "nonnegative");
%! fail("qncmbsb([1 2], [1 2 3; 1 2 3], [1 2 3; 1 2 3], [1 1 -1],[1 0])", "only supports");

%!test
%! [Xl Xu Rl Ru] = qncmbsb([0 0], [1 2 3; 1 2 3]);
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
%!   [a b c d] = qncmbsb(N,S);
%!   Xl(n,:) = a; Xu(n,:) = b; Rl(n,:) = c; Ru(n,:) = d;
%!   [U R Q X] = qncmmva(N,S,ones(size(S)));
%!   Xmva(n,:) = X(:,1)'; Rmva(n,:) = sum(R,2)';
%! endfor
%! subplot(2,2,1);
%! plot(1:NN,Xl(:,1), 1:NN,Xu(:,1), 1:NN,Xmva(:,1),";MVA;", "linewidth", 2);
%! ylim([0, 0.2]);
%! title("Class 1 throughput"); legend("boxoff");
%! subplot(2,2,2);
%! plot(1:NN,Xl(:,2), 1:NN,Xu(:,2), 1:NN,Xmva(:,2),";MVA;", "linewidth", 2);
%! ylim([0, 0.2]);
%! title("Class 2 throughput"); legend("boxoff");
%! subplot(2,2,3);
%! plot(1:NN,Rl(:,1), 1:NN,Ru(:,1), 1:NN,Rmva(:,1),";MVA;", "linewidth", 2);
%! ylim([0, 700]);
%! title("Class 1 response time"); legend("location", "northwest"); legend("boxoff");
%! subplot(2,2,4);
%! plot(1:NN,Rl(:,2), 1:NN,Ru(:,2), 1:NN,Rmva(:,2),";MVA;", "linewidth", 2);
%! ylim([0, 700]);
%! title("Class 2 response time"); legend("location", "northwest"); legend("boxoff");
