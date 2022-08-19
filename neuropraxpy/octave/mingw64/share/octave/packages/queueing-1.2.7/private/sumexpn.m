## Copyright (C) 2012, 2019 Moreno Marzolla
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
## @deftypefn {Function File} {@var{r} =} sumexpn (@var{a}, @var{n})
##
## Compute the sum:
## 
## @iftex
## @tex
## $$ S(a,n) = \sum_{k=0}^n {a^k \over k!} $$
## @end tex
## @end iftex
## @ifnottex
## @example
##           n
##           __ 
##          \    a^k
## S(a,n) =  >  -----      
##          /__   k!
##          k=0
## @end example
## @end ifnottex
##
## with @math{a>0} and @math{n @geq{} 0}.
##
## @end deftypefn
function r = sumexpn( a, n )
  n>=0 || ...
      error("n must be nonnegative");
  a>0 || ...
  error("a must be positive");
  #{
  A direct calculation of the summation yields the expression:

  r = sum(cumprod([1 a./(1:n)]));

  However, we can apply an approach similar to
  Horner's rule and rewrite

  a^0   a^1   a^2         a^n
  --- + --- + --- + ... + ---
   0!    1!    2!          n!

  as

      a /     a /     a /         /     a \     \\\
  1 + - | 1 + - | 1 + - | 1 + ... | 1 + - | ... |||
      1 \     2 \     3 \         \     n /     ///

  from which we can use the following iterative code that is
  numerically more stable:
  #}
  r = 1;
  for k=n:-1:1
    r = (1+(a/k)*r);
  endfor
endfunction
%!test
%! a = 0.8;
%! n = 0;
%! assert( sumexpn(a,n), sum(a.^(0:n) ./ factorial(0:n)), 1e-6 );

%!test
%! a = 1.2;
%! n = 6;
%! assert( sumexpn(a,n), sum(a.^(0:n) ./ factorial(0:n)), 1e-6 );

%!test
%! a = 18;
%! assert( sumexpn(a,0), 1, 1e-6 );

%!test
%! a = 18;
%! assert( sumexpn(a,1), 1 + a, 1e-6 );

%!test
%! a = 1.75;
%! assert( sumexpn(a, 2), 1 + a + (a^2)/2, 1e-6 );

%!demo
%! function r = sumexpn_direct(a, n)
%!  r = sum(cumprod([1 a./(1:n)]));
%! endfunction
%!
%! a = 0.1:0.05:30;
%! n = 20;
%! d = zeros(size(a));
%! for idx=1:length(a)
%!  d(idx) = sumexpn_direct(a(idx),n) - sumexpn(a(idx),n);
%! endfor
%! plot(a,d, ";sumexpn_direct - sumexpn;");
