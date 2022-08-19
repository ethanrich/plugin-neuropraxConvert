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

function varargout = transformMesh(varargin)
%TRANSFORMMESH Applies a 3D affine transform to a mesh.
%
%   MESH2 = transformMesh(MESH1, TRANSFO)
%   MESH2 = transformMesh(VERTICES, FACES, TRANSFO)
%   [V2, F2] = transformMesh(...)
%
%   Example
%     mesh1 = createOctahedron;
%     transfo = eulerAnglesToRotation3d([30 20 10]);
%     mesh2 = transformMesh(mesh1, transfo);
%     figure; axis equal; hold on; drawMesh(mesh2, 'faceColor', 'g'); view(3);
%
%   See also
%     meshes3d, transformPoint3d, drawMesh
%
 
% ------
% Author: David Legland
% e-mail: david.legland@inra.fr
% Created: 2019-08-08,    using Matlab 9.6.0.1072779 (R2019a)
% Copyright 2019 INRA - Cepia Software Platform.

% parses input arguments
[vertices, edges, faces] = parseMeshData(varargin{1:end-1});
transfo = varargin{end};

vertices2 = transformPoint3d(vertices, transfo);

% format output
varargout = formatMeshOutput(nargout, vertices2, edges, faces);
