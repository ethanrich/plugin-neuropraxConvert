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

function [nodes, edges, faces] = addSquareFace(nodes, edges, faces, faceNodes)
%ADDSQUAREFACE Add a (square) face defined from its vertices to a graph.
%
%   [N2 E2 F2] = addSquareFace(N, E, F, FN)
%   Add a new face, defined by the nodes indices FN, to the graph defined
%   by node list N, edge list E, and face list F.
%   Edges of the face are also added, if they are not already present in
%   the edge list.
%
%   See Also
%   patchGraph, boundaryGraph
%
%
%   ---------
%
%   author : David Legland 
%   INRA - TPV URPOI - BIA IMASTE
%   created the 28/06/2004.
%



n1 = faceNodes(1,:);
n2 = faceNodes(2,:);
n3 = faceNodes(3,:);
n4 = faceNodes(4,:);

% search indices of each nodes
ind1 = find(ismember(nodes, n1, 'rows'));       
ind2 = find(ismember(nodes, n2, 'rows'));
ind3 = find(ismember(nodes, n3, 'rows'));       
ind4 = find(ismember(nodes, n4, 'rows'));

% if nodes are not in the list, we add them
if isempty(ind1)
    nodes = [nodes; n1];
    ind1 = size(nodes, 1);
end
if isempty(ind2)
    nodes = [nodes; n2];
    ind2 = size(nodes, 1);
end
if isempty(ind3)
    nodes = [nodes; n3];
    ind3 = size(nodes, 1);
end
if isempty(ind4)
    nodes = [nodes; n4];
    ind4 = size(nodes, 1);
end

% add current face to the list
faces(size(faces, 1)+1, 1:4) = [ind1(1) ind2(1) ind3(1) ind4(1)];

% create edges of the face 
% (first index is the smallest one, by convention)
e1 = [min(ind1, ind2) max(ind1, ind2)];
e2 = [min(ind2, ind3) max(ind2, ind3)];
e3 = [min(ind3, ind4) max(ind3, ind4)];
e4 = [min(ind4, ind1) max(ind4, ind1)];

% search edge indices in the list
% if nodes are not in the list
if isempty(ismember(edges, e1, 'rows'))
    edges = [edges; e1];
end
if isempty(ismember(edges, e2, 'rows'))
    edges = [edges; e2];
end
if isempty(ismember(edges, e3, 'rows'))
    edges = [edges; e3];
end
if isempty(ismember(edges, e4, 'rows'))
    edges = [edges; e4];
end
