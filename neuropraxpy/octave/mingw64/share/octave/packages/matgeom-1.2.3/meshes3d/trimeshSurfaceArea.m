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

function area = trimeshSurfaceArea(v, e, f)
%TRIMESHSURFACEAREA Surface area of a triangular mesh.
%
%   S = trimeshSurfaceArea(V, F)
%   S = trimeshSurfaceArea(V, E, F)
%   Computes the surface area of the mesh specified by vertex array V and
%   face array F. Vertex array is a NV-by-3 array of coordinates. 
%   Face array is a NF-by-3, containing vertex indices of each face.
%
%   Example
%     % Compute area of an octahedron (equal to 2*sqrt(3)*a*a, with 
%     % a = sqrt(2) in this case)
%     [v f] = createOctahedron;
%     trimeshSurfaceArea(v, f)
%     ans = 
%         6.9282
%
%     % triangulate a compute area of a unit cube
%     [v f] = createCube;
%     f2 = triangulateFaces(f);
%     trimeshSurfaceArea(v, f2)
%     ans =
%         6
%
%   See also
%   meshes3d, meshSurfaceArea, trimeshMeanBreadth, triangulateFaces

% ------
% Author: David Legland
% e-mail: david.legland@inra.fr
% Created: 2011-08-26,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2011 INRA - Cepia Software Platform.

% check input number
if nargin == 2
    f = e;
end

% compute two direction vectors, using first vertex of each face as origin
v1 = v(f(:, 2), :) - v(f(:, 1), :);
v2 = v(f(:, 3), :) - v(f(:, 1), :);

% area of each triangle is half the cross product norm
vn = vectorNorm3d(crossProduct3d(v1, v2));

% sum up and normalize
area = sum(vn) / 2;
