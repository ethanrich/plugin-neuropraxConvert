## Copyright (C) 2005 Julius O. Smith III <jos@ccrma.stanford.edu>
##
## This program is free software: you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation, either version 3 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; see the file COPYING. If not, see
## <https://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn  {Function File} {[@var{b}, @var{a}] =} sos2tf (@var{sos})
## @deftypefnx {Function File} {[@var{b}, @var{a}] =} sos2tf (@var{sos}, @var{g})
## Convert series second-order sections to direct form @math{H(z) = B(z)/A(z)}.
##
## INPUTS:
## @itemize
##
## @item
## @var{sos} = matrix of series second-order sections, one per row:
## @example
## @var{sos} = [@var{B1}.' @var{A1}.'; ...; @var{BN}.' @var{AN}.']
## @end example
## where
## @code{@var{B1}.' = [b0 b1 b2] and @var{A1}.' = [1 a1 a2]} for
## section 1, etc.  The b0 entry must be nonzero for each section.
## See @code{filter} for documentation of the second-order direct-form filter
## coefficients @var{B}i and @var{A}i.
##
## @item
## @var{g} is an overall gain factor that effectively scales
## the output @var{b} vector (or any one of the input @var{B}i vectors).
## If not given the gain is assumed to be 1.
## @end itemize
##
## RETURNED:
## @var{b} and @var{a} are vectors specifying the digital filter @math{H(z) = B(z)/A(z)}.
## See @code{filter} for further details.
##
## @seealso{tf2sos, zp2sos, sos2pz, zp2tf, tf2zp}
## @end deftypefn

function [B,A] = sos2tf(sos, g = 1)

  if (nargin < 1 || nargin > 2)
    print_usage;
  endif

  [N,M] = size(sos);

  if M~=6
    error('sos2tf: sos matrix should be N by 6');
  endif

  A = 1;
  B = 1;

  for i=1:N
    B = conv(B, sos(i,1:3));
    A = conv(A, sos(i,4:6));
  endfor

  nB = length(B);
  while nB && B(nB)==0
    B=B(1:nB-1);
    nB=length(B);
  endwhile

  nA = length(A);
  while nA && A(nA)==0
    A=A(1:nA-1);
    nA=length(A);
  endwhile

  B = B .* prod (g);

endfunction

%!test
%! B = [1, 1];
%! A = [1, 0.5];
%! [sos, g] = tf2sos (B, A);
%! [Bh, Ah] = sos2tf (sos, g);
%! assert (g, 1);
%! assert (Bh, B, 10*eps);
%! assert (Ah, A, 10*eps);

%!test
%! B = [1, 0, 0, 0, 0, 1];
%! A = [1, 0, 0, 0, 0, 0.9];
%! [sos, g] = tf2sos (B, A);
%! [Bh, Ah] = sos2tf (sos, g);
%! assert (g, 1);
%! assert (Bh, B, 100*eps);
%! assert (Ah, A, 100*eps);

## Test that gain is applied to the B vector
%!test
%! B = [1, 1];
%! A = [1, 0.5];
%! [sos, g] = tf2sos (B, A);
%! [Bh, Ah] = sos2tf (sos, 2);
%! assert (g, 1);
%! assert (Bh, 2 * B, 10*eps);
%! assert (Ah, A, 10*eps);

## Test that a vector of gain is applied as the total product
%!test
%! B = [1, 1];
%! A = [1, 0.5];
%! [sos, g] = tf2sos (B, A);
%! [Bh, Ah] = sos2tf (sos, [2, 2, 2]);
%! assert (g, 1);
%! assert (Bh, 8 * B, 10*eps);
%! assert (Ah, A, 10*eps);

