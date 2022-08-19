## Copyright (C) 2008, 2009, 2010, 2011, 2012, 2013, 2018, 2019, 2020 Moreno Marzolla
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
## @deftypefn {Function File} {[@var{U}, @var{R}, @var{Q}, @var{X}, @var{p0}] =} qsmm1 (@var{lambda}, @var{mu})
## @deftypefnx {Function File} {@var{pk} =} qsmm1 (@var{lambda}, @var{mu}, @var{k})
##
## @cindex @math{M/M/1} system
##
## Compute utilization, response time, average number of requests and throughput for a @math{M/M/1} queue.
##
## @tex
## The steady-state probability @math{\pi_k} that there are @math{k}
## jobs in the system, @math{k \geq 0}, can be computed as:
##
## $$
## \pi_k = (1-\rho)\rho^k
## $$
##
## where @math{\rho = \lambda/\mu} is the server utilization.
##
## @end tex
##
## @strong{INPUTS}
##
## @table @code
##
## @item @var{lambda}
## Arrival rate (@code{@var{lambda} @geq{} 0}).
##
## @item @var{mu}
## Service rate (@code{@var{mu} > @var{lambda}}).
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
## Server utilization
##
## @item @var{R}
## Server response time
##
## @item @var{Q}
## Average number of requests in the system
##
## @item @var{X}
## Server throughput. If the system is ergodic (@code{@var{mu} >
## @var{lambda}}), we always have @code{@var{X} = @var{lambda}}
##
## @item @var{p0}
## Steady-state probability that there are no requests in the system.
##
## @item @var{pk}
## Steady-state probability that there are @var{k} requests in the system.
## (including the one being served).
##
## @end table
##
## If this function is called with less than three input parameters,
## @var{lambda} and @var{mu} can be vectors of the same size. In this
## case, the results will be vectors as well.
##
## @strong{REFERENCES}
##
## @itemize
## @item
## G. Bolch, S. Greiner, H. de Meer and K. Trivedi, @cite{Queueing Networks
## and Markov Chains: Modeling and Performance Evaluation with Computer
## Science Applications}, Wiley, 1998, Section 6.3
## @end itemize
##
## @seealso{qsmmm, qsmminf, qsmmmk}
##
## @end deftypefn

## Author: Moreno Marzolla <moreno.marzolla(at)unibo.it>
## Web: http://www.moreno.marzolla.name/

function [U_or_pk R Q X p0] = qsmm1( lambda, mu, k )
  if ( nargin < 2 || nargin > 3 )
    print_usage();
  endif
  ( isvector(lambda) && isvector(mu) ) || ...
      error( "lambda and mu must be vectors" );
  [ err lambda mu ] = common_size( lambda, mu );
  if ( err ) 
    error( "parameters are of incompatible size" );
  endif
  lambda = lambda(:)';
  mu = mu(:)';
  all( lambda >= 0 ) || error( "lambda must be >= 0" );
  rho = lambda ./ mu;
  all( rho < 1 ) || error( "Processing capacity exceeded" );

  if (nargin == 2) 
    U_or_pk = rho; # utilization
    p0 = 1-rho;
    Q = rho ./ (1-rho);
    R = 1 ./ ( mu .* (1-rho) );
    X = lambda;
  else
    (length(lambda) == 1) || error("lambda must be a scalar if this function is called with three arguments");
    isvector(k) || error("k must be a vector");
    all(k>=0) || error("k must be >= 0");
    k = k(:)'; # make k a row vector
    U_or_pk = (1 - rho).*rho.^k;
  endif
endfunction
%!test
%! fail( "qsmm1(10,5)", "capacity exceeded" );
%! fail( "qsmm1(1,1)", "capacity exceeded" );
%! fail( "qsmm1([2 2], [1 1 1])", "incompatible size");

%!test
%! [U R Q X P0] = qsmm1(0, 1);
%! assert( U, 0 );
%! assert( R, 1 );
%! assert( Q, 0 );
%! assert( X, 0 );
%! assert( P0, 1 );

%!test
%! [U R Q X P0] = qsmm1(0.2, 1.0);
%! pk = qsmm1(0.2, 1.0, 0);
%! assert(P0, pk);

%!demo
%! ## Given a M/M/1 queue, compute the steady-state probability pk
%! ## of having k requests in the systen.
%! lambda = 0.2;
%! mu = 0.25;
%! k = 0:10;
%! pk = qsmm1(lambda, mu, k);
%! plot(k, pk, "-o", "linewidth", 2);
%! xlabel("N. of requests (k)");
%! ylabel("p_k");
%! title(sprintf("M/M/1 system, \\lambda = %g, \\mu = %g", lambda, mu));
