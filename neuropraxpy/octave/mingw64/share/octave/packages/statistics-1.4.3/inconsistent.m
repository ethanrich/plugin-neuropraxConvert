## Copyright (C) 2020-2021 Stefano Guidoni <ilguido@users.sf.net>
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
## @deftypefn {Function File} {@var{Y} =} inconsistent (@var{Z})
## @deftypefnx {Function File} {@var{Y} =} inconsistent (@var{Z}, @var{d})
##
## Compute the inconsistency coefficient for each link of a hierarchical cluster
## tree.
##
## Given a hierarchical cluster tree @var{Z} generated by the @code{linkage}
## function, @code{inconsistent} computes the inconsistency coefficient for each
## link of the tree, using all the links down to the @var{d}-th level below that
## link.
##
## The default depth @var{d} is 2, which means that only two levels are
## considered: the level of the computed link and the level below that.
##
## Each row of @var{Y} corresponds to the row of same index of @var{Z}.
## The columns of @var{Y} are respectively: the mean of the heights of the links
## used for the calculation, the standard deviation of the heights of those
## links, the number of links used, the inconsistency coefficient.
##
## @strong{Reference}
## Jain, A., and R. Dubes. Algorithms for Clustering Data.
## Upper Saddle River, NJ: Prentice-Hall, 1988.
## @end deftypefn
##
## @seealso{cluster, clusterdata, dendrogram, linkage, pdist, squareform}

## Author: Stefano Guidoni <ilguido@users.sf.net>

function Y = inconsistent (Z, d = 2)

  ## check the input
  if (nargin < 1) || (nargin > 2)
    print_usage ();
  endif

  ## MATLAB compatibility:
  ## when d = 0, which does not make sense, the result of inconsistent is the
  ## same as d = 1, which is... inconsistent
  if ((d < 0) || (! isscalar (d)) || (mod (d, 1)))
    error ("inconsistent: d must be a positive integer scalar");
  endif

  if ((columns (Z) != 3) || (! isnumeric (Z)) || ...
      (! (max (Z(end, 1:2)) == rows (Z) * 2)))
    error (["inconsistent: Z must be a matrix generated by the linkage " ...
           "function"]);
  endif

  ## number of observations
  n = rows (Z) + 1;

  ## compute the inconsistency coefficient for every link
  for i = 1:rows (Z)
    v = inconsistent_recursion (i, d); # nested recursive function - see below

    Y(i, 1) = mean (v);
    Y(i, 2) = std (v);
    Y(i, 3) = length (v);
    ## the inconsistency coefficient is (current_link_height - mean) / std;
    ## if the standard deviation is zero, it is zero by definition
    if (Y(i, 2) != 0)
      Y(i, 4) = (v(end) - Y(i, 1)) / Y(i, 2);
    else
      Y(i, 4) = 0;
    endif
  endfor

  ## recursive function
  ## while depth > 1 search the links (columns 1 and 2 of Z) below the current
  ## link and then append the height of the current link to the vector v.
  ## The height of the starting link should be the last one of the vector.
  function v = inconsistent_recursion (index, depth)
    v = [];
    if (depth > 1)
      for j = 1:2
        if (Z(index, j) > n)
          new_index = Z(index, j) - n;
          v = [v (inconsistent_recursion (new_index, depth - 1))];
        endif
      endfor
    endif
    v(end+1) = Z(index, 3);
  endfunction

endfunction


## Test input validation
%!error inconsistent ()
%!error inconsistent ([1 2 1], 2, 3)
%!error <Z must be .* generated by the linkage .*> inconsistent (ones (2, 2))
%!error <d must be a positive integer scalar> inconsistent ([1 2 1], -1)
%!error <d must be a positive integer scalar> inconsistent ([1 2 1], 1.3)
%!error <d must be a positive integer scalar> inconsistent ([1 2 1], [1 1])
%!error <Z must be .* generated by the linkage .*> inconsistent (ones (2, 3))

## Test output
%!test
%! load fisheriris;
%! Z = linkage(meas, 'average', 'chebychev');
%! assert (cond (inconsistent (Z)), 39.9, 1e-3);

