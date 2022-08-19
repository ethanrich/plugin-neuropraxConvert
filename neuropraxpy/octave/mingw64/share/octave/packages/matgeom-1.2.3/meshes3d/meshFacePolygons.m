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

function polys = meshFacePolygons(varargin)
%MESHFACEPOLYGONS Returns the set of polygons that constitutes a mesh.
%
%   POLYGONS = meshFacePolygons(V, F)
%   POLYGONS = meshFacePolygons(MESH)
%
%   Example
%     [v f] = createCubeOctahedron;
%     polygons = meshFacePolygons(v, f);
%     areas = polygonArea3d(polygons);
%     sum(areas)
%     ans =
%         18.9282
%
%   See also
%     meshes3d, meshFace, polygonArea3d

% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2013-08-20,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2013 INRA - Cepia Software Platform.

% extract vertices and faces
[v, f] = parseMeshData(varargin{:});

% number of faces
if iscell(f)
    nFaces = length(f);
else
    nFaces = size(f, 1);
end

% allocate cell array for result
polys = cell(nFaces, 1);

% compute polygon corresponding to each face
if iscell(f)
    for i = 1:nFaces
        polys{i} = v(f{i}, :);
    end
else
    for i = 1:nFaces
        polys{i} = v(f(i,:), :);
    end
end
