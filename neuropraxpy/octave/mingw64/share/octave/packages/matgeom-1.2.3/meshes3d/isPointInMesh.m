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

function res = isPointInMesh(point, v, f, varargin)
%ISPOINTINMESH Check if a point is inside a 3D mesh.
%
%   B = isPointInMesh(PT, V, F)
%   Check if the point PT (given as a 1-by-3 array) is inside the mesh
%   defined by the vertices V and the face array F. The result is a
%   boolean.
%
%   If PT is a N-by-3 point array, the result is a N-by-1 array of logical.
%
%   Example
%     [v, f] = torusMesh([50 50 50 30 10 30 45]);
%     [x, y, z] = meshgrid(5:5:100, 5:5:100, 5:5:100);
%     res = false(size(x));
%     res(:) = isPointInMesh([x(:) y(:) z(:)], v, f);
%     figure; plot3(x(res), y(res), z(res), 'b.'); axis equal;
%
%   Algorithm:
%   The method computes the intersection with a ray starting from the
%   point(s) and with a random orientation. Some errors are possible if
%   rays crosses the mesh between two or three faces.
%
%   See also
%     meshes3d, intersectLineMesh3d
 
% ------
% Author: David Legland
% e-mail: david.legland@inra.fr
% Created: 2018-01-26,    using Matlab 9.3.0.713579 (R2017b)
% Copyright 2018 INRA - Cepia Software Platform.

% choose a random vector
vect = rand(1, 3);

% initialize array for result
np = size(point, 1);
res = false(np, 1);

% iterate over the various points
for i = 1:np
%     disp(i);
    line = createLine3d(point(i,:), vect);
    
    [inters, pos] = intersectLineMesh3d(line, v, f); %#ok<ASGLU>
    
    res(i) = mod(sum(pos > 0), 2) > 0;
end
