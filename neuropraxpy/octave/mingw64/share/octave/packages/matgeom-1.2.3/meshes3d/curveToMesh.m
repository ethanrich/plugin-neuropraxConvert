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

function [vertices, faces] = curveToMesh(curve, varargin)
% Create a mesh surrounding a 3D curve.
%
%   [V, F] = curveToMesh(CURVE)
%   Computes the vertices and the faces of the mesh surrounding the
%   specified 3D curve.
%
%   [V, F] = curveToMesh(CURVE, THICKNESS)
%   Specifies the thickness of the mesh (distance between mesh vertices and
%   curve vertices). Default is 0.5.
%
%   [V, F] = curveToMesh(CURVE, THICKNESS, NCORNERS)
%   Also specifies the number of mesh vertices around each curve vertex.
%   Default is 8.
%
%
%   Example
%     % Creates a tubular mesh around a trefoil knot curve
%     t = linspace(0, 2*pi, 200)';
%     x = sin(t) + 2 * sin(2 * t);
%     y = cos(t) - 2 * cos(2 * t);
%     z = -sin(3 * t);
%     curve = [x, y, z];
%     [v2, f2] = curveToMesh(curve, .5, 16);
%     figure; 
%     drawMesh(v2, f2);
%     axis equal; view(3);
%     axis([-4 4 -4 4 -2 2]);
%  
%   See also
%     meshes3d, torusMesh, surfToMesh
 
% ------
% Author: David Legland
% e-mail: david.legland@inra.fr
% Created: 2015-01-07,    using Matlab 8.4.0.150421 (R2014b)
% Copyright 2015 INRA - Cepia Software Platform.

radius = .1;
if nargin > 1
    radius = varargin{1};
end

nCorners = 8;
if nargin > 2
    nCorners = varargin{2};
end

nNodes = size(curve, 1);
nVerts = nNodes * nCorners;

vertices = zeros(nVerts, 3);

% create reference corners, that will be rotated and translated
t = linspace(0, 2*pi, nCorners + 1)';
t(end) = [];
baseCorners = radius * [cos(t) sin(t) zeros(size(t))];

for iNode = 1:nNodes
    % coordinate of current node
    node = curve(iNode, :);
    
    % compute local tangent vector
    iNext = mod(iNode, nNodes) + 1;
    tangentVector = normalizeVector3d(curve(iNext, :) - node);

    % convert to spherical coordinates
    [theta, phi, rho] = cart2sph2(tangentVector); %#ok<ASGLU>
    
    % apply transformation to place corners around current node
    rotY = createRotationOy(theta);
    rotZ = createRotationOz(phi);
    trans = createTranslation3d(node);
    transformMatrix = trans * rotZ * rotY;
    corners = transformPoint3d(baseCorners, transformMatrix);
    
    % concatenate with other corners
    vertices( (1:nCorners) + (iNode - 1) * nCorners, :) = corners;
end

% indices of vertices
inds = (1:nVerts)';
add1 = repmat([ones(nCorners-1, 1) ; 1-nCorners], nNodes, 1);

% generate faces
faces = [inds ...
    mod(inds + add1 - 1, nVerts) + 1 ...
    mod(inds + nCorners + add1 - 1, nVerts) + 1 ...
    mod(inds + nCorners - 1, nVerts) + 1];

