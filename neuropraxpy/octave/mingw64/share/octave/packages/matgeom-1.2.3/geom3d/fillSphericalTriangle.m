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

function varargout = fillSphericalTriangle(sphere, p1, p2, p3, varargin)
%FILLSPHERICALTRIANGLE Fill a triangle on a sphere.
%
%   fillSphericalTriangle(SPHERE, PT1, PT2, PT3);
%
%
%   See also
%   fillSphericalPolygon, drawSphericalTriangle, drawSphere
%
%   ---------
%   author : David Legland 
%   INRA - TPV URPOI - BIA IMASTE
%   created the 22/02/2005
%

%   HISTORY
%   27/06/2007 manage spheres other than origin
%   30/10/2008 replace intersectPlaneLine by intersectLinePlane
%   2012-02-09 rename as fillSphericalTriangle

% extract data of the sphere
ori = sphere(:, 1:3);
r   = sphere(4);

% extract direction vectors for each point
v1  = normalizeVector3d(p1 - ori);
v2  = normalizeVector3d(p2 - ori);
v3  = normalizeVector3d(p3 - ori);

% create a plane tangent to the sphere containing first point
plane = createPlane(v1, v1);

% position on the plane of the direction vectors
pp2 = planePosition(intersectLinePlane([ori v2], plane), plane);
pp3 = planePosition(intersectLinePlane([ori v3], plane), plane);

% create rough parametrization with 2 variables
nTri = 5;
s  = linspace(0, 1, nTri);
t  = linspace(0, 1, nTri);
ns = length(s);
nt = length(t);
s  = repmat(s, [nt, 1]);
t  = repmat(t', [1, ns]);

% convert to plane coordinates
xp = s * pp2(1) + t .* (1-s) * pp3(1);
yp = s * pp2(2) + t .* (1-s) * pp3(2);

% convert to 3D coordinates (still on the 3D plane)
x  = plane(1) * ones(size(xp)) + plane(4) * xp + plane(7) * yp - ori(1);
y  = plane(2) * ones(size(xp)) + plane(5) * xp + plane(8) * yp - ori(2);
z  = plane(3) * ones(size(xp)) + plane(6) * xp + plane(9) * yp - ori(3);

% project on the sphere
norm = hypot(hypot(x, y), z);
xn = x ./ norm * r + ori(1);
yn = y ./ norm * r + ori(2);
zn = z ./ norm * r + ori(3);


if nargout == 0
    % simply display the patch
    surf(xn, yn, zn, 'FaceColor', 'g', 'EdgeColor', 'none', varargin{:});
    
elseif nargout == 1
    % display the patch and return a handle
    h = surf(xn, yn, zn, 'FaceColor', 'g', 'EdgeColor', 'none', varargin{:});
    varargout = {h};
    
elseif nargout == 3
    % If 3 outputs are required, return patch vertex coordinates
    varargout = {x, y, z};
end
