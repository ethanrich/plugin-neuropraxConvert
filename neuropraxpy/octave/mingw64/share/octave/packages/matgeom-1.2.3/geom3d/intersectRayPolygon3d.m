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

function [inter, inside]= intersectRayPolygon3d(ray, poly)
%INTERSECTRAYPOLYGON3D Intersection point of a 3D ray and a 3D polygon.
%
%   INTER = intersectRayPolygon3d(RAY, POLY)
%   Compute coordinates of intersection point between the 3D ray RAY and
%   the 3D polygon POLY. RAY is a 1-by-6 row vector containing origin and
%   direction vector of the ray, POLY is a Np-by-3 array containing
%   coordinates of 3D polygon vertices.
%   INTER is a 1-by-3 row vector containing coordinates of intersection
%   point, or [NaN NaN NaN] if ray and polygon do not intersect.
%
%   INTERS = intersectRayPolygon3d(RAYS, POLY)
%   If RAYS is a N-by-6 array representing several rays, the result
%   INTERS is a N-by-3 array containing coordinates of intersection of each
%   ray with the polygon.
%
%   [INTER INSIDE] = intersectRayPolygon3d(RAY, POLY)
%   Also return a N-by-1 boolean array containing TRUE if both the polygon
%   and the corresponding ray contain the intersection point.
%
%   Example
%     % Compute intersection between a 3D ray and a 3D triangle
%     pts3d = [3 0 0; 0 6 0;0 0 9];
%     ray1 = [0 0 0 3 6 9];
%     inter = intersectRayPolygon3d(ray1, pts3d)
%     inter =
%           1   2   3
%
%     % keep only valid intersections with several rays
%     pts3d = [3 0 0; 0 6 0;0 0 9];
%     rays = [0 0 0 3 6 9;10 0 0 1 2 3;3 6 9 3 6 9];
%     [inter inside] = intersectRayPolygon3d(rays, pts3d);
%     inter(inside, :)
%     ans = 
%           1   2   3
%
%   See Also
%   intersectRayPolygon, intersectLinePolygon3d, intersectLineTriangle3d
%

% ------
% Author: David Legland
% e-mail: david.legland@inra.fr
% Created: 2011-05-22,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2011 INRA - Cepia Software Platform.

% supporting plane of polygon vertices
plane   = createPlane(poly(1:3, :));

% intersection of 3D ray with the plane
inter   = intersectLinePlane(ray, plane);

% project all points on reference plane
pts2d   = planePosition(projPointOnPlane(poly, plane), plane);
pInt2d  = planePosition(projPointOnPlane(inter, plane), plane);

% need to check polygon orientation
inPoly  = xor(isPointInPolygon(pInt2d, pts2d), polygonArea(pts2d) < 0);
onRay   = linePosition3d(inter, ray) >= 0;
inside  = inPoly & onRay;

% intersection points outside the polygon are set to NaN
inter(~inside, :) = NaN;
