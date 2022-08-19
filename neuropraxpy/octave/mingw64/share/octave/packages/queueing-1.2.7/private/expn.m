## Copyright (C) 2012, 2018, 2019 Moreno Marzolla
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
## @deftypefn {Function File} {@var{r} =} expn (@var{a}, @var{n})
##
## Compute @code{r = a^n / n!}, with @math{a>0} and @math{n @geq{} 0}.
##
## @end deftypefn
function r = expn( a, n )
  (isscalar(n) && (n>=0)) || error("n must be nonnegative");
  (isscalar(a) && (a>0)) || error("a must be positive");
  r = prod( a./(1:n) ); # for n=0, prod([]) returns 1 which is correct
endfunction
