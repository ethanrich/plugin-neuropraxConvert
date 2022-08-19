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

function [nodes2, edges2] = grRemoveNode(nodes, edges, node)
%GRREMOVENODE Remove a node in a graph.
% 
%   usage:
%   [NODES2 EDGES2] = grRemoveNode(NODES, EDGES, NODE2REMOVE)
%   remove the node with index NODE2REMOVE from array NODES, and also
%   remove edges containing the node NODE2REMOVE.
%
%   -----
%
%   author : David Legland 
%   INRA - TPV URPOI - BIA IMASTE
%   created the 13/08/2003.
%

%   HISTORY
%   10/02/2004: doc


% remove all edges connected to the node 
neighbours = grAdjacentEdges(edges, node);
[nodes2, edges2] = grRemoveEdges(nodes, edges, neighbours); %#ok<ASGLU>


% change edges information, due to the node index shift
for i = 1:length(edges2)
    if edges2(i,1) > node
        edges2(i,1) = edges2(i,1) - 1;
    end
    if edges2(i,2) > node
        edges2(i,2) = edges2(i,2) - 1;
    end
end

% allocate memory
dim = size(nodes);
nodes2 = zeros(dim(1)-1, 2);

% copy nodes information, except the undesired node
nodes2(1:node-1, :) = nodes(1:node-1, :);
nodes2(node:dim(1)-1, :) = nodes(node+1:dim(1), :);
