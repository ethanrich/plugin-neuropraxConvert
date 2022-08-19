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

function path = grFindMaximalLengthPath(nodes, edges, edgeWeights)
%GRFINDMAXIMALLENGTHPATH Find a path that maximizes sum of edge weights.
%
%   PATH = grFindMaximalLengthPath(NODES, EDGES, EDGE_WEIGHTS);
%   Finds a greatest geodesic path in the graph. A path between two nodes
%   is a succession of adjacent edges that link the first and last nodes.
%   the length of the path is the sum of weights of edges that constitute
%   the path.
%   A geodesic path is a path that minimizes the length of the path among
%   the set of paths between the nodes.
%   A maximal length path maximizes the length of the geodesic path between
%   couples of nodes in the graph
%
%   The result PATH is the list of edge indices that constitutes the path.
%
%   PATH = grFindMaximalLengthPath(NODES, EDGES);
%   Assumes each edge has a weight equal to 1.
%
%   See Also
%   grFindGeodesicPath
%
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2011-05-22,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2011 INRA - Cepia Software Platform.

% ensure weights are defined
if ~exist('edgeWeights', 'var')
    edgeWeights = ones(size(edges, 1), 1);
end

% find an extremity vertex
inds = graphPeripheralVertices(nodes, edges, edgeWeights);
ind0 = inds(end);

% find a vertex opposite to the first extremity
dists = grPropagateDistance(nodes, edges, ind0, edgeWeights);
ind1 = find(dists == max(dists), 1, 'first');

% iterate on neighbors of current node: choose next neighbor with smallest
% cumulated weight, until we are back on source node
path = [];
while true
    % find neighbor with lowest cumulated distance
    neighs = grAdjacentNodes(edges, ind1);
    neighDists = dists(neighs);
    indN = find(neighDists == min(neighDists), 1);
    ind2 = neighs(indN);
    
    % add edge index to the path
    indE = find(sum(ismember(edges, [ind1 ind2]), 2) == 2, 1);
    path = [path indE]; %#ok<AGROW>
    
    % test if path is finished or not
    if ind2 == ind0
        break;
    end
    ind1 = ind2;
end
