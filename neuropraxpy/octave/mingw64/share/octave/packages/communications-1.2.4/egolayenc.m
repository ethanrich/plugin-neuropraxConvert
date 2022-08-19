## Copyright (C) 2007 Muthiah Annamalai <muthiah.annamalai@uta.edu>
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
## @deftypefn {Function File} {@var{C} =} egolayenc (@var{M})
## Encode with Extended Golay code.
##
## The message @var{M}, needs to be of size Nx12, for encoding.
## We can encode several messages, into codes at once, if they
## are stacked in the order suggested.
##
## The generator used in here is same as obtained from the
## function @code{egolaygen}. Extended Golay code (24,12) which can correct
## up to 3 errors.
##
## @example
## @group
## msg = rand (10, 12) > 0.5;
## c = egolayenc (msg)
## @end group
## @end example
##
## @seealso{egolaygen, egolaydec}
## @end deftypefn

function C = egolayenc (M)

  if (nargin != 1)
    print_usage ();
  elseif (columns (M) != 12)
    error ("egolayenc: M must be a matrix with 12 columns");
  endif

  G = egolaygen (); # generator

  C = mod (M * G, 2);

endfunction

%% Test input validation
%!error egolayenc ()
%!error egolayenc (1)
%!error egolayenc (1, 2)

%%test encryption-decryption and robustness to error
%!test
%! x = [1   1   0   0   1   1   0   0   0   0   1   0;  1   1   1   0   1   1   1   0   0   0   1   1];
%! y = egolayenc (x);
%! err = zeros(2, 24);
%! err(1, [4 10 12]) = 1; #should be able to correct any 3 errors per column
%! err(2, [2 3 13]) = 1;
%! y1 = xor (y, err);
%! [xb, err0] = egolaydec (y);
%! [x1, err1] = egolaydec (y1);
%! assert (y, [1   1   1   0   0   0   1   1   0   0   1   1   1   1   0   0   1   1   0   0   0   0   1   0;   1   0   0   1   0   0   1   1   1   1   1   1   1   1   1   0   1   1   1   0   0   0   1   1])
%! assert (xb(:, 13:24), x) 
%! assert (x1(:, 13:24), x)
%! assert (err0, [0; 0]) 
%! assert (err1, [0; 0]) 
