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

function inds = meshBoundaryVertexIndices(varargin)
%MESHBOUNDARYVERTEXINDICES Indices of boundary vertices of a mesh.
%
%   INDS = meshBoundaryVertexIndices(V, F)
%   INDS = meshBoundaryVertexIndices(V, E, F)
%
%   Example
%     % create centered icosahedron
%     [v, f] = createIcosahedron;
%     v(:,3) = v(:,3) - mean(v(:,3));
%     % convert to simili-sphere
%     [v2, f2] = subdivideMesh(v, f, 3);
%     v3 = normalizeVector3d(v2);
%     % clip with plane
%     plane = createPlane([0 0 0], [-1 -2 3]);
%     [vc, fc] = clipMeshVertices(v3, f2, plane, 'shape', 'plane');
%     figure; drawMesh(vc, fc); axis equal; view(3);
%     % draw boundary vertices
%     inds = meshBoundaryVertexIndices(vc, fc);
%     hold on; drawPoint3d(vc(inds,:), 'k*');
%
%   See also
%     meshes3d, meshBoundary, meshBoundaryEdgeIndices, meshEdgeFaces
 
% ------
% Author: David Legland
% e-mail: david.legland@inra.fr
% Created: 2019-05-01,    using Matlab 8.6.0.267246 (R2015b)
% Copyright 2019 INRA - Cepia Software Platform.

[vertices, edges, faces] = parseMeshData(varargin{:});

% Compute edge-vertex map if not specified
if isempty(edges)
    edges = meshEdges(vertices, faces);
end

% compute edges to faces map
edgeFaces = meshEdgeFaces(vertices, edges, faces);

borderEdges = sum(edgeFaces == 0, 2) > 0;

inds = edges(borderEdges, :);
inds = unique(inds(:));
