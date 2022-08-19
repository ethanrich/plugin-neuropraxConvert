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

function varargout = drawFaceNormals(varargin)
%DRAWFACENORMALS Draw normal vector of each face in a mesh.
%
%   drawFaceNormals(V, E, F)
%   Compute and draw the face normals of the mesh defined by vertices V,
%   edges E and faces F. See meshes3d for format of each argument.
%
%   H = drawFaceNormals(...)
%   Return handle array to the created objects.
%
%   Example
%   % draw face normals of a cube
%     [v, f] = createCubeOctahedron;
%     figure; drawMesh(v, f)
%     axis([-2 2 -2 2 -2 2]); axis equal; hold on;
%     drawFaceNormals(v, f)
%     view(3);
%
%   See also
%   meshes3d, drawMesh, drawVector3d, meshFaceNormals, meshFaceCentroids
%

% ------
% Author: David Legland
% e-mail: david.legland@inra.fr
% Created: 2010-10-06,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2010 INRA - Cepia Software Platform.

% extract vertices and faces
mesh = parseMeshData(varargin{:});

% compute vector data
c = meshFaceCentroids(mesh);
n = meshFaceNormals(mesh);

% display an arrow for each normal
h = quiver3(c(:,1), c(:,2), c(:,3), n(:,1), n(:,2), n(:,3));

% format output
if nargout > 0
    varargout{1} = h;
end
