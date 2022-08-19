## Copyright (C) 2012-2019 (C) Juan Pablo Carbajal
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

## Author: Juan Pablo Carbajal <ajuanpi+dev@gmail.com>

## -*- texinfo -*-
## @defun {} {@var{h} = } plotShape (@var{shape})
## @defunx {} {@var{h} = } plotShape (@dots{}, @asis{'tol'}, @var{value})
## @defunx {} {@var{h} = } plotShape (@dots{}, @var{prop}, @var{value})
## Plots a 2D shape defined by piecewise smooth polynomials in the current axis.
##
## @var{shape} is a cell where each elements is a 2-by-(poly_degree+1) matrix
## containing a pair of polynomials.
##
## The property @asis{'Tol'} sets the tolerance for the quality
## of the polygon as explained in @command{shape2polygon}.
## Additional property value pairs are passed to @code{drawPolygon}.
##
## @seealso{drawPolygon, shape2polygon, polygon2shape}
## @end defun

function h = plotShape(shape, varargin)

  # Parse arguments
  # consume tolerance option
  # use last one given, erase all
  tol = 1e-4;
  if ~isempty (varargin)
    istol = cellfun (@(x)strcmp (tolower (x), 'tol'), varargin);
    if any (istol)
      idx                   = find (istol);
      # use last
      tol                   = varargin{idx(end) + 1};
      # erase all
      varargin([idx(:); idx(:)+1]) = [];
    endif
  endif

  # Estimate step for discretization using random samples to get area range
  pts     = cell2mat (cellfun (@(x)curveval (x, rand (1, 11)), shape, 'unif', 0));
  bb      = boundingBox (pts);
  mxrange = ( (bb(2) - bb(1)) * (bb(4) - bb(3)) ) * 0.5;
  dr      = tol * mxrange;

  p  = shape2polygon (shape, 'tol', dr);
  h  = drawPolygon (p, varargin{:});

endfunction

%!demo
%! # Taylor series of cos(pi*x),sin(pi*x)
%! n = 5; N = 0:5;
%! s{1}(1,2:2:2*n+2) = fliplr ( (-1).^N .* (pi).^(2*N) ./ factorial (2*N));
%! s{1}(2,1:2:2*n+1) = fliplr ( (-1).^N .* (pi).^(2*N+1) ./ factorial (2*N+1));
%!
%! h(1) = plotShape (s, 'tol', 1e-1, 'color','b');
%! h(2) = plotShape (s, 'tol', 1e-3, 'color', 'm');
%! h(3) = plotShape (s, 'tol', 1e-9, 'color', 'g');
%! legend (h, {'1e-1','1e-3','1e-9'})
%! axis image

%!shared s
%! s = {[0.1 1; 1 0]};

%!test
%! plotShape (s); close;
%!test
%! plotShape (s,'tol', 1e-4);close;
%!test
%! plotShape (s,'color', 'm', 'tol', 1e-4);close;
%!test
%! plotShape (s,'color', 'm', 'linewidth', 2, 'tol', 1e-4);close;
%!test
%! plotShape (s,'color', 'm', 'tol', 1e-4, 'linewidth', 2);close;
%!test
%! plotShape (s,'-om', 'tol', 1e-4, 'linewidth', 2);close;
%! plotShape (s,'tol', 1e-4, '-om', 'linewidth', 2);close;
%! plotShape (s,'-om', 'linewidth', 2, 'tol', 1e-4);close;
%!test
%! plotShape (s,'-om', 'tol', 1e-4, 'tol', 1e-2);close;
