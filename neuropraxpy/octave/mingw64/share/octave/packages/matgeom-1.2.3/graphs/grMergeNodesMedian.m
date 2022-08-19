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

function [nodes2, edges2] = grMergeNodesMedian(nodes, edges, mnodes)
%GRMERGENODESMEDIAN Replace several nodes by their median coordinate.
%
%   [NODES2, EDGES2] = grMergeNodesMedian(NODES, EDGES, NODES2MERGE)
%   NODES ans EDGES are the graph structure, and NODES2MERGE is the list of
%   indices of nodes to be merged.
%   The median coordinate of merged nodes is computed, and all nodes are
%   merged to this new node.
%
%

%   -----
%   author : David Legland 
%   INRA - TPV URPOI - BIA IMASTE
%   created the 13/08/2003.
%

%   HISTORY
%   10/02/2004 : documentation


% coordinates of reference node
x = median(nodes(mnodes, 1));
y = median(nodes(mnodes, 2));

% index of reference node
refNode = findPoint([x y], nodes);
mnodes = sort(mnodes(mnodes ~= refNode));

for n = 1:length(mnodes)
    node = mnodes(n);
    
    % process each neighbor of the current node
    neighbors = grAdjacentNodes(edges, node);
    for e = 1:length(neighbors)
        edge = neighbors(e);
        
        if edges(edge, 1) == refNode || edges(edge, 2) == refNode
            continue;
        end

        % find if the node is referenced as 1 or 2 in the edge,
        % and replace it with the reference node.
        if edges(edge, 1) == node
            edges(edge, 1) = refNode;
        else
            edges(edge, 2) = refNode;
        end  
        
    end
end   

% remove nodes from the list, except the reference node.
for n = 1:length(mnodes)
    [nodes, edges] = grRemoveNode(nodes, edges, mnodes(n)-n+1);
end

nodes2 = nodes;
edges2 = edges;

    
