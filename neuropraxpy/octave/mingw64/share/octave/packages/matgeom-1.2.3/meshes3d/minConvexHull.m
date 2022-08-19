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

function newFaces = minConvexHull(points, varargin)
%MINCONVEXHULL Return the unique minimal convex hull of a set of 3D points.
%
%   FACES = minConvexHull(PTS)
%   NODES is a set of 3D points  (as a Nx3 array). The function computes
%   the convex hull, and merge contiguous coplanar faces. The result is a
%   set of polygonal faces, such that there are no coplanar faces.
%   FACES is a cell array, each cell containing the vector of indices of
%   nodes given in NODES for the corresponding face.
%
%   FACES = minConvexHull(PTS, PRECISION)
%   Adjust the threshold for deciding if two faces are coplanar or
%   parallel. Default value is 1e-14.
%
%   Example
%     % extract square faces from a cube
%     [n, e, f] = createCube;
%     f2 = minConvexHull(n);
%     drawMesh(n, f2);
%
%     % Subdivides and smooths a mesh rpresenting a cube
%     [n, e, f] = createCube;
%     [n2, f2] = subdivideMesh(n, triangulateFaces(f), 4);
%     [n3, f3] = smoothMesh(n2, f2);
%     figure; drawMesh(n3, f3);
%     axis equal; view(3);
%     % merge coplanar faces, making apparent the faces of the original cube
%     f4 = minConvexHull(n3);
%     figure; drawMesh(n3, f4);
%     axis equal; view(3);
%
%
%   See also
%   meshes3d, mergeCoplanarFaces, drawMesh, convhull, convhulln
%


% ------
% Author: David Legland
% e-mail: david.legland@inra.fr
% Created: 2006-07-05
% Copyright 2006 INRA - CEPIA Nantes - MIAJ (Jouy-en-Josas).

% HISTORY
%   20/07/2006 add tolerance for coplanarity test
%   21/08/2006 fix small bug due to difference of methods to test
%       coplanarity, sometimes resulting in 3 points of a face being not
%       coplanar! Also add control on precision
%   18/09/2007 ensure faces are given as horizontal vectors

% set up precision
acc = 1e-14;
if ~isempty(varargin)
    acc = varargin{1};
end

% triangulated convex hull. It is not uniquely defined.
faces = convhulln(points);

% compute centroid of the nodes
pointsCentroid = centroid(points);

% number of base triangular faces
N = size(faces, 1);

% compute normals of given faces
normals = planeNormal(createPlane(...
    points(faces(:,1),:), points(faces(:,2),:), points(faces(:,3),:)));

% initialize empty faces
newFaces = {};


% Processing flag for each triangle
% 1 : triangle to process, 0 : already processed
% in the beginning, every triangle face need to be processed
flag = ones(N, 1);

% iterate on each triangular face of the convex hull
for iFace = 1:N
    
    % check if face was already performed
    if ~flag(iFace)
        continue;
    end

    % indices of faces with same normal
    ind = find(abs(vectorNorm3d(cross(repmat(normals(iFace, :), [N 1]), normals)))<acc);
    ind = ind(ind~=iFace);
    
    % keep only coplanar faces (test coplanarity of points in both face)
    ind2 = iFace;
    for j = 1:length(ind)
        if isCoplanar(points([faces(iFace,:) faces(ind(j),:)], :), acc)
            ind2 = [ind2 ind(j)]; %#ok<AGROW>
        end
    end
    
    
    % compute order of the vertices in current face
    faceVertices = unique(faces(ind2, :));
    [tmp, I]  = angleSort3d(points(faceVertices, :)); %#ok<ASGLU>
    
    % create the new face, ensuring it is a row vector
    face = faceVertices(I);
    face = face(:)';
    
    % ensure face has normal pointing outwards
    outerNormal = meshFaceCentroids(points, face) - pointsCentroid;
    if dot(meshFaceNormals(points, face), outerNormal, 2) < 0
        face = face([1 end:-1:2]);
    end
    
    % add a new face to the list
    newFaces = [newFaces {face}]; %#ok<AGROW>
    
    % mark processed faces
    flag(ind2) = 0;
end

