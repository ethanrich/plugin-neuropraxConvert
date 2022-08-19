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

function [points, edges] = delaunayGraph(points, varargin)
%DELAUNAYGRAPH Graph associated to Delaunay triangulation of input points.
%
%   [NODES, EDGES] = delaunayGraph(POINTS)
%   Compute the Delaunay triangulation of the set of input points, and
%   convert to a set of edges. The output NODES is the same as the input
%   POINTS.
%
%   Example
%     % Draw a planar graph correpspionding to Delaunay triangulation
%     points = rand(30, 2) * 100;
%     [nodes, edges] = delaunayGraph(points);
%     figure; 
%     drawGraph(nodes, edges);
%
%     % Draw a 3D graph corresponding to Delaunay tetrahedrisation
%     points = rand(20, 3) * 100;
%     [nodes, edges] = delaunayGraph(points);
%     figure;
%     drawGraph(nodes, edges);
%     view(3);
%
%   See Also
%   delaunay, delaunayn, delaunayTriangulation
%

% ------
% Author: David Legland
% e-mail: david.legland@inrae.fr
% Created: 2011-05-19,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2011 INRA - Cepia Software Platform.

% compute triangulation
tri = delaunayn(points, varargin{:});

% number of simplices (triangles), and of vertices by simplex (3 in 2D)
nt = size(tri, 1);
nv = size(tri, 2);

% allocate memory
edges = zeros(nt * nv, 2);

% compute edges of each simplex
for i = 1:nv-1
    edges((1:nt) + (i-1)*nt, :) = sort([tri(:, i) tri(:, i+1)], 2);
end
edges((1:nt) + (nv-1)*nt, :) = sort([tri(:, end) tri(:, 1)], 2);

% remove multiple edges
edges = unique(edges, 'rows');
