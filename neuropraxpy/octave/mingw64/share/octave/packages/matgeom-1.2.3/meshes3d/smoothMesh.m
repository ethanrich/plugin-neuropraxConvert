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

function varargout = smoothMesh(varargin)
%SMOOTHMESH Smooth mesh by replacing each vertex by the average of its neighbors.
%
%   V2 = smoothMesh(V, F)
%   [V2, F2] = smoothMesh(V, F)
%   Performs smoothing of the values given in V, by using adjacency
%   information given in F. 
%   V is a numeric array representing either vertex coordinate, or value
%   field associated to each vertex. F is an array of faces, given either
%   as a NF-by-3 or NF-by-4 numeric array, or as a cell array. 
%   Artifact adjacencies are added if faces have more than 4 vertices.
%
%   ... = smoothMesh(V, F, NITER)
%   Repeat the smoothing procedure NITER times. This is equivalent to
%   calling the smoothMesh function NITER times.
%
%
%   Example
%     [v f] = torusMesh([50 50 50 30 10 30 45]);
%     v = v + randn(size(v));
%     [v2 f] = smoothMesh(v, f, 3);
%     figure; drawMesh(v2, f);
%     l = light; lighting gouraud
%
%   See also
%     meshes3d, meshAdjacencyMatrix, triangulateFaces, drawMesh
%

% ------
% Author: David Legland
% e-mail: david.legland@inra.fr
% Created: 2013-04-29,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2013 INRA - Cepia Software Platform.

var1 = varargin{1};
if isstruct(var1)
    vertices = var1.vertices;
    faces = var1.faces;
    varargin(1) = [];
else
    vertices = varargin{1};
    faces = varargin{2};
    varargin(1:2) = [];
end

% determine number of iterations
nIter = 1;
if ~isempty(varargin)
    nIter = varargin{1};
end

% compute adjacency matrix, 
% result is a Nv-by-Nv matrix with zeros on the diagonal
adj = meshAdjacencyMatrix(faces);

% ensure the size of the matrix is Nv-by-Nv
% (this can not be the case if some vertices are not referenced)
nv = size(vertices, 1);
if size(adj, 1) < nv
    adj(nv, nv) = 0;
end

% Add "self adjacencies"
adj = adj + speye(nv);

% weight each vertex by the number of its neighbors
w = spdiags(full(sum(adj, 2).^(-1)), 0, nv, nv);
adj = w * adj;

% do averaging to smooth the field
v2 = vertices;
for k = 1:nIter
    v2 = adj * v2;
end

varargout = formatMeshOutput(nargout, v2, faces);

%% Old version
% % Compute vertex adjacencies
% edges = computeMeshEdges(faces);
% v2 = zeros(size(vertices));
% 
% % apply several smoothing
% for iter = 1:nIter
%     
%     % replace the coords of each vertex by the average coordinate in the
%     % neighborhood
%     for i = 1:size(vertices, 1)
%         edgeInds = sum(edges == i, 2) > 0;
%         neighInds = unique(edges(edgeInds, :));
%         v2(i, :) = mean(vertices(neighInds, :));
%     end
%     
%     % update for next iteration
%     vertices = v2;
% end
