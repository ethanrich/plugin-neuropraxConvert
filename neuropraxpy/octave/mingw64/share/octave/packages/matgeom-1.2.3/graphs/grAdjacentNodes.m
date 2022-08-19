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

function nodes2 = grAdjacentNodes(edges, node)
%GRADJACENTNODES Find list of nodes adjacent to a given node.
%
%   NEIGHS = grAdjacentNodes(EDGES, NODE)
%   EDGES: the complete edges list (containing indices of neighbor nodes)
%   NODE: index of the node
%   NEIGHS: the nodes adjacent to the given node.
%
%   NODE can also be a vector of node indices, in this case the result is
%   the set of neighbors of any input node, excluding the input nodes.
%
%   Example
%     % create a basic graph and display it
%     nodes = [10 10;20 10;10 20;20 20;27 15];
%     edges = [1 2;1 3;2 4;2 5;3 4;4 5];
%     figure; drawGraph(nodes, edges);
%     hold on; drawNodeLabels(nodes, 1:5)
%     axis equal; axis([0 40 0 30]);
%     % compute list of nodes adjacent to node with index 2
%     grAdjacentNodes(edges, 2)
%     ans =
%         1
%         4
%         5
%
%   See Also
%     grAdjacentEdges

%   -----
%   author : David Legland 
%   INRA - TPV URPOI - BIA IMASTE
%   created the 16/08/2004.
%

%   HISTORY
%   10/02/2004 documentation
%   13/07/2004 faster algorithm
%   03/10/2007 can specify several input nodes
%   20/01/2013 rename from grNeighborNodes to grAdjacentNodes


[i, j] = find(ismember(edges, node)); %#ok<NASGU>
nodes2 = edges(i,1:2);
nodes2 = unique(nodes2(:));
nodes2 = sort(nodes2(~ismember(nodes2, node)));
