## Copyright (C) 2011, 2012, 2016, 2018 Moreno Marzolla
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
## @deftypefn {Function File} {[@var{U}, @var{R}, @var{Q}, @var{X}] =} qncscmva (@var{N}, @var{S}, @var{Sld}, @var{V})
## @deftypefnx {Function File} {[@var{U}, @var{R}, @var{Q}, @var{X}] =} qncscmva (@var{N}, @var{S}, @var{Sld}, @var{V}, @var{Z})
##
## @cindex conditional MVA (CMVA)
## @cindex Mean Value Analysis, conditional (CMVA)
## @cindex closed network, single class
## @cindex CMVA
##
## Conditional MVA (CMVA) algorithm, a numerically stable variant of
## MVA. This function supports a network of @math{M @geq{} 1} service
## centers and a single delay center. Servers @math{1, @dots{}, (M-1)}
## are load-independent; server @math{M} is load-dependent.
##
## @strong{INPUTS}
##
## @table @code
##
## @item @var{N}
## Number of requests in the system, @code{@var{N} @geq{} 0}. If
## @code{@var{N} == 0}, this function returns @code{@var{U} = @var{R}
## = @var{Q} = @var{X} = 0}
##
## @item @var{S}(k)
## mean service time on server @math{k = 1, @dots{}, (M-1)}
## (@code{@var{S}(k) > 0}). If there are no fixed-rate servers, then
## @code{S = []}
##
## @item @var{Sld}(n)
## inverse service rate at server @math{M} (the load-dependent server)
## when there are @math{n} requests, @math{n=1, @dots{}, N}.
## @code{@var{Sld}(n) = } @math{1 / \mu(n)}.
##
## @item @var{V}(k)
## average number of visits to service center @math{k=1, @dots{}, M},
## where @code{@var{V}(k) @geq{} 0}. @code{@var{V}(1:M-1)} are the
## visit rates to the fixed rate servers; @code{@var{V}(M)} is the
## visit rate to the load dependent server.
##
## @item @var{Z}
## External delay for customers (@code{@var{Z} @geq{} 0}). Default is 0.
##
## @end table
##
## @strong{OUTPUTS}
##
## @table @code
##
## @item @var{U}(k)
## center @math{k} utilization (@math{k=1, @dots{}, M})
##
## @item @var{R}(k)
## response time of center @math{k} (@math{k=1, @dots{}, M}). The
## system response time @var{Rsys} can be computed as @code{@var{Rsys}
## = @var{N}/@var{Xsys} - Z}
##
## @item @var{Q}(k)
## average number of requests at center @math{k} (@math{k=1, @dots{}, M}).
##
## @item @var{X}(k)
## center @math{k} throughput (@math{k=1, @dots{}, M}).
##
## @end table
##
## @strong{REFERENCES}
##
## @itemize
## @item
## G. Casale. @cite{A note on stable flow-equivalent aggregation in
## closed networks}. Queueing Syst. Theory Appl., 60:193–-202, December
## 2008, @uref{http://dx.doi.org/10.1007/s11134-008-9093-6, 10.1007/s11134-008-9093-6}
## @end itemize
##
## @end deftypefn

## Author: Moreno Marzolla <moreno.marzolla(at)unibo.it>
## Web: http://www.moreno.marzolla.name/

function [U R Q X] = qncscmva( N, S, Sld, V, Z )

  ## This is a numerically stable implementation of the MVA algorithm,
  ## described in G. Casale, A note on stable flow-equivalent aggregation in
  ## closed networks. Queueing Syst. Theory Appl., 60:193–-202, December
  ## 2008, http://dx.doi.org/10.1007/s11134-008-9093-6


  if ( nargin < 4 || nargin > 5 )
    print_usage();
  endif

  isscalar(N) && N >= 0 || ...
      error("N must be a positive scalar");

  (isempty(S) || isvector(S)) || ...
      error("S must be a vector");
  S = S(:)'; # make S a row vector
  M = length(S)+1; # total number of service centers (excluding the delay center)
  
  isvector(Sld) && length(Sld) == N && all(Sld>=0) || ...
      error("Sld must be a vector with %d elements >= 0", N);
  Sld = Sld(:)'; # Make Sld a row vector

  isvector(V) && length(V) == M && all(V>=0) || ...
      error("V must be a vector with %d elements", M);
  V = V(:)'; # Make V a row vector

  ## The reference paper assumes queue M (LD center) as reference.
  ## Therefore, we need to rescale V

  V(M) > 0 || ...
      error("V(M) must be >0");

  V = V / V(M);

  if ( nargin == 5 )
    isscalar(Z) && Z>=0 || ...
	error("Z must be nonnegative");
  else
    Z = 0;
  endif

  if ( N == 0 )
    U = R = Q = X = zeros(1,M);
    return;
  endif

  ## Di(1+k) = service demand of server k=0,1,...,M-1 (server 0 is the delay center)
  Di = zeros(1,M); 
  Di(1) = Z;
  Di(2:M) = S .* V(1:M-1);
  ## DM(n,t), n=1, ..., N, t=1, ..., N
  DM = zeros(N,N);

  mu = 1./Sld; # rate function

  ## Ri(1+k,:,:) = response time of server k=0,1,...,M
  Ri = zeros(1+M,N,N); 

  ## Qi(k,1+n,t) = queue length of server k=1,...,M, n=0,1,...,N, t=1,...,N+1
  Qi = zeros(M,1+N,N+1);

  Xs = zeros(N,N); # Xs = system throughput

  ## Main MVA loop
  for n=1:N 
    for t=1:(N-n+1)
      if ( n==1 )
	DM(n,t) = 1/mu(t);
      else # n>=2
	DM(n,t) = Xs(n-1,t)/Xs(n-1,t+1)*DM(n-1,t);
      endif

      Ri(1+0,n,t) = Di(1+0);
      i=1:M-1; Ri(1+i,n,t) = Di(1+i).*(1+Qi(i,1+n-1,t))';
      Ri(1+M,n,t) = DM(n,t)*(1+Qi(M,1+n-1,t+1));

      Xs(n,t) = n/sum(Ri(:,n,t));

      i=1:M-1; Qi(i,1+n,t) = Di(1+i) .* Xs(n,t) .* (1+Qi(i,1+n-1,t))';
      Qi(M,1+n,t) = DM(n,t) * Xs(n,t) * (1+Qi(M,1+n-1,t+1));
    endfor
  endfor
  X = Xs(N,1).*V;
  Q = Qi(1:M,1+N,1)';
  ## Note that the result R is the *response time*, while the value
  ## computed by the reference paper is the *residence time*. The
  ## response time is equal to the residence time divided by the visit
  ## ratios. FIXME: This will choke if the visit ratio is zero for some server k
  R = Ri(2:M+1,N,1)' ./ V;
  U = [Di(2:M) DM(N,1)] .* X ./ V;
endfunction
%!test
%! N=5;
%! S = [1 0.3 0.8 0.9];
%! V = [1 1 1 1];
%! [U1 R1 Q1 X1] = qncscmva( N, S(1:3), repmat(S(4),1,N), V );
%! [U2 R2 Q2 X2] = qncsmva(N, S, V);
%! assert( X1, X2, 1e-5 );
%! assert( U1, U2, 1e-5 );
%! assert( R1, R2, 1e-5 );
%! assert( Q1, Q2, 1e-5 );

%!test
%! N=5;
%! S = [1 1 1 1 1; ...
%!      1 1 1 1 1; ...
%!      1 1 1 1 1; ...
%!      1 1/2 1/3 1/4 1/5];
%! V = [1 1 1 1];
%! [U1 R1 Q1 X1] = qncscmva( N, S(1:3,1), S(4,:), V );
%! [U2 R2 Q2 X2] = qncsmvald(N, S, V);
%! assert( U1, U2, 1e-5 );
%! assert( R1, R2, 1e-5 );
%! assert( Q1, Q2, 1e-5 );
%! assert( X1, X2, 1e-5 );

%!test
%! N=5;
%! S = [1 1 1 1 1; ...
%!      1 1 1 1 1; ...
%!      1 1 1 1 1; ...
%!      1 1/2 1/3 1/4 1/5];
%! V = [1 2 1 1];
%! Z = 3;
%! [U1 R1 Q1 X1] = qncscmva( N, S(1:3,1), S(4,:), V, Z );
%! [U2 R2 Q2 X2] = qncsmvald(N, S, V, Z);
%! assert( U1, U2, 1e-5 );
%! assert( R1, R2, 1e-5 );
%! assert( Q1, Q2, 1e-5 );
%! assert( X1, X2, 1e-5 );

%!demo
%! maxN = 90; # Max population size
%! Rmva = Rconv = Rcmva = zeros(1,maxN); # Results
%! S = 4; Z = 10; m = 8;
%! old = warning("query","qn:numerical-instability");
%! warning("off","qn:numerical-instability");
%! for N=1:maxN
%!   [U R] = qncsmva(N,S,1,m,Z);		# Use MVA
%!   Rmva(N) = R(1);
%!   [U R] = qncsconv(N,[S Z],[1 1],[m -1]);	# Use Convolution
%!   Rconv(N) = R(1);
%!   if ( N > m )
%!     Scmva = S ./ min(1:N,m);
%!   else
%!     Scmva = S ./ (1:N);
%!   endif
%!   [U R] = qncscmva(N,[],Scmva,1,Z);		# Use CMVA
%!   Rcmva(N) = R(1);
%! endfor
%! warning(old.state,"qn:numerical-instability");
%! plot(1:maxN, Rmva, ";MVA;", ...
%!      1:maxN, Rconv, ";Convolution;", ...
%!      1:maxN, Rcmva, ";CNVA;", "linewidth",2);
%! xlabel("Population size (N)");
%! ylabel("Response Time");
%! ax=axis(); ax(3) = 0; ax(4) = 40; axis(ax);
%! legend("location","northwest"); legend("boxoff");
