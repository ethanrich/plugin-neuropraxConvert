## Copyright (C) 2015-2017 Philip Nienhuis
## Copyright (C) 2016 - Juan Pablo Carbajal
##
## This program is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program.  If not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {} { @var{XYo} =} polygon2patch (@var{XYi})
## @deftypefnx {} [@var{Xo}, @var{Yo} ] = polygon2patch (@var{Xi}, @var{Yi})
## @deftypefnx {} [@var{Xo}, @var{Yo}, @var{Zo} ] = polygon2patch (@var{Xi}, @var{Yi}, @var{Zi})
## Connect outer (filled) polygon and inner (hole) polygons using branch cuts
## such that all polygons are connected as one string of vertices, for
## subsequent plotting polygons with holes using the function @command{patch}.
##
## @var{XYi} can be a 2 or 3 dimensional array; only the X and Y coordinates
## will be optmized and Z-values will be kept with their original vertices.
## Alternatively separate X, Y and optionally Z-vectors can be specified.
## The outer polygon should appear as a first subvector, bounded by a row of
## NaN values, and have a counterclockwise winding direction.  All subsequent
## inner hole polygons should also be bounded by rows of NaN values and have
## clockwise winding directions.
##
## This function expects and returns column vectors or matrices where
## each row contains coordinates of a vertex.
##
## @seealso{drawPolygon, patch}
## @end deftypefn

## Author: Philip Nienhuis <prnienhuis@users.sf.net>
## Created: 2016-04-30

function [X, Y, Z] = polygon2patch (XX, YY=[], ZZ=[]);

  matinp = 0;
  XYsz = size (XX, 2);
  ## Check args
  if (nargin == 1)
    if (ismatrix (XX) && XYsz >= 2)
      ## apparently matrix input rather than two separate X,Y[,Z] vectors
      matinp = 1;
      XY     = XX;
    endif
  elseif (nargin >= 2)
    ## Separate vector input
    XY = [XX YY ZZ];
  elseif (nargin < 1)
    error ("Octave:invalid-input-arg", ...
           "polygon2patch: not enough input arguments");
  endif

  ## Also keep track of Z.
  ## Z isn't (yet) in the branch cut optimization 
  ## (but that could be done easily)
  if (isempty (ZZ) || XYsz == 2)
    ## At least provide pointers where Z coordinates have gone 
    ## in output arrays
    ZZ = [1:size(XY, 1)]';
    XY = [ XY ZZ ];
  endif
  Z = [];

  ## Find NAN separators
  idx = find (isnan (XY(:, 1)));
  if (isempty (idx))
    ## No NaN separators => no subfeatures. Return
    if (!matinp)
      X = XX; Y = YY;
      if (nargin == 3)
        Z = ZZ;
      endif
    else
      X = XX;
      Y = [];
    endif
    return
  endif
  ipt = [0; idx; numel(XY(:, 1))+1];

  for ii=1:numel (ipt) - 1

    ## Check for closed polygon
    if (any (abs (XY(ipt(ii)+1, 1:2) - XY(ipt(ii+1)-1, 1:2)) > eps))
      ## Duplicate first vertex as last vertex of subpolygon
      ## First shift all subpolys down
      XY(ipt(ii+1)+1:end+1, :) = XY(ipt(ii+1):end, :);
      ipt(ii+1:end)           += 1;
      XY(ipt(ii+1)-1, :)       = XY(ipt(ii)+1, :);
    endif

    XY(ipt(ii)+1:ipt(ii+1)-1, 4) = [ ipt(ii)+1:ipt(ii+1)-1 ]';
  endfor

  ## Compute all interdistances
  XY(ipt(2:end-1), :) = [];
  dists = distancePoints (XY(:, 1:2), XY(:, 1:2));
  szdst = size (dists);
  dists = dists + tril (Inf (szdst(1)));
  X_Y   = XY(1:ipt(2)-1, :);

  ## Keep track of which holes are still unconnected
  processed = [0 (ones (1, numel (ipt) - 2))];
  tt        = cumsum (diff (ipt) - 1);
  idx       = [tt(1:end-1)+1 tt(2:end)];
  odx       = 1:(ipt(2) - 1);
  ody       = 1:size (dists, 2);

  ## Find hole polygon with smallest distance to an outer vertex; afterwards
  ## assign that to outer vertex + restart search until all holes are processed.
  ## FIXME Although Octave doesn't draw the branch cuts, it may be better to
  ##       also check that branch cuts do not cross polygons between two
  ##       vertices belonging to other polygons (or self-intersect polygons)
  while (any (processed))
    ## Get slice of dists with outer vertices + vertices connected to it, excl.
    ## columns already processed
    odz       = setdiff (ody, odx);
    [~, indx] = min (dists(odx, odz)(:));
    ## Get subscripts into sliced dists matrix
    [r, c] = ind2sub ([numel(odx),numel(odz)], indx);
    ## Recompute subscripts into full dists matrix
    rr = odx(r);             ## Needed to insert new hole into place
    cc = odz(c);             ## To rotate hole such that this vertex has
                             ## smallest distance to outer polygon vertex
    ## Find hole polygon corresponding to these subscripts
    ii    = find (cc >= idx(:, 1) & cc < idx(:, 2));
    shft  = idx(ii, 1) - cc;
    tmpXY = XY(idx(ii, 1):idx(ii, 2), :);
    if (shft)
      tmpXY(1:end-1, :) = circshift (tmpXY(1:end-1, :), [shft, 0]);
      ## tmpXY is always shifted upward here. Copy toprow coordinates to bottom
      tmpXY(end, :) = tmpXY(1, :);
    endif
    X_Y = [X_Y(1:r, :); tmpXY; X_Y(r:end, :)];
    odx = [odx idx(ii, 1):idx(ii, 2)];

    processed(ii+1) = 0;

  endwhile

  if (!matinp)
    X = X_Y(:, 1);
    Y = X_Y(:, 2);
    if (nargin == 3)
      Z = X_Y(:, 3);
    endif
  else
    X = X_Y(:, 1:XYsz);
    Y = [];
  endif

endfunction

%!demo
%! figure()
%! p  = [0 0; 0 1; 1 1; 1 0]; %ccw
%! pp = [0 0; 1 0; 1 1; 0 1]; %cw
%! ph = p + [1.2 0];
%! # add hole
%! ph(end+1,:) = nan;
%! ph          = [ph; (pp-[0.5 0.5])*0.5+[1.7 0.5]];
%! po = polygon2patch (ph);
%! patch (po(:,1), po(:,2), 'b', 'facecolor', 'c');
%! axis image

%!demo
%! holes = [0 0; 35 0; 35 25; 0 25; 0 0; NaN NaN; 7 1; 2 1; 3 5; 6 6; 7 1; ...
%! NaN NaN; 9 2; 8 5; 18 7; 28 5; 30 2; 9 2; NaN NaN; 19 11; 18 14; 21 13; ...
%! 19 11; NaN NaN; 24 24; 34 24; 34 6; 24 24; NaN NaN; 9 6; 7 14; 9 18; 9 6; ...
%! NaN NaN; 27 6; 27 12; 31 9; 27 6; NaN NaN; 2 24; 23 24; 22 21; 23 19; ...
%! 1 23; 2 24; NaN NaN; 18 8; 26 13; 26 7; 18 8; NaN NaN; 8 18; 6 14; 8 7; ...
%! 2 9; 1 18; 5 19; 8 18; NaN NaN; 13 16; 17 8; 10 6; 13 16; NaN NaN; 34 1; ...
%! 28 6; 31 8; 34 1; NaN NaN; 9 20; 26 17; 31 10; 24 15; 8 19; 9 20];
%! subplot (2, 2, 1);
%! p1 = plot (holes(:, 1), holes(:, 2), 'b'); box off; axis off
%! title ("Plot of array 'holes'");
%! subplot (2, 2, 2);
%! p2 = patch (holes(:, 1), holes(:, 2), 'b', 'facecolor', 'c'); box off; axis off
%! title ("Patch of array 'holes'\nbefore processing");
%! subplot (2, 2, 3);
%! pt = polygon2patch (holes);
%! p3 = plot (pt(:, 1), pt(:, 2), 'b'); box off; axis off
%! title ("Plot of array 'holes'\nafter polygon2patch");
%! subplot (2, 2, 4);
%! p4 = patch (pt(:, 1), pt(:, 2), 'b', 'facecolor', 'c'); box off; axis off
%! title ("Patch of array 'holes'\nafter polygon2patch");
