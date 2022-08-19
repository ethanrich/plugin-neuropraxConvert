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

function normals = meshFaceNormals(varargin)
%MESHFACENORMALS Compute normal vector of faces in a 3D mesh.
%
%   NORMALS = meshFaceNormals(VERTICES, FACES)
%   VERTICES is a set of 3D points (as a N-by-3 array), and FACES is either
%   a N-by-3 index array or a cell array of indices. The function computes
%   the normal vector of each face.
%   The orientation of the normal is defined by the sign of cross product
%   between vectors joining vertices 1 to 2 and 1 to 3.
%
%
%   Example
%     [v e f] = createIcosahedron;
%     normals1 = meshFaceNormals(v, f);
%     centros1 = meshFaceCentroids(v, f);
%     figure; drawMesh(v, f); 
%     hold on; axis equal; view(3);
%     drawVector3d(centros1, normals1);
%
%     pts = rand(50, 3);
%     hull = minConvexHull(pts);
%     normals2 = meshFaceNormals(pts, hull);
%
%   See also
%   meshes3d, meshFaceCentroids, meshVertexNormals, drawFaceNormals
%   drawMesh 

% ------
% Author: David Legland
% e-mail: david.legland@inra.fr
% Created: 2006-07-05
% Copyright 2006 INRA - CEPIA Nantes - MIAJ (Jouy-en-Josas).

% HISTORY
% 2011-11-24 rename from faceNormal to meshFaceNormals

% parse input data
[vertices, faces] = parseMeshData(varargin{:});

if isnumeric(faces)
    % compute vector of first edges
	v1 = vertices(faces(:,2),1:3) - vertices(faces(:,1),1:3);
    v2 = vertices(faces(:,3),1:3) - vertices(faces(:,1),1:3);
    
    % compute normals using cross product (nodes have same size)
	normals = cross(v1, v2, 2);

else
    % initialize empty array
    normals = zeros(length(faces), 3);
    
    for i = 1:length(faces)
        face = faces{i};
        % compute vector of first edges
        v1 = vertices(face(2),1:3) - vertices(face(1),1:3);
        v2 = vertices(face(3),1:3) - vertices(face(1),1:3);

        % compute normals using cross product
        normals(i, :) = cross(v1, v2, 2);
    end
end

normals = normalizeVector3d(normals);
