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

function [inter, inside]= intersectLinePolygon3d(line, poly)
%INTERSECTLINEPOLYGON3D Intersection point of a 3D line and a 3D polygon.
%
%   INTER = intersectLinePolygon3d(LINE, POLY)
%   Compute coordinates of intersection point between the 3D line LINE and
%   the 3D polygon POLY. LINE is a 1-by-6 row vector containing origin and
%   direction vector of the line, POLY is a Np-by-3 array containing
%   coordinates of 3D polygon vertices.
%   INTER is a 1-by-3 row vector containing coordinates of intersection
%   point, or [NaN NaN NaN] if line and polygon do not intersect.
%
%   INTERS = intersectLinePolygon3d(LINES, POLY)
%   If LINES is a N-by-6 array representing several lines, the result
%   INTERS is a N-by-3 array containing coordinates of intersection of each
%   line with the polygon.
%
%   [INTER INSIDE] = intersectLinePolygon3d(LINE, POLY)
%   Also return a N-by-1 boolean array containing TRUE if the corresponding
%   polygon contains the intersection point.
%
%   Example
%     % Compute intersection between a 3D line and a 3D triangle
%     pts3d = [3 0 0; 0 6 0;0 0 9];
%     line1 = [0 0 0 3 6 9];
%     inter = intersectLinePolygon3d(line1, pts3d)
%     inter =
%           1   2   3
%
%     % keep only valid intersections with several lines
%     pts3d = [3 0 0; 0 6 0;0 0 9];
%     lines = [0 0 0 1 2 3;10 0 0 1 2 3];
%     [inter inside] = intersectLinePolygon3d(line1, pts3d);
%     inter(inside, :)
%     ans = 
%           1   2   3
%
%   See Also
%   intersectLinePolygon, intersectRayPolygon3d, intersectLinePlane
%

% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2011-05-22,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2011 INRA - Cepia Software Platform.

% supporting plane of polygon vertices
plane = createPlane(poly(1:3, :));

% intersection of 3D line with the plane
inter = intersectLinePlane(line, plane);

% project all points on reference plane
pts2d = planePosition(poly, plane);
pInt2d = planePosition(inter, plane);

% need to check polygon orientation
inside = xor(isPointInPolygon(pInt2d, pts2d), polygonArea(pts2d) < 0);

% intersection points outside the polygon are set to NaN
inter(~inside, :) = NaN;
