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

function [nodePath, edgePath] = grShortestPath(nodes, edges, ind0, ind1, edgeWeights)
%GRSHORTESTPATH Find a shortest path between two nodes in the graph.
%
%   PATH = grShortestPath(NODES, EDGES, NODE1, NODE2, WEIGHTS)
%   NODES and EDGES defines the graph, NODE1 and NODE2 are indices of the
%   node extremities, and WEIGHTS is the set of weights associated to each
%   edge.
%   The function returns a set of node indices.
%
%   PATH = grShortestPath(NODES, EDGES, NODEINDS, WEIGHTS)
%   Specifies two or more points that must be traversed by the path, in the
%   specified order.
%
%   % Create a simple tree graph, and compute shortest path
%     [x y] = meshgrid([10 20 30], [10 20 30]);
%     nodes = [x(:) y(:)];
%     edges = [1 2;2 3;2 5;3 6; 4 5;4 7;5 8; 8 9];
%     drawGraph(nodes, edges)
%     axis equal; axis([0 40 0 40]);
%     drawNodeLabels(nodes, 1:9)
%     path = grShortestPath(nodes, edges, 1, 9);
%     % same as:
%     path = grShortestPath(nodes, edges, [1 9]);
%
%   See also
%     graphs, grFindMaximalLengthPath
%

% ------
% Author: David Legland
% e-mail: david.legland@inra.fr
% Created: 2011-05-22,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2011 INRA - Cepia Software Platform.

% process the case where several node indices are specified in first arg.
if length(ind0) > 1
    % following optional argument is edge values
    if exist('ind1', 'var')
        edgeWeights = ind1;
    else
        edgeWeights = ones(size(edges, 1), 1);
    end
    
    % concatenate path pieces
    nodePath = ind0(1);
    edgePath = size(0, 2);
    for i = 2:length(ind0)
        [node0, edge0] = grShortestPath(nodes, edges, ind0(i-1), ind0(i), edgeWeights);
        nodePath = [nodePath ; node0(2:end)]; %#ok<AGROW>
        edgePath = [edgePath ; edge0]; %#ok<AGROW>
    end
    
    return;
end

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


%% Initialisations

% consider infinite distance for all nodes
dists = inf * ones(nNodes, 1);

% initial node is at distance 0 by definition
dists(ind0) = 0;

% create an array of indices for the predessor of each node
preds = zeros(nNodes, 1);
preds(ind0) = 0;

% allocate memory to store the subgraph, which is a tree
edges2 = zeros(nNodes-1, 2);

% create an array of node flags
unprocessedNodeInds = 1:nNodes;

edgeCount = 0;


%% Iterate until all nodes are flagged to 1

while ~isempty(unprocessedNodeInds)
    % choose unprocessed node with lowest distance
    [tmp, ind] = min(dists(unprocessedNodeInds)); %#ok<ASGLU>
    ind = unprocessedNodeInds(ind);
    ind = ind(1);

    % mark current node as processed
    unprocessedNodeInds(unprocessedNodeInds == ind) = [];
    
    % if the current node is the target, it is not necessary to continue...
    if ind == ind1
        break;
    end
    
    % find the index list of edges incident to current node 
    adjEdgeInds = grAdjacentEdges(edges, ind);
    
    % select edges whose opposite node has not yet been processed
    inds2 = sum(ismember(edges(adjEdgeInds, :), unprocessedNodeInds), 2) > 0;
    adjEdgeInds = adjEdgeInds(inds2);
    
    % iterate over incident edges to update adjacent nodes
    for iNeigh = 1:length(adjEdgeInds)
        % extract index of current adjacent node
        edge = edges(adjEdgeInds(iNeigh), :);
        adjNodeInd = edge(~ismember(edge, ind));
        
        newDist = dists(ind) + edgeWeights(adjEdgeInds(iNeigh));
%         dists(adjNodeInd) = min(dists(adjNodeInd), newDist);
        if newDist < dists(adjNodeInd)
            dists(adjNodeInd) = newDist;
            preds(adjNodeInd) = ind;
        end
    end

    % find the list of adjacent nodes
    adjNodeInds = unique(edges(adjEdgeInds, :));
    adjNodeInds(adjNodeInds == ind) = [];
    
    % choose the adjacent nodes with lowest distance, and add the
    % corresponding edges to the subgraph 
    if ~isempty(adjNodeInds)
        minDist = min(dists(adjNodeInds));
        closestNodeInds = adjNodeInds(dists(adjNodeInds) <= minDist);
        for iCloseNode = 1:length(closestNodeInds)
            edgeCount = edgeCount + 1;
            edges2(edgeCount, :) = [ind closestNodeInds(iCloseNode)];
        end
    end
end


%% Path creation

% create the path: start from end index, and identify successive set of
% neighbor edges and nodes

nodeInd = ind1;
nodePath = nodeInd;
edgePath = [];

% find predecessors until we reach ind0 node
while nodeInd ~= ind0
    newNodeInd = preds(nodeInd);
    nodePath = [nodePath ; newNodeInd]; %#ok<AGROW>

    % search the edge (both directions) in the list of edges
    e_tmp                 = [nodeInd newNodeInd];
    [~,edgeInd]           = ismember ([e_tmp; e_tmp(end:-1:1)], edges, 'rows');
    edgeInd(edgeInd == 0) = []; % erase the one that isn't there
    edgePath = [edgePath ; edgeInd]; %#ok<AGROW>

    nodeInd = newNodeInd;
end
    
% reverse the path
nodePath = nodePath(end:-1:1);
edgePath = edgePath(end:-1:1);

