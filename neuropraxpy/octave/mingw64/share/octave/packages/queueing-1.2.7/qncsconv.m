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
## @deftypefn {Function File} {[@var{U}, @var{R}, @var{Q}, @var{X}, @var{G}] =} qncsconv (@var{N}, @var{S}, @var{V})
## @deftypefnx {Function File} {[@var{U}, @var{R}, @var{Q}, @var{X}, @var{G}] =} qncsconv (@var{N}, @var{S}, @var{V}, @var{m})
##
## @cindex closed network, single class
## @cindex normalization constant
## @cindex convolution algorithm
##
## Analyze product-form, single class closed networks with @math{K} service centers using the convolution algorithm.
##
## Load-independent service centers, multiple servers (@math{M/M/m}
## queues) and IS nodes are supported. For general load-dependent
## service centers, use @code{qncsconvld} instead.
##
## @strong{INPUTS}
##
## @table @code
##
## @item @var{N}
## Number of requests in the system (@code{@var{N}>0}).
##
## @item @var{S}(k)
## average service time on center @math{k} (@code{@var{S}(k) @geq{} 0}).
##
## @item @var{V}(k)
## visit count of service center @math{k} (@code{@var{V}(k) @geq{} 0}).
##
## @item @var{m}(k)
## number of servers at center @math{k}. If @code{@var{m}(k) < 1},
## center @math{k} is a delay center (IS); if @code{@var{m}(k) @geq{}
## 1}, center @math{k} it is a regular @math{M/M/m} queueing center
## with @code{@var{m}(k)} identical servers. Default is
## @code{@var{m}(k) = 1} for all @math{k}.
##
## @end table
##
## @strong{OUTPUT}
##
## @table @code
##
## @item @var{U}(k)
## center @math{k} utilization.
## For IS nodes, @code{@var{U}(k)} is the @emph{traffic intensity}
## @code{@var{X}(k) * @var{S}(k)}.
##
## @item @var{R}(k)
## average response time of center @math{k}.
##
## @item @var{Q}(k)
## average number of customers at center @math{k}.
##
## @item @var{X}(k)
## throughput of center @math{k}.
##
## @item @var{G}(n)
## Vector of normalization constants. @code{@var{G}(n+1)} contains the value of
## the normalization constant with @math{n} requests
## @math{G(n)}, @math{n=0, @dots{}, N}.
##
## @end table
##
## @strong{NOTE}
##
## For a network with @math{K} service centers and @math{N} requests,
## this implementation of the convolution algorithm has time and space
## complexity @math{O(NK)}.
##
## @strong{REFERENCES}
##
## @itemize
## @item
## Jeffrey P. Buzen, @cite{Computational Algorithms for Closed Queueing
## Networks with Exponential Servers}, Communications of the ACM, volume
## 16, number 9, September 1973,
## pp. 527--531. @uref{http://doi.acm.org/10.1145/362342.362345, 10.1145/362342.362345}
## @end itemize
##
## This implementation is based on G. Bolch, S. Greiner, H. de Meer and
## K. Trivedi, @cite{Queueing Networks and Markov Chains: Modeling and
## Performance Evaluation with Computer Science Applications}, Wiley,
## 1998, pp. 313--317.
##
## @seealso{qncsconvld}
##
## @end deftypefn

## Author: Moreno Marzolla <moreno.marzolla(at)unibo.it>
## Web: http://www.moreno.marzolla.name/

function [U R Q X G] = qncsconv( varargin )

  if ( nargin < 3 || nargin > 4 )
    print_usage();
  endif

  ## To be compliant with the reference, we use K to denote the
  ## population size
  [err K S V m] = qncschkparam( varargin{:} );
  isempty(err) || error(err);

  N = length(S); # Number of service centers

  ## This implementation is based on G. Bolch, S. Greiner, H. de Meer
  ## and K. Trivedi, Queueing Networks and Markov Chains: Modeling and
  ## Performance Evaluation with Computer Science Applications, Wiley,
  ## 1998, pp. 313--317.

  ## First, we remember the indexes of IS nodes
  i_delay = find(m<1);

  m( i_delay ) = K; # IS nodes are handled as if they were M/M/K nodes with number of servers equal to the population size K, such that queueing never occurs.

  ## Initialization
  G_n = G_nm1 = zeros(1,K+1); 
  F_n = zeros(N,K+1); F_n(:,1) = 1;
  k=1:K; G_n(1) = 1; G_n(k+1) = F_n(1,k+1) = F(1,k,V,S,m); 
  ## Main convolution loop
  for n=2:N
    G_nm1 = G_n;
    k=1:K; F_n(n,1+k) = F(n,k,V,S,m);
    # G_n(1) = 1;
    G_n = conv( F_n(n,:), G_nm1(:) )(1:K+1);
  endfor
  ## Done computation of G(n,k).
  G = G_n(:)'; # ensure G is a row vector
  ## Computes performance measures

  X = V*G(K)/G(K+1);
  U = X .* S ./ m;
  ## Adjust utilization of delay centers
  U(i_delay) = X(i_delay) .* S(i_delay);
  Q = zeros(1,N);
  i_multi = find(m>1);
  for i=i_multi
    G_N_i = zeros(1,K+1);
    G_N_i(1) = 1;
    for k=1:K
      j=1:k;
      G_N_i(k+1) = G(k+1)-dot( F_n(i,j+1), G_N_i(k-j+1) );
    endfor
    k=0:K;
    p_i(k+1) = F_n(i,k+1)./G(K+1).*G_N_i(K-k+1);
    Q(i) = dot( k, p_i( k+1 ) );
  endfor
  i_single = find(m==1);
  for i=i_single
    k=1:K;
    Q(i) = sum( ( V(i)*S(i) ) .^ k .* G(K+1-k)/G(K+1) );
  endfor
  R = Q ./ X;
endfunction

%!test
%! # Example 8.1 p. 318 Bolch et al.
%! K=3;
%! S = [ 1/0.8 1/0.6 1/0.4 ];
%! m = [2 3 1];
%! V = [ 1 .667 .2 ];
%! [U R Q X G] = qncsconv( K, S, V, m );
%! assert( G, [1 2.861 4.218 4.465], 5e-3 );
%! assert( X, [0.945 0.630 0.189], 1e-3 );
%! assert( U, [0.590 0.350 0.473], 1e-3 );
%! assert( Q, [1.290 1.050 0.660], 1e-3 );
%! assert( R, [1.366 1.667 3.496], 1e-3 );

%!test
%! # Example 8.3 p. 331 Bolch et al.
%! # compare results of convolution to those of mva
%! S = [ 0.02 0.2 0.4 0.6 ];
%! K = 6;
%! V = [ 1 0.4 0.2 0.1 ];
%! [U_mva R_mva Q_mva X_mva G_mva] = qncsmva(K, S, V);
%! [U_con R_con Q_con X_con G_con] = qncsconv(K, S, V);
%! assert( U_mva, U_con, 1e-5 );
%! assert( R_mva, R_con, 1e-5 );
%! assert( Q_mva, Q_con, 1e-5 );
%! assert( X_mva, X_con, 1e-5 );
%! assert( G_mva, G_con, 1e-5 );

%!test
%! # Compare the results of convolution to those of mva
%! S = [ 0.02 0.2 0.4 0.6 ];
%! K = 6;
%! V = [ 1 0.4 0.2 0.1 ];
%! m = [ 1 -1 2 1 ]; # center 2 is IS
%! [U_mva R_mva Q_mva X_mva] = qncsmva(K, S, V, m);
%! [U_con R_con Q_con X_con G] = qncsconv(K, S, V, m );
%! assert( U_mva, U_con, 1e-5 );
%! assert( R_mva, R_con, 1e-5 );
%! assert( Q_mva, Q_con, 1e-5 );
%! assert( X_mva, X_con, 1e-5 );

## result = F(i,j,v,S,m)
##
## Helper fuction to compute F(i,j) as defined in Eq 7.61 p. 289 of
## Bolch, Greiner, de Meer, Trivedi "Queueing Networks and Markov
## Chains: Modeling and Performance Evaluation with Computer Science
## Applications", Wiley, 1998. This function has been vectorized,
## and accepts a vector as parameter j.
function result = F(i,j,v,S,m)
  isscalar(i) || ...
      error( "i must be a scalar" );
  k_i = j;
  if ( m(i) == 1 )
    result = ( v(i)*S(i) ).^k_i;
  else
    ii = find(k_i<=m(i)); ## if k_i<=m(i)
    result(ii) = ( v(i)*S(i) ).^k_i(ii) ./ factorial(k_i(ii));
    ii = find(k_i>m(i)); ## if k_i>m(i)
    result(ii) = ( v(i)*S(i) ).^k_i(ii) ./ ( factorial(m(i))*m(i).^(k_i(ii)-m(i)) );
  endif
endfunction

%!demo
%! n = [1 2 0];
%! N = sum(n); # Total population size
%! S = [ 1/0.8 1/0.6 1/0.4 ];
%! m = [ 2 3 1 ];
%! V = [ 1 .667 .2 ];
%! [U R Q X G] = qncsconv( N, S, V, m );
%! p = [0 0 0]; # initialize p
%! # Compute the probability to have n(k) jobs at service center k
%! for k=1:3
%!   p(k) = (V(k)*S(k))^n(k) / G(N+1) * ...
%!          (G(N-n(k)+1) - V(k)*S(k)*G(N-n(k)) );
%!   printf("Prob( n(%d) = %d )=%f\n", k, n(k), p(k) );
%! endfor
