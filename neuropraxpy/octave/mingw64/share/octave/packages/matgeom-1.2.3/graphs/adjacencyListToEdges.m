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

function edges = adjacencyListToEdges(adjList)
% Convert an adjacency list to an edge array.
%
%   EDGES = adjacencyListToEdges(ADJ)
%   Converts the adjacency list ADJ, given as a cell array of adjacent
%   indices, to an edge array. 
%
%   Example
%     % create adjacency list for a simple graph
%     adj = {[2 3], [1 4 5], [1 4], [2 3 5], [2 4]};
%     edges = adjacencyListToEdges(adj)
%     edges =
%          1     2
%          1     3
%          2     4
%          2     5
%          3     4
%          4     5
%
%   See also
%     graphs, polygonSkeletonGraph
 
% ------
% Author: David Legland
% e-mail: david.legland@inrae.fr
% INRAE - BIA Research Unit - BIBS Platform (Nantes)
% Created: 2020-06-02,    using Matlab 9.8.0.1323502 (R2020a)
% Copyright 2020 INRAE.

% TODO: allocate memory

% create the connectivity array
edges = zeros([0 2]);
for iVertex = 1:length(adjList)
    neighs = adjList{iVertex};
    for iNeigh = 1:length(neighs)
        edge = sort([iVertex neighs(iNeigh)]);
        edges = [edges ; edge]; %#ok<AGROW>
    end
end
edges = unique(edges, 'rows');
