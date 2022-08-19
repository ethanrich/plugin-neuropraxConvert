## Copyright (C) 2020 Pedro Rodriguez Torija
##
## This program is free software; you can redistribute it and/or modify it under
## the terms of the GNU General Public License as published by the Free Software
## Foundation; either version 3 of the License, or (at your option) any later
## version.
##
## This program is distributed in the hope that it will be useful, but WITHOUT
## ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
## FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
## details.
##
## You should have received a copy of the GNU General Public License along with
## this program; if not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn  {Function File} {@var{ber} =} berconfint (@var{r}, @var{n})
## @deftypefnx {Function File} {[@var{ber}, @var{interval}] =} berconfint (@var{r}, @var{n})
## @deftypefnx {Function File} {[@var{ber}, @var{interval}] =} berconfint (@var{r}, @var{n}, @var{level})
##
## Returns Bit Error Rate, @var{ber}, and confidence interval, @var{interval}, for 
## the number of errors @var{r} and number of transmitted bits @var{n} with a
## confidence level of @var{level}. By default @var{level} is 0.95.
##
## The confidence interval is the Wilson one (without continuity correction) for a proportion. By contrast, Matlab appears to return the Clopper–Pearson confidence interval.
##
## Reference:
##     Robert G. Newcombe (1998), "Two‐sided confidence intervals for the single proportion: comparison of seven methods", Statistics in Medicine 17(8):857-872.
## @end deftypefn


function [ber, conf_inter] = berconfint(r,n,level)
  
  switch (nargin)
    case 2
      level = 0.95;
    case 3
      level = level;
    otherwise
      print_usage ();
  endswitch
  
  ber = r / n;
  
  if isargout (2)  
    d = - sqrt (2) * erfcinv (1 + level);
    d2 = d^2;
    y = 2 * (n + d2);  
    x = ( 2 * r + d2 ) / y;
    z = sqrt( (4 * r * n + n * d2 - 4 * r^2) / n);
    conf_inter = x + [-1 1]*(d / y * z);
  endif
 
endfunction

%!assert (berconfint (1, 2), 0.5)
%!assert (berconfint (10, 200, 0.98), 0.05)

%!test
%! [ber, conf_inter] = berconfint(100, 1E6, 0.95);
%! assert (ber, 1E-4)
%! assert (conf_inter, [8.222786e-05 1.216128e-04], 1E-10) #values are from prop.test(x=100,n=1E6,correct=FALSE) in R

%% Test input validation
%!error berconfint ()
%!error berconfint (1, 2, 3, 4)
