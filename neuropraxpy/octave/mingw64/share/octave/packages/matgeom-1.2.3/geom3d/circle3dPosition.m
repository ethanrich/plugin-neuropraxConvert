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

function theta = circle3dPosition(point, circle)
%CIRCLE3DPOSITION Return the angular position of a point on a 3D circle.
%
%   POS = circle3dPosition(POINT, CIRCLE)
%   Returns angular position of point on the circle, in degrees, between 0
%   and 360.
%   with POINT: [xp yp zp]
%   and CIRCLE: [X0 Y0 Z0 R THETA PHI] or [X0 Y0 Z0 R THETA PHI PSI]
%   (THETA being the colatitude, and PHI the azimut)
%
%   See also:
%   circles3d, circle3dOrigin, circle3dPoint
%
%   ---------
%   author : David Legland 
%   INRA - TPV URPOI - BIA IMASTE
%   created the 21/02/2005
%

%   HISTORY
%   27/06/2007: change 3D angle convention
%   2011-06-21 use degrees for angles


% get center and radius
xc = circle(:,1);
yc = circle(:,2);
zc = circle(:,3);

% get angle of normal
theta   = circle(:,5);
phi     = circle(:,6);

% find origin of the circle
ori     = circle3dOrigin(circle);

% normal vector of the supporting plane (cartesian coords)
vn      = sph2cart2d([theta phi]);

% create plane containing the circle
plane   = createPlane([xc yc zc], vn);

% find position of point on the circle plane
pp0     = planePosition(ori,    plane);
pp      = planePosition(point,  plane);

% compute angles in the planes
theta0  = mod(atan2(pp0(:,2), pp0(:,1)) + 2*pi, 2*pi);
theta   = mod(atan2(pp(:,2), pp(:,1)) + 2*pi - theta0, 2*pi);

% convert to degrees
theta = theta * 180 / pi;
