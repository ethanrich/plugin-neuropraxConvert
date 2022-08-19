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

function path = grFindGeodesicPath(nodes, edges, ind0, ind1, edgeWeights)
%GRFINDGEODESICPATH Find a geodesic path between two nodes in the graph.
%
%   PATH = grFindGeodesicPath(NODES, EDGES, NODE1, NODE2, WEIGHTS)
%   NODES and EDGES defines the graph, NODE1 and NODE2 are indices of the
%   node extremities, and WEIGHTS is the set of weights associated to each
%   edge.
%   The function returns a set of edge indices.
%
%
%   See also
%   grFindMaximalLengthPath
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

% check indices limits
nNodes = size(nodes, 1);
if max(ind0) > nNodes
    error('Start index exceed number of nodes in the graph');
end
if max(ind1) > nNodes
    error('End index exceed number of nodes in the graph');
end

% find a vertex opposite to the first extremity
dists = grPropagateDistance(nodes, edges, ind0, edgeWeights);

% iterate on neighbors of current node: choose next neighbor with smallest
% cumulated weight, until we are back on source node
path = [];
while true
    % find neighbor with lowest cumulated distance
    neighs = grAdjacentNodes(edges, ind1);
    neighDists = dists(neighs);
    indN = find(neighDists == min(neighDists), 1);
    ind2 = neighs(indN);

    if isempty(ind2)
        warning('graphs:grFindGeodesicPath', ...
            'No neighbor node found for node %d, graph may be not connected', ind1);
        break;
    end

    % add edge index to the path
    indE = find(sum(ismember(edges, [ind1 ind2]), 2) == 2, 1);
    path = [path indE]; %#ok<AGROW>
    
    % test if path is finished or not
    if ind2 == ind0
        break;
    end
    ind1 = ind2;
end

% reverse path direction
path = path(end:-1:1);
