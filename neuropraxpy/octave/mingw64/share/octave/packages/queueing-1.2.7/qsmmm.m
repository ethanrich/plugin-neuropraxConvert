## Copyright (C) 2008, 2009, 2010, 2011, 2012, 2013, 2014, 2016, 2018, 2019 Moreno Marzolla
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
## @deftypefn {Function File} {[@var{U}, @var{R}, @var{Q}, @var{X}, @var{p0}, @var{pm}] =} qsmmm (@var{lambda}, @var{mu})
## @deftypefnx {Function File} {[@var{U}, @var{R}, @var{Q}, @var{X}, @var{p0}, @var{pm}] =} qsmmm (@var{lambda}, @var{mu}, @var{m})
## @deftypefnx {Function File} {@var{pk} =} qsmmm (@var{lambda}, @var{mu}, @var{m}, @var{k})
##
## @cindex @math{M/M/m} system
##
## Compute utilization, response time, average number of requests in
## service and throughput for a @math{M/M/m} queue, a queueing system
## with @math{m} identical servers connected to a single FCFS
## queue.
##
## @tex
## The steady-state probability @math{\pi_k} that there are @math{k}
## requests in the system, @math{k \geq 0}, can be computed as:
##
## $$
## \pi_k = \cases{ \displaystyle{\pi_0 { ( m\rho )^k \over k!}} & $0 \leq k \leq m$;\cr\cr
##                 \displaystyle{\pi_0 { \rho^k m^m \over m!}} & $k>m$.\cr
## }
## $$
##
## where @math{\rho = \lambda/(m\mu)} is the individual server utilization.
## The steady-state probability @math{\pi_0} that there are no jobs in the
## system is:
##
## $$
## \pi_0 = \left[ \sum_{k=0}^{m-1} { (m\rho)^k \over k! } + { (m\rho)^m \over m!} {1 \over 1-\rho} \right]^{-1}
## $$
##
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
## Service rate (@code{@var{mu}>@var{lambda}}).
##
## @item @var{m}
## Number of servers (@code{@var{m} @geq{} 1}).
## Default is @code{@var{m}=1}.
##
## @item @var{k}
## Number of requests in the system (@code{@var{k} @geq{} 0}).
##
## @end table
##
## @strong{OUTPUTS}
##
## @table @code
##
## @item @var{U}
## Service center utilization, @math{U = \lambda / (m \mu)}.
##
## @item @var{R}
## Service center mean response time
##
## @item @var{Q}
## Average number of requests in the system
##
## @item @var{X}
## Service center throughput. If the system is ergodic, 
## we will always have @code{@var{X} = @var{lambda}}
##
## @item @var{p0}
## Steady-state probability that there are 0 requests in the system
##
## @item @var{pm}
## Steady-state probability that an arriving request has to wait in the
## queue
##
## @item @var{pk}
## Steady-state probability that there are @var{k} requests in the
## system (including the one being served).
##
## @end table
##
## If this function is called with less than four parameters,
## @var{lambda}, @var{mu} and @var{m} can be vectors of the same size. In this
## case, the results will be vectors as well.
##
## @strong{REFERENCES}
##
## @itemize
## @item
## G. Bolch, S. Greiner, H. de Meer and K. Trivedi, @cite{Queueing Networks
## and Markov Chains: Modeling and Performance Evaluation with Computer
## Science Applications}, Wiley, 1998, Section 6.5
## @end itemize
##
## @seealso{erlangc,qsmm1,qsmminf,qsmmmk}
##
## @end deftypefn

## Author: Moreno Marzolla <moreno.marzolla(at)unibo.it>
## Web: http://www.moreno.marzolla.name/

function [U_or_pk R Q X p0 pm] = qsmmm( lambda, mu, m, k )
  if ( nargin < 2 || nargin > 4 )
    print_usage();
  endif
  if ( nargin == 2 )
    m = 1;
  else
    ( isnumeric(lambda) && isnumeric(mu) && isnumeric(m) ) || ...
	error( "the parameters must be numeric vectors" );
  endif
  [err lambda mu m] = common_size( lambda, mu, m );
  if ( err ) 
    error( "parameters are not of common size" );
  endif
  lambda = lambda(:)';
  mu = mu(:)';
  m = m(:)';
  all( m>0 ) || error( "m must be >0" );
  all( lambda>0 ) || error( "lambda must be >0" );
  rho = lambda ./ (m .* mu );
  all( rho < 1 ) || error( "Processing capacity exceeded" );
  for i=1:length(lambda)
    p0(i) = 1 / ( ...
                  sumexpn( m(i)*rho(i), m(i)-1 ) + ...		 
		  expn(m(i)*rho(i), m(i))/(1-rho(i)) ...
                );
  endfor  
  if (nargin < 4) 
    X = lambda;
    U_or_pk = rho;
    pm = erlangc(lambda ./ mu, m);
    Q = m .* rho .+ rho ./ (1-rho) .* pm;
    R = Q ./ X;
  else
    (length(lambda) == 1) || error("lambda must be a scalar if this function is called with four arguments");
    isvector(k) || error("k must be a vector");
    all(k>=0) || error("k must be >= 0");
    U_or_pk = 0*k;
    for idx=1:length(k)
      if (k(idx) <= m)
        U_or_pk(idx) = p0 * expn(m * rho, k(idx));
      else
        U_or_pk(idx) = p0 * expn(m * rho, m) * (rho ^ (k(idx)-m));
      endif
    endfor
  endif
endfunction
%!demo
%! # This is figure 6.4 on p. 220 Bolch et al.
%! rho = 0.9;
%! ntics = 21;
%! lambda = 0.9;
%! m = linspace(1,ntics,ntics);
%! mu = lambda./(rho .* m);
%! [U R Q X] = qsmmm(lambda, mu, m);
%! qlen = X.*(R-1./mu);
%! plot(m,Q,"o",qlen,"*");
%! axis([0,ntics,0,25]);
%! legend("Jobs in the system","Queue Length","location","northwest");
%! legend("boxoff");
%! xlabel("Number of servers (m)");
%! title("M/M/m system, \\lambda = 0.9, \\mu = 0.9");

%!demo
%! ## Given a M/M/m queue, compute the steady-state probability pk of
%! ## having k jobs in the systen.
%! lambda = 0.5;
%! mu = 0.15;
%! m = 5;
%! k = 0:10;
%! pk = qsmmm(lambda, mu, m, k);
%! plot(k, pk, "-o", "linewidth", 2);
%! xlabel("N. of jobs (k)");
%! ylabel("P_k");
%! title(sprintf("M/M/%d system, \\lambda = %g, \\mu = %g", m, lambda, mu));

