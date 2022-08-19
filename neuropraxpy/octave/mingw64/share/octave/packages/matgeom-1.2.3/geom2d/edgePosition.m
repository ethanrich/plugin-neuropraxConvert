## Copyright (C) 2021 David Legland
## All rights reserved.
## 
## Redistribution and use in source and binary forms, with or without
## modification, are permitted provided that the following conditions are met:
## 
##     1 Redistributions of source code must retain the above copyright notice,
##       this list of conditions and the following disclaimer.
##     2 Redistributions in binary form must reproduce the above copyright
##       notice, this list of conditions and the following disclaimer in the
##       documentation and/or other materials provided with the distribution.
## 
## THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS ''AS IS''
## AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
## IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
## ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE FOR
## ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
## DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
## SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
## CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
## OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
## OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
## 
## The views and conclusions contained in the software and documentation are
## those of the authors and should not be interpreted as representing official
## policies, either expressed or implied, of the copyright holders.

function pos = edgePosition(point, edge)
%EDGEPOSITION Return position of a point on an edge.
%
%   POS = edgePosition(POINT, EDGE);
%   Computes position of point POINT on the edge EDGE, relative to the
%   position of edge vertices.
%   EDGE has the form [x1 y1 x2 y2],
%   POINT has the form [x y], and is assumed to belong to edge.
%   The result POS has the following meaning:
%     POS < 0:      POINT is located before the first vertex
%     POS = 0:      POINT is located on the first vertex
%     0 < POS < 1:  POINT is located between the 2 vertices (on the edge)
%     POS = 1:      POINT is located on the second vertex
%     POS < 0:      POINT is located after the second vertex
%
%   POS = edgePosition(POINT, EDGES);
%   If EDGES is an array of NL edges, return NE positions, corresponding to
%   each edge.
%
%   POS = edgePosition(POINTS, EDGE);
%   If POINTS is an array of NP points, return NP positions, corresponding
%   to each point.
%
%   POS = edgePosition(POINTS, EDGES);
%   If POINTS is an array of NP points and EDGES is an array of NE edges,
%   return an array of [NP NE] position, corresponding to each couple
%   point-edge.
%
%   See also:
%   edges2d, createEdge, isPointOnEdge
%

% ------
% Author: David Legland
% e-mail: david.legland@nantes.inra.fr
% Created: 2004-05-25
% Copyright 2009 INRA - Cepia Software Platform.
%

%   HISTORY:
%   06/12/2009 created from linePosition

% number of points and of edges
nEdges = size(edge, 1);
nPoints = size(point, 1);

if nPoints == nEdges
    dxe = (edge(:, 3) - edge(:,1))';
    dye = (edge(:, 4) - edge(:,2))';
    dxp = point(:, 1) - edge(:, 1);
    dyp = point(:, 2) - edge(:, 2);

else
    % expand one of the arrays to have the same size
    dxe = (edge(:,3) - edge(:,1))';
    dye = (edge(:,4) - edge(:,2))';
    dxp = bsxfun(@minus, point(:,1), edge(:,1)');
    dyp = bsxfun(@minus, point(:,2), edge(:,2)');

end

pos = (dxp .* dxe + dyp .* dye) ./ (dxe .* dxe + dye .* dye);
