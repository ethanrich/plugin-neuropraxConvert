## Copyright (C) 2008, 2009, 2010, 2011, 2012, 2016, 2019 Moreno Marzolla
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
## @deftypefn {Function File} {[@var{U}, @var{R}, @var{Q}, @var{X}, @var{p0}, @var{pK}] =} qsmm1k (@var{lambda}, @var{mu}, @var{K})
## @deftypefnx {Function File} {@var{pn} =} qsmm1k (@var{lambda}, @var{mu}, @var{K}, @var{n})
##
## @cindex @math{M/M/1/K} system
##
## Compute utilization, response time, average number of requests and
## throughput for a @math{M/M/1/K} finite capacity system.
##
## In a @math{M/M/1/K} queue there is a single server and a queue with
## finite capacity: the maximum number of requests in the system
## (including the request being served) is @math{K}, and the maximum
## queue length is therefore @math{K-1}.
##
## @tex
## The steady-state probability @math{\pi_n} that there are @math{n}
## jobs in the system, @math{0 @leq{} n @leq{} K}, is:
##
## $$
## \pi_n = {(1-a)a^n \over 1-a^{K+1}}
## $$
##
## where @math{a = \lambda/\mu}.
## @end tex
##
## @strong{INPUTS}
##
## @table @code
##
## @item @var{lambda}
## Arrival rate (@code{@var{lambda}>0}).
##
## @item @var{mu}
## Service rate (@code{@var{mu}>0}).
##
## @item @var{K}
## Maximum number of requests allowed in the system (@code{@var{K} @geq{} 1}).
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
## Service center utilization, which is defined as @code{@var{U} = 1-@var{p0}}
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
## Steady-state probability that there are no requests in the system
##
## @item @var{pK}
## Steady-state probability that there are @math{K} requests in the system
## (i.e., that the system is full)
##
## @item @var{pn}
## Steady-state probability that there are @math{n} requests in the system
## (including the one being served).
##
## @end table
##
## If this function is called with less than four arguments,
## @var{lambda}, @var{mu} and @var{K} can be vectors of the
## same size. In this case, the results will be vectors as well.
##
## @seealso{qsmm1,qsmminf,qsmmm}
##
## @end deftypefn

## Author: Moreno Marzolla <moreno.marzolla(at)unibo.it>
## Web: http://www.moreno.marzolla.name/

function [U_or_pn R Q X p0 pK] = qsmm1k( lambda, mu, K, n )
  if ( nargin < 3 || nargin > 4 )
    print_usage();
  endif

  ( isvector(lambda) && isvector(mu) && isvector(K) ) || ...
      error( "lambda, mu, K must be vectors of the same size" );

  [err lambda mu K] = common_size( lambda, mu, K );
  if ( err ) 
    error( "Parameters are not of common size" );
  endif

  all( K>0 ) || ...
      error( "K must be >0" );
  ( all( lambda>0 ) && all( mu>0 ) ) || ...
      error( "lambda and mu must be >0" );
  
  a = lambda./mu;

  if (nargin < 4)
    U_or_pn = R = Q = X = p0 = pK = 0*lambda;
    ## persistent tol = 1e-7;
    ## if a!=1
    ## i = find( abs(a-1)>tol );
    i = find( a != 1 );
    p0(i) = (1-a(i))./(1-a(i).^(K(i)+1));
    pK(i) = (1-a(i)).*(a(i).^K(i))./(1-a(i).^(K(i)+1));
    Q(i) = a(i)./(1-a(i)) - (K(i)+1)./(1-a(i).^(K(i)+1)).*(a(i).^(K(i)+1));
    ## if a==1
    ## i = find( abs(a-1)<=tol );
    i = find( a == 1 );
    p0(i) = pK(i) = 1./(K(i)+1);
    Q(i) = K(i)/2;   
    ## Compute other performance measures
    U_or_pn = 1-p0;
    X = lambda.*(1-pK);
    R = Q ./ X;
  else
    (length(lambda) == 1) || error("lambda must be a scalar if this function is called with four arguments");
    isvector(n) || error("n must be a vector");
    (all(n >= 0) && all(n <= K)) || error("n must be >= 0 and <= K");
    n = n(:)';
    if (a != 1) # we know that a must be a scalar
      U_or_pn = ((1 - a) * a.^n) ./ (1 - a^(K+1));
    else
      U_or_pn = 1/(K+1) * ones(size(n));
    endif
  endif
endfunction
%!test
%! lambda = mu = 1;
%! K = 10;
%! [U R Q X p0] = qsmm1k(lambda,mu,K);
%! assert( Q, K/2, 1e-7 );
%! assert( U, 1-p0, 1e-7 );

%!test
%! lambda = 1;
%! mu = 1.2;
%! K = 10;
%! [U R Q X p0 pK] = qsmm1k(lambda, mu, K);
%! prob = qsmm1k(lambda, mu, K, 0:K);
%! assert( p0, prob(1), 1e-7 );
%! assert( pK, prob(K+1), 1e-7 );

%!test
%! # Compare the result with the equivalent Markov chain
%! lambda = 0.8;
%! mu = 0.8;
%! K = 10;
%! [U1 R1 Q1 X1] = qsmm1k( lambda, mu, K );
%! birth = lambda*ones(1,K);
%! death = mu*ones(1,K);
%! q = ctmc(ctmcbd( birth, death ));
%! U2 = 1-q(1);
%! Q2 = dot( [0:K], q );
%! assert( U1, U2, 1e-4 );
%! assert( Q1, Q2, 1e-4 );

%!demo
%! ## Given a M/M/1/K queue, compute the steady-state probability pk
%! ## of having n requests in the systen.
%! lambda = 0.2;
%! mu = 0.25;
%! K = 10;
%! n = 0:10;
%! pn = qsmm1k(lambda, mu, K, n);
%! plot(n, pn, "-o", "linewidth", 2);
%! xlabel("N. of requests (n)");
%! ylabel("p_n");
%! title(sprintf("M/M/1/%d system, \\lambda = %g, \\mu = %g", K, lambda, mu));
