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

function [b1, b2] = isManifoldMesh(varargin)
%ISMANIFOLDMESH Check whether the input mesh may be considered as manifold.
%
%   B = isManifoldMesh(V, F)
%   B = isManifoldMesh(V, E, F)
%   Checks if the specified mesh is a manifold. When mesh is a manifold,
%   all edges are connected to either 2 or 1 faces.
%
%   [B, HASBORDER] = isManifoldMesh(V, E, F)
%   Also checks whether the mesh contains border faces. Border faces
%   contains at least one edge which is ajacent to only one face.
%
%   Example
%     [V, F] = createOctahedron;
%     isManifoldMesh(V, F)
%     ans =
%       logical
%        1
%
%   See also
%     meshes3d, ensureManifoldMesh, trimMesh
 
% ------
% Author: David Legland
% e-mail: david.legland@inra.fr
% Created: 2019-01-31,    using Matlab 9.5.0.944444 (R2018b)
% Copyright 2019 INRA - Cepia Software Platform.

vertices = varargin{1};
faces = varargin{2};

% compute edge to vertex array
if nargin == 3
    edges = faces;
    faces = varargin{3};
else
    % compute edge to vertex array
    edges = meshEdges(faces);
end


% compute face to edge indices array
% as a nFaces-by-3 array (each face connected to exactly three edges)
faceEdgeInds = meshFaceEdges(vertices, edges, faces);

% compute number of faces incident each edge
edgeFaces = trimeshEdgeFaces(faces);
edgeFaceDegrees = sum(edgeFaces > 0, 2);

% for each face, concatenate the face degree of each edge
faceEdgeDegrees = zeros(size(faces, 1), 3);
for iFace = 1:size(faces, 1)
    edgeInds = faceEdgeInds{iFace};
    faceEdgeDegrees(iFace, :) = edgeFaceDegrees(edgeInds);
end

regFaces = sum(ismember(faceEdgeDegrees, [1 2]), 2) == 3;
innerFaces = sum(faceEdgeDegrees == 2, 2) == 3;
borderFaces = regFaces & ~innerFaces;

% check if mesh is manifold: all faces are either regular or border
b1 = all(regFaces);

% check if some faces are border
b2 = any(borderFaces);
