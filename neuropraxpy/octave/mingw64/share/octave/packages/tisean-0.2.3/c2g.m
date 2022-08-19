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
## @deftypefn{Function File} {@var{output} =} c2g (@var{d2_out})
##
## This program calculates the Gaussian kernel correlation integral
## and its logarithmic derivatice from correlation sums calculated by d2
## (the 'c2' field of the d2 output).
##
## It uses the following formula to calculate the Gaussian kernel correlation
## integral:
##
## @iftex
## @tex
## $$C_G(r)=\frac{1}{r^2}\int_{0}^{\infty}dx\, e^{-\frac{x^2}{2r^2}}C(x)$$
## @end tex
## @end iftex
## @ifnottex
## @example
##              /00            2
##          1   |        /    x   \
## C (r) = ---  | dx exp |- ----- | x C(x)
##  G        2  |        \     2  /
##          r   /0           2r
## @end example
## @end ifnottex
##
## And the logarithmic derivative is calculated using:
##
## @iftex
## @tex
## $$D_G(r) = \frac{d}{d\log r}\log{C_G(r)}$$
## @end tex
## @end iftex
## @ifnottex
## @example
##            d
## D (r) = ------- log C (r)
##  G      d log r      G
## @end example
## @end ifnottex
##
## @strong{Input}
##
## The input needs to be the output of d2.
##
## @strong{Output}
##
## The output is a struct array of the same length as the input.
## It contains the following fiels:
##
## @table @var
## @item dim
## The dimension for each matrix @var{g}.
## @item g
## Matrix with three columns. The first contains epsilon (the first column
## of field 'c2' from the d2 output), the second is the Gaussian kernel
## correlation integral and the third its logarithmic derivative.
## @end table
##
## @seealso{demo c2g, d2, c2t, av_d2}
##
## @strong{Algorithms}
##
## The algorithms for this functions have been taken from the TISEAN package.
## @end deftypefn

## Author: Piotr Held <pjheld@gmail.com>.
## This function is based on c2g of TISEAN 3.0.1 
## https://github.com/heggus/Tisean"

function output = c2g (d2_out)
  if (nargin != 1)
    print_usage;
  endif

  if ((!isfield (d2_out, "dim")) || (!isfield (d2_out, "c2")) ...
      || (!isfield (d2_out, "d2")) || (!isfield (d2_out, "h2")))
    error ('Octave:invalid-input-arg', "d2_out must be the output of d2");
  endif

  if (! exist ("__c2g__"))
    error ('Octave:tisean', ["__c2g__ was not found in path ",...
                             "- if package was installed properly the ",...
                             "compiler might not support C++11 standard"])
  endif

  # Create the cell that will become the 'g' field of the output
  g_out = cell (length (d2_out),1);

  # Calculate output for each struct in the input struct array
  for i = 1:size(d2_out,1)
    tmp     = d2_out(i);

    # Limit to only the first positive correlation sums
    # (do not calculate output for any past first negative sum)
    idx_lt0 = min (find (tmp.c2(:,2) <= 0));
    if (!isempty (idx_lt0))
      tmp.c2  = tmp.c2(1:idx_lt0-1,:);
    endif

    [s,idx] = sort (tmp.c2(:,1));
    emat    = log (tmp.c2(idx,1));
    cmat    = log (tmp.c2(idx,2));

    # Create column vectors instead of using loop
    k_id    = 1:length(tmp.c2)-1;
    f       = exp((emat(k_id+1).*cmat(k_id).-emat(k_id).*cmat(k_id+1))
              ./(emat(k_id+1).-emat(k_id)));
    d       = (cmat(k_id+1).-cmat(k_id))./(emat(k_id+1).-emat(k_id));
    a       = emat(k_id);
    b       = emat(k_id+1);

    # Create row vector instead of using loop
    h       = exp(emat).';

    # Create output
    # __c2g__ performs integration on the function func and funcd 
    # (depending on whether 'false' or 'true' is passed as the last argument)
    # from original TISEAN on vectors (matrices) of parameters
    g            = sum (__c2g__ (h, f, d, a, b, false));
    gd           = sum (__c2g__ (h, f, d, a, b, true));
    de           = emat(end);
    cgauss       = g ./ (h.^2) + exp (-exp (2.*de) ./ (2.*h.^2));
    cgd          = gd ./ (h.^4) + (2 + exp (2*de) ./ h.^2) ...
                   .* exp (-exp (2*de) ./ (2.*h.^2));

    g_out{i} = [h.', cgauss.', (-2+cgd./cgauss).'];
  endfor

  output = struct ("dim", {d2_out.dim}.', "g", g_out);

endfunction

%!demo
%! vals          = d2 (henon (5000), 'd', 1, 't', 50);
%! kernel        = c2g (vals);
%! do_plot_slope = @(x) semilogx (x{1}(:,1),x{1}(:,3),'r');
%! hold on
%! arrayfun (do_plot_slope, {kernel.g});
%! hold off
%! axis tight
%! xlabel ("Epsilon")
%! ylabel ("logarithmic derivative")
%! title ("Gaussian kernel");
%!###############################################################

%% test against the result obtain from program c2g of TISEAN 3.0.1
%!test
%! c2g_res = [0.00255674845539033 0.00262371218 1.56393838;0.00274151703342795 0.00291572767 1.46379328;0.00293963821604848 0.00321952766 1.37964845;0.00315207871608436 0.00353588979 1.30904245;0.00337987160310149 0.00386583689 1.2498455;0.00362412468530238 0.00421059737 1.20023394;0.00388602935709059 0.00457157521 1.1586616;0.00416686292737722 0.00495032407 1.12383032;0.00446798978373408 0.00534852408 1.09465814;0.00479088025167584 0.00576799177 1.07024431;0.00513710314407945 0.00621065963 1.04983807;0.00550834601745009 0.00667859521 1.03281331;0.00590642029419541 0.00717399921 1.01864672;0.00633325986564159 0.00769920321 1.00690293;0.00679094903171062 0.00825670082 0.997214317;0.00728171039372683 0.00884913001 0.989262819;0.00780794164165854 0.00947930664 0.982763529;0.00837219785898924 0.0101501858 0.977451086;0.00897723622620106 0.0108648958 0.973080397;0.00962599366903305 0.011626686 0.969439983];
%! val = d2 (henon (1000), 'd', 1, 't', 50, 'm', 5);
%! res = c2g (val);
%! assert (cell2mat ({res.g}.')(1:rows(c2g_res),:), c2g_res, -1e-5);

%% input validation
%!error <output> c2g (1)
