## Copyright (C) 2015-2019 - Juan Pablo Carbajal
##
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program. If not, see <http://www.gnu.org/licenses/>.

## Author: Juan Pablo Carbajal <ajuanpi+dev@gmail.com>
## Updated: 2019-05-14

## -*- texinfo -*-
## @deftypefn {} {[@var{pline2} @var{idx}] = } simplifyPolyline_geometry (@var{pline})
## @deftypefnx {} {@dots{} = } simplifyPolyline_geometry (@dots{},@var{property},@var{value},@dots{})
## Simplify or subsample a polyline using the Ramer-Douglas-Peucker algorithm,
## a.k.a. the iterative end-point fit algorithm or the split-and-merge algorithm.
##
## The @var{pline} as a N-by-2 matrix. Rows correspond to the
## verices (compatible with @code{polygons2d}). The vector @var{idx} constains
## the indexes on vetices in @var{pline} that generates @var{pline2}, i.e.
## @code{pline2 = pline(idx,:)}.
##
## @strong{Parameters}
## @table @samp
## @item 'Nmax'
## Maximum number of vertices. Default value @code{1e3}.
## @item 'Tol'
## Tolerance for the error criteria. Default value @code{1e-4}.
## @item 'MaxIter'
## Maximum number of iterations. Default value @code{10}.
## @item 'Method'
## Not implemented.
## @end table
##
## Run @code{demo simplifyPolyline_geometry} to see an example.
##
## @seealso{curve2polyline, curveval, simplifyPolygon_geometry}
## @end deftypefn

function [pline idx] = simplifyPolyline_geometry (pline_o, varargin)
## TODO do not print warnings if user provided Nmax or MaxIter.

  # --- Parse arguments --- #
  parser              = inputParser ();
  parser.FunctionName = "simplifyPolyline_geometry";
  toldef              = 1e-4;#max(sumsq(diff(pline_o),2))*2;
  parser.addParamValue ('Tol', toldef, @(x)x>0);
  parser.addParamValue ('Nmax', 1e3, @(x)x>0);
  parser.addParamValue ('MaxIter', 100, @(x)x>0);
  parser.parse(varargin{:});

  Nmax      = parser.Results.Nmax;
  tol       = parser.Results.Tol;
  MaxIter   = parser.Results.MaxIter;

  clear parser toldef
  msg = ["simplifyPolyline_geometry: Maximum number of points reached with maximum error %g." ...
       " Increase %s if the result is not satisfactory."];
  # ------ #

  [N dim] = size (pline_o);
  idx     = [1 N];

  for iter = 1:MaxIter
    # Find the point with the maximum distance.
    [dist ii] = maxdistance (pline_o, idx);

    tf = dist > tol;
    n  = sum (tf);
    if ( all (!tf) );
      break;
    end

    idx(end+1:end+n) = ii(tf);
    idx              = sort (idx);

    if length(idx) >= Nmax
      ## TODO remove extra points
      warning ('geometry:MayBeWrongOutput', sprintf (msg, max (dist),'Nmax'));
      break;
    end

  end
  if iter == MaxIter
    warning ('geometry:MayBeWrongOutput', sprintf (msg ,max (dist), 'MaxIter'));
  end

  pline = pline_o(idx,:);
endfunction

function [dist ii] = maxdistance (p, idx)

  ## Separate the groups of points according to the edge they can divide.
  idxc   = arrayfun (@colon, idx(1:end-1), idx(2:end), "UniformOutput",false);
  points = cellfun (@(x)p(x,:), idxc, "UniformOutput",false);

  ## Build the edges
  edges = [p(idx(1:end-1),:) p(idx(2:end),:)];
  edges = mat2cell (edges, ones (1,size (edges,1)), 4)';

  ## Calculate distance between the points and the corresponding edge
  [dist ii] = cellfun (@dd, points, edges, idxc);

endfunction

function [dist ii] = dd (p,e,idx)
  [d pos]   = distancePointEdge (p, e);
  [dist ii] = max (d);
  ii        = idx(ii);
endfunction

%!demo
%! t     = linspace(0,1,100).';
%! y     = polyval([1 -1.5 0.5 0],t);
%! pline = [t y];
%!
%! figure(1)
%! clf
%! plot (t,y,'-r;Original;','linewidth',2);
%! hold on
%!
%! tol    = [8 2  1 0.5]*1e-2;
%! colors = jet(4);
%!
%! for i=1:4
%!   pline_ = simplifyPolyline_geometry(pline,'tol',tol(i));
%!   msg = sprintf('-;%g;',tol(i));
%!   h = plot (pline_(:,1),pline_(:,2),msg);
%!   set(h,'color',colors(i,:),'linewidth',2,'markersize',4);
%! end
%! hold off
%!
%! # ---------------------------------------------------------
%! # Four approximations of the initial polyline with decreasing tolerances.

%!demo
%! P       = [0 0; 3 1; 3 4; 1 3; 2 2; 1 1];
%! func    = @(x,y) linspace(x,y,5);
%! P2(:,1) = cell2mat( ...
%!             arrayfun (func, P(1:end-1,1),P(2:end,1), ...
%!             'uniformoutput',false))'(:);
%! P2(:,2) = cell2mat( ...
%!             arrayfun (func, P(1:end-1,2),P(2:end,2), ...
%!             'uniformoutput',false))'(:);
%!
%! P2s = simplifyPolyline_geometry (P2);
%!
%! plot(P(:,1),P(:,2),'s',P2(:,1),P2(:,2),'o',P2s(:,1),P2s(:,2),'-ok');
%!
%! # ---------------------------------------------------------
%! # Simplification of a polyline in the plane.
