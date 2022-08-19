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

function point2 = projPointOnCircle3d(point, circle)
%PROJPOINTONCIRCLE3D Project a 3D point onto a 3D circle.
%
%   PT2 = projPointOnCircle3d(PT, CIRCLE).
%   Computes the projection of 3D point PT onto the 3D circle CIRCLE. 
%   
%   Point PT is a N-by-3 array, and CIRCLE is a 1-by-7 array.
%   Result PT2 is a N-by-3 array, containing coordinates of projections of
%   PT onto the circle CIRCLE. 
%
%   See also
%   projPointOnLine3d, projPointOnPlane
%
%   Source
%   https://www.geometrictools.com/Documentation/DistanceToCircle3.pdf
%
% ---------
% Author: oqilipo
% Created: 2020-10-12
% Copyright 2020
%

center = circle(1:3);
radius = circle(4);

% Compute transformation from local basis to world basis
TFM = localToGlobal3d(center, circle(5), circle(6), circle(7));

% Create circle plane
circlePlaneNormal = transformVector3d([0 0 1], TFM);
circlePlane = createPlane(center, circlePlaneNormal);

% Project point on circle plane
PTonCP = projPointOnPlane(point, circlePlane);

% Calculate vector from the projected point to the center of the circle
PTtoCenter = normalizeVector3d(circle(1:3) - PTonCP);

% Calculate final point
point2 = PTonCP + PTtoCenter.*(distancePoints3d(PTonCP, center) - radius);

% Take an arbitrary point of the circle if the point is the center of the circle
if any(all(isnan(point2),2))
    point2(all(isnan(point2),2),:) = center + normalizeVector3d(circlePlane(4:6))*radius;
end
% Take an arbitrary point of the circle if the point lies on the normal of the circle plane
if any(sum(PTtoCenter == 0,2) == 2)
    point2(sum(PTtoCenter == 0,2) == 2,:) = center + normalizeVector3d(circlePlane(4:6))*radius;
end
end
