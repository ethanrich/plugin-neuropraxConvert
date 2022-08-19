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

function [normals, faceNormals] = meshVertexNormals(varargin)
%MESHVERTEXNORMALS Compute normals to a mesh vertices.
%
%   N = meshVertexNormals(V, F)
%   Computes vertex normals of the mesh given by vertices V and F. 
%   V is a vertex array with 3 columns, F is either a NF-by-3 or NF-by-4
%   index array, or a cell array with NF elements.
%
%   Example
%     % Draw the vertex normals of a sphere
%     s = [10 20 30 20];
%     [v f] = sphereMesh(s);
%     figure; drawMesh(v, f);
%     view(3);axis equal; light; lighting gouraud;
%     normals = meshVertexNormals(v, f);
%     drawVector3d(v, normals*2);
%
%   See also
%     meshes3d, meshFaceNormals, triangulateFaces
%

% ------
% Author: David Legland
% e-mail: david.legland@inra.fr
% Created: 2011-12-19,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2011 INRA - Cepia Software Platform.

[vertices, faces] = parseMeshData(varargin{:});

nv = size(vertices, 1);
nf = size(faces, 1);

% unit normals to the faces
faceNormals = normalizeVector3d(meshFaceNormals(vertices, faces));

% compute normal of each vertex: sum of normals to each face
normals = zeros(nv, 3);
if isnumeric(faces)
    for i = 1:nf
        face = faces(i, :);
        for j = 1:length(face)
            v = face(j);
            normals(v, :) = normals(v,:) + faceNormals(i,:);
        end
    end
else
    for i = 1:nf
        face = faces{i};
        for j = 1:length(face)
            v = face(j);
            normals(v, :) = normals(v,:) + faceNormals(i,:);
        end
    end
end

% normalize vertex normals to unit vectors
normals = normalizeVector3d(normals);
