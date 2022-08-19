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

function box3d = orientedBox3d(pts)
%ORIENTEDBOX3D Object-oriented bounding box of a set of 3D points.
%
%   OOBB = orientedBox3d(PTS)
%
%   Example
%     [v, f] = sphereMesh;
%     rotMat = eulerAnglesToRotation3d(30, 20, 10);
%     pts = transformPoint3d(bsxfun(@times, v, [5 3 1]), rotMat);
%     box3d = orientedBox3d(pts);
%     figure; drawPoint3d(pts, '.'); hold on;
%     axis equal; axis([-6 6 -6 6 -5 5]);
%     h = drawCuboid(box3d);
%     set(h, 'facecolor', 'none');
%
%   See also
%     meshes3d, drawCuboid
 
% ------
% Author: David Legland
% e-mail: david.legland@nantes.inra.fr
% Created: 2015-12-01,    using Matlab 8.6.0.267246 (R2015b)
% Copyright 2015 INRA - Cepia Software Platform.

tri = convhulln(pts);
nFaces = size(tri, 1);

%% identify index of face with smallest width
indMinBreadth = 0;
minBreadth = Inf;
for iFace = 1:nFaces
    faceInds = tri(iFace, :);
    plane = createPlane(pts(faceInds, :));
    
    breadth = max(abs(distancePointPlane(pts, plane)));
    
    if breadth < minBreadth
        minBreadth = breadth;
        indMinBreadth = iFace;
    end
end

% compute projection on reference plane
refPlane = createPlane(pts(tri(indMinBreadth, :), :));
pts2d = planePosition(projPointOnPlane(pts, refPlane), refPlane);

% compute 2D OOBB for projected points
box2d = orientedBox(pts2d);

% extract reference points from planar OOBB: the center, and two direction
% vectors
center2d = box2d(1:2);
L1 = box2d(3);
L2 = box2d(4);
markers2d = [0 0; L1/2 0; 0 L2/2];

% orient reference points to 2d basis
theta2d = box2d(5);
rot = createRotation(deg2rad(theta2d));
tra = createTranslation(center2d);
transfo = tra * rot;
markers2d = transformPoint(markers2d, transfo);

% backprojection to 3D space
markers3d = planePoint(refPlane, markers2d);

% compute 3D vectors and center
centerProj = markers3d(1,:);
v1n = normalizeVector3d(markers3d(2,:) - centerProj);
v2n = normalizeVector3d(markers3d(3,:) - centerProj);

% compute rotation matrix and convert to Euler Angles
v3n = crossProduct3d(v1n, v2n);
rotMat = [v1n' v2n' v3n'];
boxAngles = rotation3dToEulerAngles(rotMat);

% create 3D object-oriented bounding box
boxCenter3d = centerProj + v3n * minBreadth/2;
box3d = [boxCenter3d L1 L2 minBreadth boxAngles];
