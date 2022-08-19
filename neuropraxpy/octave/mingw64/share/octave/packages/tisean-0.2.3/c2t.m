## Copyright (C) 1996-2015 Piotr Held
##
## This file is part of Octave.
##
## Octave is free software; you can redistribute it and/or
## modify it under the terms of the GNU General Public
## License as published by the Free Software Foundation;
## either version 3 of the License, or (at your option) any
## later version.
##
## Octave is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied
## warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
## PURPOSE.  See the GNU General Public License for more
## details.
##
## You should have received a copy of the GNU General Public
## License along with Octave; see the file COPYING.  If not,
## see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn{Function File} {@var{output} =} c2t (@var{d2_c1_out})
##
## This program calculates the maximum likelihood estimator (the Takens'
## estimator) from correlation sums of the output of d2 (the 'c2' field of 
## the d2 output) or c1 (the 'c1' field of c1 output).
##
## The estimator is calculated using the following equation (the integral
## is computed for the discrete values of C(r) by assuming an exact power
## law between the available points):
##
## @iftex
## @tex
## $$D_T(r)=\frac{C(r)}{\int_{0}^{r}dx\, \frac{C(x)}{x}}$$
## @end tex
## @end iftex
## @ifnottex
## @example
##             C(r)
## D (r) = ------------
##  T       /r    C(x)
##          |  dx ----
##          /0     x
## @end example
## @end ifnottex
##
## @strong{Input}
##
## The input needs to be the output of d2 or c1.
##
## @strong{Output}
##
## The output is a struct array of the same length as the input.
## It contains the following fiels:
##
## @table @var
## @item dim
## The dimension for each matrix @var{t}.
## @item t
## Matrix with two columns. The first contains epsilon (the first column
## of field 'c2' from d2 output or field 'c1' from c1 output) and the second
## is the maximum likelihood estimator (Takens' estimator).
## @end table
##
## @seealso{demo c2t, d2, c1, c2g, av_d2}
##
## @strong{Algorithms}
##
## The algorithms for this functions have been taken from the TISEAN package.
## @end deftypefn

## Author: Piotr Held <pjheld@gmail.com>.
## This function is based on c2t of TISEAN 3.0.1 
## https://github.com/heggus/Tisean"

function output = c2t (d2_c1_out)

  if (nargin != 1)
    print_usage;
  endif

  if (!(isfield (d2_c1_out, "dim") && (isfield (d2_c1_out, "c2") ...
        && isfield (d2_c1_out, "d2") && isfield (d2_c1_out, "h2") ...
        || isfield (d2_c1_out, "c1"))))
    error ('Octave:invalid-input-arg', ["d2_c1_out must be the output of ", ...
                                        "d2 or c1"]);
  endif

  t_out = cell (length (d2_c1_out), 1);
  for j = 1:size(d2_c1_out,1)
    tmp     = d2_c1_out(j);

    if (isfield (d2_c1_out, "c2"))
      corr_sums = tmp.c2;
    elseif (isfield (d2_c1_out, "c1"))
      corr_sums = tmp.c1;
    # there is no else: we checked in input validation that d2_c1_out has one
    # of the above
    endif

    # Limit to only the first positive correlation sums
    # (do not calculate output for any past first negative sum)
    idx_lt0 = min (find (corr_sums(:,2) <= 0));
    if (!isempty (idx_lt0))
      corr_sums  = corr_sums(1:idx_lt0-1,:);
    endif

    [s,idx] = sort (corr_sums(:,1));
    emat    = log (corr_sums(idx,1));
    cmat    = log (corr_sums(idx,2));

    b = (emat(2:end) .* cmat(1:end-1) .- emat(1:end-1) .* cmat(2:end)) ...
        ./ (emat(2:end) .- emat(1:end-1));
    a = (cmat(2:end) - cmat(1:end-1)) ./ (emat(2:end) - emat(1:end-1));

    cint       = (exp (b) ./ a) ...
                 .* (exp (a .* emat(2:end)) - exp (a .* emat(1:end-1)));
    # If a(i) == 0 then the right side above is '+/-Inf * (1-1)' which is NaN.
    tidx       = find (isnan (cint));
    cint(tidx) = exp (b(tidx)) .* (emat(tidx+1) - emat(tidx));
    cint       = cumsum (cint);

    t_out{j} = [exp(emat(2:end)),exp(cmat(2:end))./cint];
  endfor

  output = struct ("dim", {d2_c1_out.dim}.', "t", t_out);

#  Below is the same code as above but uses loops
#  It is left to easily see what the algorithm does.
#  output = d2_c1_out;
#  for j = 1:size(d2_c1_out,1)
#    tmp = d2_c1_out(j);
#    [s,idx] = sort (corr_sums(:,1));
#    emat = log (corr_sums(idx,1));
#    cmat = log (corr_sums(idx,2));

#    c2_out = zeros (length(corr_sums)-1,2);
#    cint = 0;
#    for i = 2:length(corr_sums)
#      b = (emat(i)*cmat(i-1)-emat(i-1)*cmat(i))/(emat(i)-emat(i-1));
#      a = (cmat(i)-cmat(i-1))/(emat(i)-emat(i-1));

#      if (a != 0)
#        cint=cint+(exp(b)/a)*(exp(a*emat(i))-exp(a*emat(i-1)));
#      else
#        cint=cint+exp(b)*(emat(i)-emat(i-1));
#      endif
#      c2_out(i-1,1) = exp (emat(i));
#      c2_out(i-1,2) = exp (cmat(i))/cint;
#    endfor
#    output(j).c2 = c2_out;
#  endfor


endfunction

%!demo
%! vals          = d2 (henon (1000), 'd', 1, 't', 50, 'm', 5);
%! takens        = c2t (vals);
%! do_plot_slope = @(x) semilogx (x{1}(:,1),x{1}(:,2),'r');
%! hold on
%! arrayfun (do_plot_slope, {takens.t});
%! hold off
%! axis tight
%! ylim ([0 3]);
%! xlabel ("Epsilon")
%! title ("Takens' Estimator");
%!###############################################################

%!test
%! c2t_res = [0.00274151703 14.7681456;0.00293963822 7.62825966;0.00315207872 5.24064684;0.0033798716 4.0903101;0.00362412469 3.3594861;0.00388602936 2.86986566;0.00416686293 2.51803875;0.00446798978 2.26902509;0.00479088025 2.09245157;0.00513710314 1.94326866;0.00550834602 1.82226741;0.00590642029 1.73174965;0.00633325987 1.63774204;0.00679094903 1.57059276;0.00728171039 1.50973487;0.00780794164 1.455006;0.00837219786 1.40932345;0.00897723623 1.37041831;0.00962599367 1.33392417;0.0103216404 1.29980099];
%! val = d2 (henon (1000), 'd', 1, 't', 50, 'm', 5);
%! res = c2t (val);
%! assert (cell2mat({res.t}.')(1:length(c2t_res),:), c2t_res, -2.51e-5);

%% Check if limiting of negative correlation sums works
%!test
%! c2t_res = [1.20000005 11.9785480;1.29999995 7.00581074;1.50000000 5.05822706;2.00000000 1.75614762];
%! in_c2   = [2 4;1.5 5;1.3 3;1.2 2.5;1.1 2.3;1 -1;0.9 1.3;0.8 1.4;0.7 1.6];
%! in      = struct ("dim",1,"c2",in_c2,"d2",0,"h2",0);
%! res = c2t (in);
%! assert (cell2mat({res.t}.'), c2t_res, -1e-5);

%% Check if funciton accepts output from c1 and produces nonzero output
%!test
%! c2t_c1_res = c2t (c1 (henon (1000)));
%! assert (!isequal (c2t_c1_res, []));
%! assert (isfield (c2t_c1_res, "t"));

%% Testing input validation
%!error <output> av_d2 (1);
