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

function [nodes2, edges2] = grRemoveNodes(nodes, edges, rmNodes)
%GRREMOVENODES Remove several nodes in a graph.
%
%   usage:
%   [NODES2 EDGES2] = grRemoveNodes(NODES, EDGES, NODES2REMOVE)
%   remove the nodes with indices NODE2REMOVE from array NODES, and also
%   remove edges containing the nodes NODE2REMOVE.
%
%   Example
%     nodes = [...
%         10 10; 20 10; 30 10; ...
%         10 20; 20 20; 30 20];
%     edges = [...
%         1 2; 1 4; 1 5; ...
%         2 3; 2 5; 2 6; ...
%         3 6; 4 5; 5 6];
%     toRemove = [3 4];
%     [nodes2 edges2] = grRemoveNodes(nodes, edges, toRemove);
%     drawGraph(nodes2, edges2);
%     axis equal; axis([0 40 0 30]);
%
%   See also
%     grRemoveEdges
%

%   -----
%   author: David Legland 
%   INRA - TPV URPOI - BIA IMASTE
%   created the 13/08/2003.
%

%   HISTORY
%   10/02/2004 doc
%   07/03/2014 rewrite using clearer algorithm


%% edges processing

% remove all edges connected to one of the nodes to remove
edges2 = edges(~any(ismember(edges, rmNodes), 2), :);

% change edges information, due to the node index shift
for i = 1:length(rmNodes)
    inds = edges2 > (rmNodes(i) - i + 1);
    edges2(inds) = edges2(inds) - 1;
end


%% nodes processing

% number of nodes
N   = size(nodes, 1);
NR  = length(rmNodes);
N2  = N-NR;

% allocate memory
nodes2 = zeros(N2, 2);

% process the first node
nodes2(1:rmNodes(1)-1,:) = nodes(1:rmNodes(1)-1,:);

for i = 2:NR
    inds = rmNodes(i-1)+1:rmNodes(i)-1;
    if isempty(inds)
        continue;
    end
    nodes2(inds - i + 1, :) = nodes(inds, :);
end

% process the last node
nodes2(rmNodes(NR)-NR+1:N2, :) = nodes(rmNodes(NR)+1:N, :);
