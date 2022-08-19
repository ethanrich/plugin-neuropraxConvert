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

function [nodes, edges, faces] = boundedVoronoi2d(box, germs)
%BOUNDEDVORONOI2D Return a bounded voronoi diagram as a graph structure.
%   
%   [NODES, EDGES, FACES] = boundedVoronoi2d(BOX, GERMS)
%   GERMS an array of points with dimension 2
%   NODES, EDGES, FACES: usual graph representation, FACES as cell array
%
%   Example
%   [n, e, f] = boundedVoronoi2d([0 100 0 100], rand(100, 2)*100);
%   drawGraph(n, e);
%
%   See also
%     graphs, boundedCentroidalVoronoi2d, clipGraph, clipGraphPolygon

% ------
% Author: David Legland
% e-mail: david.legland@inra.fr
% Created: 2007-01-12
% Copyright 2007 INRA - BIA PV Nantes - MIAJ Jouy-en-Josas.

% uniformize input for box.
box = box';
box = box(:);

% add points far enough
boxSizeX  = box(2) - box(1);
boxSizeY  = box(4) - box(3);
farPoints = [...
    box(2)+2*boxSizeX  box(4)+3*boxSizeY;...
    box(1)-3*boxSizeX  box(4)+2*boxSizeY;...
    box(1)-2*boxSizeX  box(3)-3*boxSizeY;...
    box(2)+3*boxSizeX  box(3)-2*boxSizeY;...
    ];

% extract voronoi vertices and face structure
[V, C] = voronoin([germs ; farPoints]);

% initialize graph structure, without edges and without faces
nodes = V(2:end, :);
edges = zeros(0, 2);
faces = {};

for i = 1:size(germs, 1)   
    cell = C{i};
    cell = cell-1;
    edges = [edges; sort([cell' cell([2:end 1])'], 2)]; %#ok<AGROW>
    faces{length(faces)+1} = cell; %#ok<AGROW>
end

edges = unique(edges, 'rows');


