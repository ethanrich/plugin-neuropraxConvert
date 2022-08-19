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

function areas = meshFaceAreas(vertices, faces)
%MESHFACEAREAS Surface area of each face of a mesh.
%
%   areas = meshFaceAreas(vertices, faces)
%
%   Example
%     [v, f] = createOctahedron;
%     meshFaceAreas(v, f)'
%     ans =
%         1.7321  1.7321  1.7321  1.7321  1.7321  1.7321  1.7321  1.7321
%
%   See also
%     meshes3d, meshSurfaceArea, meshFaceCentroids
 
% ------
% Author: David Legland
% e-mail: david.legland@inra.fr
% Created: 2018-06-21,    using Matlab 9.4.0.813654 (R2018a)
% Copyright 2018 INRA - Cepia Software Platform.


if isnumeric(faces)
    % trimesh or quadmesh
    nf = size(faces, 1);
    areas = zeros(nf, 1);
    if size(vertices, 2) == 2
        % planar case
        for f = 1:nf
            areas(f,:) = polygonArea(vertices(faces(f,:), :));
        end
    else
        % 3D case
        if size(faces, 2) == 3
            % For triangular meshes, uses accelerated method
            v1 = vertices(faces(:,1), :);
            v12 = vertices(faces(:,2), :) - v1;
            v13 = vertices(faces(:,3), :) - v1;
            areas = vectorNorm3d(crossProduct3d(v12, v13))/2;
            
        else
            % for quad (or larger) meshes, use slower but more precise method
            for f = 1:nf
                areas(f) = polygonArea3d(vertices(faces(f,:), :));
            end
        end
    end
    
else
    % mesh with faces stored as cell array
    nf = length(faces);
    areas = zeros(nf, 1);
    if size(vertices, 2) == 2
        % planar case
        for f = 1:nf
            areas(f) = polygonArea(vertices(faces{f}, :));
        end
    else
        % 3D case
        for f = 1:nf
            areas(f) = polygonArea3d(vertices(faces{f}, :));
        end
    end
end

