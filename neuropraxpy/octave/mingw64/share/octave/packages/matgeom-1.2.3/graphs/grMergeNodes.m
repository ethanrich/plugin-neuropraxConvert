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

function [nodes, edges] = grMergeNodes(nodes, edges, mnodes)
%GRMERGENODES Merge two (or more) nodes in a graph.
%
% usage:
%   [NODES2 EDGES2] = grMergeNodes(NODES, EDGES, NODE_INDS)
%   NODES and EDGES are wo arrays representing a graph, and NODE_INDS is
%   the set of indices of the nodes to merge.
%   The nodes corresponding to indices in NODE_INDS are removed from the
%   list, and edges between two nodes are removed.
%
%   Example: merging of lables 1 and 2
%   Edges:         Edges2:
%   [1 2]           [1 3]
%   [1 3]           [1 4]
%   [1 4]           [3 4]
%   [2 3]
%   [3 4]
%   
%
%   -----
%
%   author : David Legland 
%   INRA - TPV URPOI - BIA IMASTE
%   created the 30/06/2004.
%

refNode = mnodes(1);
mnodes = mnodes(2:length(mnodes));

% replace merged nodes references by references to refNode
edges(ismember(edges, mnodes))=refNode;

% remove "loop edges" from and to reference node
edges = edges(edges(:,1) ~= refNode | edges(:,2) ~= refNode, :);

% format output
edges = sortrows(unique(sort(edges, 2), 'rows'));

