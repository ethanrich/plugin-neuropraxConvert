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

function varargout = removeMeshEars(varargin)
%REMOVEMESHEARS Remove vertices that are connected to only one face.
%
%   [V, F] = removeMeshEars(V, F)
%   [V, F] = removeMeshEars(MESH)
%   Remove vertices that are connected to only one face. This removes also
%   "pending" faces.
%   Note that if the mesh has boundary, this may remove some regular faces
%   located on the boundary.
%
%   Example
%   removeMeshEars
%
%   See also
%     meshes3d, ensureManifoldMesh
%
 
% ------
% Author: David Legland
% e-mail: david.legland@inra.fr
% Created: 2019-01-08,    using Matlab 8.6.0.267246 (R2015b)
% Copyright 2019 INRA - Cepia Software Platform.

[vertices, faces] = parseMeshData(varargin{:});

nVertices = size(vertices, 1);

% for each vertex, determine the number of faces it belongs to
vertexDegree = zeros(nVertices, 1);
for iv = 1:nVertices
    vertexDegree(iv) = sum(sum(faces == iv, 2) > 0);
end

% remove vertices with degree 1
inds = find(vertexDegree == 1);
[vertices, faces] = removeMeshVertices(vertices, faces, inds);


%% Format output

varargout = formatMeshOutput(nargout, vertices, faces);
