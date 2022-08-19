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

function [nodes2, edges2] = grMergeNodeClusters(nodes, edges)
%GRMERGENODECLUSTERS Merge cluster of connected nodes in a graph.
%
%   grMergeNodeClusters(nodes, edges)
%   Detects groups of nodes that belongs to the same global node, and
%   replace them by a unique node. Coordinates of reference node is given
%   by the median coordinates of cluster nodes.
%
%   This function is intended to be used as filter after a binary image
%   skeletonization and vectorization.
%
%
%   See Also
%   grMergeNodesMedian
%

%   -----
%   author : David Legland 
%   INRA - TPV URPOI - BIA IMASTE
%   created the 13/08/2003.
%

%   HISTORY


%% Initialization

% intialize result 
nodes2 = nodes;
edges2 = edges;

% compute degree of each node
degrees = grNodeDegree(1:size(nodes, 1), edges)';

% find index of multiple nodes
indMul = find(degrees > 2);

% indices of edges that link several multiple nodes
indEdges = sum(ismember(edges, indMul), 2) == 2;

% associate a label to each cluster
labels = grLabel(nodes, edges(indEdges, :));
clusterLabels = unique(labels(indMul));


%% Replace each cluster by median point

% iterate on clusters
for i = 1:length(clusterLabels)
    % indices of nodes of the current cluster
    inds = find(labels == clusterLabels(i));
    
    % coordinates of new reference node
    clusterNodes = nodes(inds, :);
    medianNode = median(clusterNodes, 1);
    
    % replace coordinates of reference node
    refNode = min(inds);
    nodes2(refNode, :) = medianNode;
    
    % replace node indices in edge array
    edges2(ismember(edges2, inds)) = refNode;
end


%% Clean up

% keep only relevant nodes
inds = unique(edges2(:));
nodes2 = nodes2(inds, :);

% relabeling of edges
for i = 1:length(inds)
    edges2(edges2 == inds(i)) = i;
end

% remove double edges
edges2 = unique(sort(edges2, 2), 'rows');

% remove 'loops'
edges2(edges2(:,1) == edges2(:,2), :) = [];
