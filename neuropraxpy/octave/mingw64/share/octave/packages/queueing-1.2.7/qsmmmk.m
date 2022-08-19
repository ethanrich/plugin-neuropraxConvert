## Copyright (C) 2008, 2009, 2010, 2011, 2012, 2013, 2016, 2018, 2019 Moreno Marzolla
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
## @deftypefn {Function File} {[@var{U}, @var{R}, @var{Q}, @var{X}, @var{p0}, @var{pK}] =} qsmmmk (@var{lambda}, @var{mu}, @var{m}, @var{K})
## @deftypefnx {Function File} {@var{pn} =} qsmmmk (@var{lambda}, @var{mu}, @var{m}, @var{K}, @var{n})
##
## @cindex @math{M/M/m/K} system
##
## Compute utilization, response time, average number of requests and
## throughput for a @math{M/M/m/K} finite capacity system. In a
## @math{M/M/m/K} system there are @math{m \geq 1} identical service centers
## sharing a fixed-capacity queue. At any time, at most @math{K @geq{} m} requests can be in the system, including those being served. The maximum queue length
## is @math{K-m}. This function generates and
## solves the underlying CTMC.
##
## @tex
##
## The steady-state probability @math{\pi_n} that there are @math{n}
## jobs in the system, @math{0 @leq{} n @leq{} K}, is:
##
## $$
## \pi_n = \cases{ \displaystyle{{\rho^n \over n!} \pi_0} & if $0 \leq n \leq m$;\cr\cr
##                 \displaystyle{{\rho^m \over m!} \left( \rho \over m \right)^{n-m} \pi_0} & if $m < n \leq K$\cr}
## $$
##
## where @math{\rho = \lambda/\mu} is the offered load. The probability
## @math{\pi_0} that the system is empty can be computed by considering
## that all probabilities must sum to one: @math{\sum_{k=0}^K \pi_k = 1},
## that gives:
##
## $$
## \pi_0 = \left[ \sum_{k=0}^m {\rho^k \over k!} + {\rho^m \over m!} \sum_{k=m+1}^K \left( {\rho \over m}\right)^{k-m} \right]^{-1}
## $$
##
## @end tex
##
## @strong{INPUTS}
##
## @table @code
##
## @item @var{lambda}
## Arrival rate (@code{@var{lambda}>0})
##
## @item @var{mu}
## Service rate (@code{@var{mu}>0})
##
## @item @var{m}
## Number of servers (@code{@var{m} @geq{} 1})
##
## @item @var{K}
## Maximum number of requests allowed in the system,
## including those being served (@code{@var{K} @geq{} @var{m}})
##
## @item @var{n}
## Number of requests in the (@code{0 @leq{} @var{n} @leq{} K}).
##
## @end table
##
## @strong{OUTPUTS}
##
## @table @code
##
## @item @var{U}
## Service center utilization
##
## @item @var{R}
## Service center response time
##
## @item @var{Q}
## Average number of requests in the system
##
## @item @var{X}
## Service center throughput
##
## @item @var{p0}
## Steady-state probability that there are no requests in the system.
##
## @item @var{pK}
## Steady-state probability that there are @var{K} requests in the system
## (i.e., probability that the system is full).
##
## @item @var{pn}
## Steady-state probability that there are @var{n} requests in the system
## (including those being served).
##
## @end table
##
## If this function is called with less than five arguments,
## @var{lambda}, @var{mu}, @var{m} and @var{K} can be either scalars, or
## vectors of the  same size. In this case, the results will be vectors
## as well.
##
## @strong{REFERENCES}
##
## @itemize
## @item
## G. Bolch, S. Greiner, H. de Meer and K. Trivedi, @cite{Queueing Networks
## and Markov Chains: Modeling and Performance Evaluation with Computer
## Science Applications}, Wiley, 1998, Section 6.6
## @end itemize
##
## @seealso{qsmm1,qsmminf,qsmmm}
##
## @end deftypefn

## Author: Moreno Marzolla <moreno.marzolla(at)unibo.it>
## Web: http://www.moreno.marzolla.name/

function [U_or_pn R Q X p0 pK] = qsmmmk( lambda, mu, m, K, n )
  if ( nargin < 4 || nargin > 5 )
    print_usage();
  endif

  ( isvector(lambda) && isvector(mu) && isvector(m) && isvector(K) ) || ...
      error( "lambda, mu, m, K must be vectors" );
  
  lambda = lambda(:)'; # make lambda a row vector
  mu = mu(:)'; # make mu a row vector
  m = m(:)'; # make m a row vector
  K = K(:)'; # make K a row vector

  [err lambda mu m K] = common_size( lambda, mu, m, K );
  if ( err ) 
    error( "Parameters are not of common size" );
  endif

  all( K>0 ) || ...
      error( "k must be strictly positive" );
  all( m>0 ) && all( m <= K ) || ...
      error( "m must be in the range 1:k" );
  all( lambda>0 ) && all( mu>0 ) || ...
                     error( "lambda and mu must be >0" );
  if (nargin < 5) 
    U_or_pn = R = Q = X = p0 = pK = 0*lambda;
    for i=1:length(lambda)
      ## Build and solve the birth-death process describing the M/M/m/k system
      birth_rate = lambda(i)*ones(1,K(i));
      death_rate = [ linspace(1,m(i),m(i))*mu(i) ones(1,K(i)-m(i))*m(i)*mu(i) ];
      p = ctmc(ctmcbd(birth_rate, death_rate));
      p0(i) = p(1);
      pK(i) = p(1+K(i));
      j = [1:K(i)];
      Q(i) = dot( p(1+j),j );
    endfor
    ## Compute other performance measures
    X = lambda.*(1-pK);
    U_or_pn = X ./ (m .* mu );
    R = Q ./ X;
  else
    (length(lambda) == 1) || error("lambda must be a scalar if this function is called with five arguments");
    isvector(n) || error("n must be a vector");
    (all(n >= 0) && all(n <= K)) || error("n must be >= 0 and <= K");
    n = n(:)';   
    birth_rate = lambda*ones(1,K);
    death_rate = [ linspace(1,m,m)*mu ones(1,K-m)*m*mu ];
    p = ctmc(ctmcbd(birth_rate, death_rate));
    U_or_pn = p(1+n);
  endif
endfunction
%!test
%! lambda = mu = m = 1;
%! k = 10;
%! [U R Q X p0] = qsmmmk(lambda,mu,m,k);
%! assert( Q, k/2, 1e-7 );
%! assert( U, 1-p0, 1e-7 );

%!test
%! lambda = [1 0.8 2 9.2 0.01];
%! mu = lambda + 0.17;
%! k = 12;
%! [U1 R1 Q1 X1] = qsmm1k(lambda,mu,k);
%! [U2 R2 Q2 X2] = qsmmmk(lambda,mu,1,k);
%! assert( U1, U2, 1e-5 );
%! assert( R1, R2, 1e-5 );
%! assert( Q1, Q2, 1e-5 );
%! assert( X1, X2, 1e-5 );
%! #assert( [U1 R1 Q1 X1], [U2 R2 Q2 X2], 1e-5 );

%!test
%! lambda = 0.9;
%! mu = 0.75;
%! k = 10;
%! [U1 R1 Q1 X1 p01] = qsmmmk(lambda,mu,1,k);
%! [U2 R2 Q2 X2 p02] = qsmm1k(lambda,mu,k);
%! assert( [U1 R1 Q1 X1 p01], [U2 R2 Q2 X2 p02], 1e-5 );

%!test
%! lambda = 0.8;
%! mu = 0.85;
%! m = 3;
%! k = 5;
%! [U1 R1 Q1 X1 p0] = qsmmmk( lambda, mu, m, k );
%! birth = lambda*ones(1,k);
%! death = [ mu*linspace(1,m,m) mu*m*ones(1,k-m) ];
%! q = ctmc(ctmcbd( birth, death ));
%! U2 = dot( q, min( 0:k, m )/m );
%! assert( U1, U2, 1e-4 );
%! Q2 = dot( [0:k], q );
%! assert( Q1, Q2, 1e-4 );
%! assert( p0, q(1), 1e-4 );

%!test
%! # This test comes from an example I found on the web 
%! lambda = 40;
%! mu = 30;
%! m = 3;
%! k = 7;
%! [U R Q X p0] = qsmmmk( lambda, mu, m, k );
%! assert( p0, 0.255037, 1e-6 );
%! assert( R, 0.036517, 1e-6 );

%!test
%! # This test comes from an example I found on the web 
%! lambda = 50;
%! mu = 10;
%! m = 4;
%! k = 6;
%! [U R Q X p0 pk] = qsmmmk( lambda, mu, m, k );
%! assert( pk, 0.293543, 1e-6 );

%!test
%! # This test comes from an example I found on the web 
%! lambda = 3;
%! mu = 2;
%! m = 2;
%! k = 5;
%! [U R Q X p0 pk] = qsmmmk( lambda, mu, m, k );
%! assert( p0, 0.179334, 1e-6 );
%! assert( pk, 0.085113, 1e-6 );
%! assert( Q, 2.00595, 1e-5 );
%! assert( R-1/mu, 0.230857, 1e-6 ); # waiting time in the queue

%!demo
%! ## Given a M/M/m/K queue, compute the steady-state probability pn
%! ## of having n jobs in the systen.
%! lambda = 0.2;
%! mu = 0.25;
%! m = 5;
%! K = 20;
%! n = 0:10;
%! pn = qsmmmk(lambda, mu, m, K, n);
%! plot(n, pn, "-o", "linewidth", 2);
%! xlabel("N. of jobs (n)");
%! ylabel("P_n");
%! title(sprintf("M/M/%d/%d system, \\lambda = %g, \\mu = %g", m, K, lambda, mu));
