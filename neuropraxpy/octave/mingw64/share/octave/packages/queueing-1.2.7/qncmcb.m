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
## @deftypefn {Function File} {[@var{Xl}, @var{Xu}, @var{Rl}, @var{Ru}] =} qncmcb (@var{N}, @var{D})
## @deftypefnx {Function File} {[@var{Xl}, @var{Xu}, @var{Rl}, @var{Ru}] =} qncmcb (@var{N}, @var{S}, @var{V})
##
## @cindex multiclass network, closed
## @cindex closed multiclass network
## @cindex bounds, composite
## @cindex composite bounds
##
## Compute Composite Bounds (CB) on system throughput and response time for closed multiclass networks.
##
## @strong{INPUTS}
##
## @table @code
##
## @item @var{N}(c)
## number of class @math{c} requests in the system.
##
## @item @var{D}(c, k)
## class @math{c} service demand
## at center @math{k} (@code{@var{S}(c,k) @geq{} 0}).
##
## @item @var{S}(c, k)
## mean service time of class @math{c}
## requests at center @math{k} (@code{@var{S}(c,k) @geq{} 0}).
##
## @item @var{V}(c,k)
## average number of visits of class @math{c}
## requests to center @math{k} (@code{@var{V}(c,k) @geq{} 0}).
##
## @end table
##
## @strong{OUTPUTS}
##
## @table @code
##
## @item @var{Xl}(c)
## @itemx @var{Xu}(c)
## Lower and upper bounds on class @math{c} throughput.
##
## @item @var{Rl}(c)
## @itemx @var{Ru}(c)
## Lower and upper bounds on class @math{c} response time.
##
## @end table
##
## @strong{REFERENCES}
##
## @itemize
## @item
## Teemu Kerola, @cite{The Composite Bound Method (CBM) for Computing
## Throughput Bounds in Multiple Class Environments}, Performance
## Evaluation Vol. 6, Issue 1, March 1986, DOI
## @uref{http://dx.doi.org/10.1016/0166-5316(86)90002-7,
## 10.1016/0166-5316(86)90002-7}. Also available as
## @uref{http://docs.lib.purdue.edu/cstech/395/, Technical Report
## CSD-TR-475}, Department of Computer Sciences, Purdue University, mar
## 13, 1984 (Revised Aug 27, 1984).
## @end itemize
##
## @end deftypefn

## Author: Moreno Marzolla <moreno.marzolla(at)unibo.it>
## Web: http://www.moreno.marzolla.name/

function [Xl Xu Rl Ru] = qncmcb( varargin )

  if ( nargin < 2 || nargin > 3 )
    print_usage();
  endif

  [err N S V m Z] = qncmchkparam( varargin{:} );
  isempty(err) || error(err);

  all(m == 1) || ...
      error("this function only supports single-server FCFS centers");

  all(Z == 0) || ...
      error("this function does not support think time");

  [C K] = size(S);

  D = S .* V;

  [Xl] = qncmbsb(N, D);
  Xu = zeros(1,C);

  D_max = max(D,[],2)';
  for r=1:C

    ## This is equation (13) from T. Kerola, The Composite Bound Method
    ## (CBM) for Computing Throughput Bounds in Multiple Class
    ## Environments, Technical Report CSD-TR-475, Purdue University,
    ## march 13, 1984 (revised august 27, 1984)
    ## http://docs.lib.purdue.edu/cstech/395/

    ## The only modification here is to apply also the upper bound
    ## 1/D_max(r).

    s = (1:C != r); # boolean array
    tmp = (1 .- Xl(s)*D(s,:)) ./ D(r,:);
    Xu(r) = min([tmp 1/D_max(r)]);
  endfor

  Rl = N ./ Xu;
  Ru = N ./ Xl;
endfunction

%!demo
%! S = [10 7 5 4; ...
%!      5  2 4 6];
%! NN=20;
%! Xl = Xu = Rl = Ru = Xmva = Rmva = zeros(NN,2);
%! for n=1:NN
%!   N=[n,10];
%!   [a b c d] = qncmcb(N,S);
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
