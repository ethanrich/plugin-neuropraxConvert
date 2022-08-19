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

function lengths = grEdgeLengths(nodes, edges, varargin)
%GREDGELENGTHS  Compute length of edges in a geometric graph.
%
%   LENGTHS = grEdgeLengths(NODES, EDGES)
%
%   Example
%     % create a basic graph and display it
%     nodes = [10 10;20 10;10 20;20 20;27 15];
%     edges = [1 2;1 3;2 4;2 5;3 4;4 5];
%     figure; drawGraph(nodes, edges);
%     hold on; drawNodeLabels(nodes, 1:5)
%     axis equal; axis([0 40 0 30]);
%     % compute list of nodes adjacent to node with index 2
%     grEdgeLengths(nodes, edges)'
%     ans =
%          10.0000   10.0000   10.0000    8.6023   10.0000    8.6023
%
%   See also
%

% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2014-01-13,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2014 INRA - Cepia Software Platform.

nEdges = size(edges, 1);
lengths = zeros(nEdges, 1);


for iEdge = 1:nEdges
    ed = edges(iEdge, :);
    node1 = nodes(ed(1),:);
    node2 = nodes(ed(2),:);
    lengths(iEdge) = sqrt(sum((node1 - node2).^2));
end
