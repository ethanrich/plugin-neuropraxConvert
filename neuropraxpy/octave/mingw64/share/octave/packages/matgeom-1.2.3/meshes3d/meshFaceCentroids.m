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

function centroids = meshFaceCentroids(varargin)
%MESHFACECENTROIDS Compute centroids of faces in a mesh.
%
%   CENTROIDS = meshFaceCentroids(VERTICES, FACES)
%   VERTICES is a set of 3D points  (as a N-by-3 array), and FACES is
%   either a N-by-3 index array or a cell array of indices. The function
%   computes the centroid of each face, and returns a Nf-by-3 array
%   containing their coordinates.
%
%   Example
%     [v, e, f] = createIcosahedron;
%     normals1 = meshFaceNormals(v, f);
%     centros1 = meshFaceCentroids(v, f);
%     figure; hold on; axis equal; view(3);
%     drawMesh(v, f); 
%     drawVector3d(centros1, normals1);
%
%
%   See also:
%     meshes3d, drawMesh, meshFaceNormals, meshFaceAreas, convhull
%

% ------
% Author: David Legland
% e-mail: david.legland@inra.fr
% Created: 2006-07-05
% Copyright 2006 INRA - CEPIA Nantes - MIAJ (Jouy-en-Josas).

% HISTORY
% 2007-09-18 fix: worked only for 2D case, now works also for 3D
% 2017-11-24 rename from faceCentroids to meshFaceCentroids

% parse input data
[vertices, faces] = parseMeshData(varargin{:});

if isnumeric(faces)
    % trimesh or quadmesh
    nf = size(faces, 1);
    centroids = zeros(nf, size(vertices, 2));
    if size(vertices, 2) == 2
        % planar case
        for f = 1:nf
            centroids(f,:) = polygonCentroid(vertices(faces(f,:), :));
        end
    else
        % 3D case
        if size(faces, 2) == 3
            % For triangular meshes, uses accelerated method
            % (taken from https://github.com/alecjacobson/gptoolbox)
            for ff = 1:3
                centroids = centroids + 1/3 * vertices(faces(:,ff),:);
            end
        else
            % for quad (or larger) meshes, use slower but more precise method
            for f = 1:nf
                centroids(f,:) = polygonCentroid3d(vertices(faces(f,:), :));
            end
        end
    end        
else
    % mesh with faces stored as cell array
    nf = length(faces);
    centroids = zeros(nf, size(vertices, 2));
    if size(vertices, 2) == 2
        % planar case
        for f = 1:nf
            centroids(f,:) = polygonCentroid(vertices(faces{f}, :));
        end
    else
        % 3D case
        for f = 1:nf
            centroids(f,:) = polygonCentroid3d(vertices(faces{f}, :));
        end
    end
end

