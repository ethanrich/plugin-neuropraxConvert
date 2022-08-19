## Copyright (C) 2008, 2009, 2010, 2011, 2012, 2018, 2019 Moreno Marzolla
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
## @deftypefn {Function File} {[@var{U}, @var{R}, @var{Q}, @var{X}, @var{p0}] =} qsmminf (@var{lambda}, @var{mu})
## @deftypefnx {Function File} {@var{pk} =} qsmminf (@var{lambda}, @var{mu}, @var{k})
##
## Compute utilization, response time, average number of requests and throughput for an infinite-server queue.
##
## The @math{M/M/\infty} system has an infinite number of identical
## servers. Such a system is always stable (i.e., the mean queue
## length is always finite) for any arrival and service rates.
##
## @cindex @math{M/M/}inf system
##
## @tex
## The steady-state probability @math{\pi_k} that there are @math{k}
## requests in the system, @math{k @geq{} 0}, can be computed as:
##
## $$
## \pi_k = {1 \over k!} \left( \lambda \over \mu \right)^k e^{-\lambda / \mu}
## $$
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
## Traffic intensity (defined as @math{\lambda/\mu}). Note that this is
## different from the utilization, which in the case of @math{M/M/\infty}
## centers is always zero.
##
## @cindex traffic intensity
##
## @item @var{R}
## Service center response time.
##
## @item @var{Q}
## Average number of requests in the system (which is equal to the
## traffic intensity @math{\lambda/\mu}).
##
## @item @var{X}
## Throughput (which is always equal to @code{@var{X} = @var{lambda}}).
##
## @item @var{p0}
## Steady-state probability that there are no requests in the system
##
## @item @var{pk}
## Steady-state probability that there are @var{k} requests in the
## system (including the one being served).
##
## @end table
##
## If this function is called with less than three arguments,
## @var{lambda} and @var{mu} can be vectors of the same size. In this
## case, the results will be vectors as well.
##
## @strong{REFERENCES}
##
## @itemize
## @item
## G. Bolch, S. Greiner, H. de Meer and K. Trivedi, @cite{Queueing Networks
## and Markov Chains: Modeling and Performance Evaluation with Computer
## Science Applications}, Wiley, 1998, Section 6.4
## @end itemize
##
## @seealso{qsmm1,qsmmm,qsmmmk}
##
## @end deftypefn

## Author: Moreno Marzolla <moreno.marzolla(at)unibo.it>
## Web: http://www.moreno.marzolla.name/

function [U_or_pk R Q X p0] = qsmminf( lambda, mu, k )
  if ( nargin < 2 || nargin > 3 )
    print_usage();
  endif
  ( isvector(lambda) && isvector(mu) ) || ...
      error( "lambda and mu must be vectors" );
  [ err lambda mu ] = common_size( lambda, mu );
  if ( err ) 
    error( "Parameters are of incompatible size" );
  endif  
  lambda = lambda(:)';
  mu = mu(:)';
  ( all( lambda>0 ) && all( mu>0 ) ) || ...
  error( "lambda and mu must be >0" );
  if (nargin < 3) 
    U_or_pk = Q = lambda ./ mu; # Traffic intensity.
    p0 = exp(-lambda./mu); # probability that there are 0 requests in the system
    R = 1 ./ mu;
    X = lambda;
  else
    (length(lambda) == 1) || error("lambda must be a scalar if this function is called with three arguments");
    isvector(k) || error("k must be a vector");
    all(k>=0 )|| error("k must be >= 0");
    ## expn does not support array arguments, hence we must use arrayfun()
    U_or_pk = arrayfun(@(x) expn(lambda/mu, x) * exp(-lambda/mu), k);
  endif
endfunction
%!test
%! fail( "qsmminf( [1 2], [1 2 3] )", "incompatible size");
%! fail( "qsmminf( [-1 -1], [1 1] )", ">0" );

%!demo
%! ## Given a M/M/inf and M/M/m queue, compute the steady-state probability pk
%! ## of having k requests in the systen.
%! lambda = 5;
%! mu = 1.1;
%! m = 5;
%! k = 0:20;
%! pk_inf = qsmminf(lambda, mu, k);
%! pk_m = qsmmm(lambda, mu, 5, k);
%! plot(k, pk_inf, "-o;M/M/\\infty;", "linewidth", 2, ...
%!      k, pk_m, "-x;M/M/5;", "linewidth", 2);
%! xlabel("N. of requests (k)");
%! ylabel("P_k");
%! title(sprintf("M/M/\\infty and M/M/%d systems, \\lambda = %g, \\mu = %g", m, lambda, mu));
