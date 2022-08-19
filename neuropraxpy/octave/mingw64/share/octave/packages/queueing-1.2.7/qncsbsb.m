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
## @deftypefn {Function File} {[@var{Xl}, @var{Xu}, @var{Rl}, @var{Ru}] =} qncsbsb (@var{N}, @var{D})
## @deftypefnx {Function File} {[@var{Xl}, @var{Xu}, @var{Rl}, @var{Ru}] =} qncsbsb (@var{N}, @var{S}, @var{V})
## @deftypefnx {Function File} {[@var{Xl}, @var{Xu}, @var{Rl}, @var{Ru}] =} qncsbsb (@var{N}, @var{S}, @var{V}, @var{m})
## @deftypefnx {Function File} {[@var{Xl}, @var{Xu}, @var{Rl}, @var{Ru}] =} qncsbsb (@var{N}, @var{S}, @var{V}, @var{m}, @var{Z})
##
## @cindex bounds, balanced system
## @cindex closed network, single class
## @cindex balanced system bounds
##
## Compute Balanced System Bounds on system throughput and response time for closed, single-class networks with @math{K} service centers.
##
## @strong{INPUTS}
##
## @table @code
##
## @item @var{N}
## number of requests in the system (scalar, @code{@var{N} @geq{} 0}).
##
## @item @var{D}(k)
## service demand at center @math{k} (@code{@var{D}(k) @geq{} 0}).
##
## @item @var{S}(k)
## mean service time at center @math{k} (@code{@var{S}(k) @geq{} 0}).
##
## @item @var{V}(k)
## average number of visits to center @math{k} (@code{@var{V}(k)
## @geq{} 0}). Default is 1.
##
## @item @var{m}(k)
## number of servers at center @math{k}. This function supports
## @code{@var{m}(k) = 1} only (single-eserver FCFS nodes); this
## parameter is only for compatibility with @code{qncsaba}. Default is
## 1.
##
## @item @var{Z}
## External delay (@code{@var{Z} @geq{} 0}). Default is 0.
##
## @end table
##
## @strong{OUTPUTS}
##
## @table @code
##
## @item @var{Xl}
## @itemx @var{Xu}
## Lower and upper bound on the system throughput.
##
## @item @var{Rl}
## @itemx @var{Ru}
## Lower and upper bound on the system response time.
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
## particular, see section 5.4 ("Balanced Systems Bounds").
## @end itemize
##
## @seealso{qncmbsb}
##
## @end deftypefn

## Author: Moreno Marzolla <moreno.marzolla(at)unibo.it>
## Web: http://www.moreno.marzolla.name/

function [Xl Xu Rl Ru] = qncsbsb( varargin )

  if (nargin<2 || nargin>5)
    print_usage();
  endif

  [err N S V m Z] = qncschkparam( varargin{:} );
  isempty(err) || error(err);

  all(m==1) || ...
      error( "this function supports M/M/1 servers only" );

  D = S .* V;

  D_max = max(D);
  D_tot = sum(D);
  D_ave = mean(D);
  Xl = N/(D_tot+Z+( (N-1)*D_max )/( 1+Z/(N*D_tot) ) );
  Xu = min( 1/D_max, N/( D_tot+Z+( (N-1)*D_ave )/(1+Z/D_tot) ) );
  Rl = max( N*D_max-Z, D_tot+( (N-1)*D_ave )/( 1+Z/D_tot) );
  Ru = D_tot + ( (N-1)*D_max )/( 1+Z/(N*D_tot) );
endfunction

%!test
%! fail("qncsbsb(-1,0)", "N must be");
%! fail("qncsbsb(1,[])", "nonempty");
%! fail("qncsbsb(1,[-1 2])", "nonnegative");
%! fail("qncsbsb(1,[1 2],[1 2 3])", "incompatible size");
%! fail("qncsbsb(1,[1 2 3],[1 2 3],[1 2])", "incompatible size");
%! fail("qncsbsb(1,[1 2 3],[1 2 3],[1 2 1])", "M/M/1 servers");
%! fail("qncsbsb(1,[1 2 3],[1 2 3],[1 1 1],-1)", "nonnegative");
%! fail("qncsbsb(1,[1 2 3],[1 2 3],[1 1 1],[0 0])", "scalar");

