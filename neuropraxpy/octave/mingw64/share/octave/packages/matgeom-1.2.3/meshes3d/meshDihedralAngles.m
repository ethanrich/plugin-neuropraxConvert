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

function alpha = meshDihedralAngles(vertices, edges, faces)
%MESHDIHEDRALANGLES Dihedral at edges of a polyhedal mesh.
%
%   ALPHA = meshDihedralAngles(V, E, F)
%   where V, E and F represent vertices, edges and faces of a mesh,
%   computes the dihedral angle between the two adjacent faces of each edge
%   in the mesh. ALPHA is a column array with as many rows as the number of
%   edges. The i-th element of ALPHA corresponds to the i-th edge.
%
%   Note: the function assumes that the faces are correctly oriented. The
%   face vertices should be indexed counter-clockwise when considering the
%   supporting plane of the face, with the outer normal oriented outwards
%   of the mesh.
%
%   Example
%   [v, e, f] = createCube;
%   rad2deg(meshDihedralAngles(v, e, f))
%   ans = 
%       90
%       90
%       90
%       90
%       90
%       90
%       90
%       90
%       90
%       90
%       90
%       90
%
%   See also
%   meshes3d, polyhedronMeanBreadth, trimeshMeanBreadth, dihedralAngle, meshEdgeFaces
%

% ------
% Author: David Legland
% e-mail: david.legland@inra.fr
% Created: 2010-10-04,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2010 INRA - Cepia Software Platform.

% compute normal of each face
normals = meshFaceNormals(vertices, faces);

% indices of faces adjacent to each edge
edgeFaces = meshEdgeFaces(vertices, edges, faces);

% allocate memory for resulting angles
Ne = size(edges, 1);
alpha = zeros(Ne, 1);

% iterate over edges
for i = 1:Ne
    % indices of adjacent faces
    indFace1 = edgeFaces(i, 1);
    indFace2 = edgeFaces(i, 2);
    
    % normal vector of adjacent faces
    normal1 = normals(indFace1, :);
    normal2 = normals(indFace2, :);
    
    % compute dihedral angle of two vectors
    alpha(i) = vectorAngle3d(normal1, normal2);
end

