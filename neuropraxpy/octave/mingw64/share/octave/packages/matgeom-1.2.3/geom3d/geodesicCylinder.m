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

function [geo, geoLength, conGeo, conGeoLength] = geodesicCylinder(pts, cyl, varargin)
%GEODESICCYLINDER computes the geodesic between two points on a cylinder.
%
%   [GEO, GEOLENGTH] = geodesicCylinder(PTS, CYL) computes the geodesic 
%   between the two points PTS projected onto the infinite cylinder CYL.  
%   PTS is a 2-by-3 array, and CYL is a 1-by-7 array. Result is the 
%   polyline GEO (500-by-3 array) [500 = default] containing the  
%   coordinates of the geodesic between two projected points. GEOLENGTH 
%   contains the analytical length of the geodesic.
%
%   [~, ~, CONGEO, CONGEOLENGTH] = geodesicCylinder(PTS, CYL) provides the
%   conjugate geodesic and its analytical length.
%
%   ... = geodesicCylinder(PTS, CYL, 'n', N) defines the number of points
%   representing the geodesic and conjugate geodesic.
%
%   Example
%       demoGeodesicCylinder
%
%   See also
%     drawCylinder, projPointOnCylinder
%
%   Source
%     Based on the script 'geodesic.m' by Lei Wang
%     https://mathworks.com/matlabcentral/fileexchange/6522
%

% ---------
% Author: oqilipo
% Created: 2021-04-17, using R2020b
% Copyright 2021

parser = inputParser;
addRequired(parser, 'pts', @(x) validateattributes(x, {'numeric'},...
    {'size',[2 3],'real','finite','nonnan'}));
addRequired(parser, 'cyl', @(x) validateattributes(x, {'numeric'},...
    {'size',[1 7],'real','finite','nonnan'}));
addParameter(parser,'n',500, @(x) validateattributes(x, {'numeric'},...
    {'scalar','>', 2,'<=', 1e5}));
parse(parser,pts,cyl,varargin{:});
pts = parser.Results.pts;
cyl = parser.Results.cyl;
n = parser.Results.n;

% Radius of the cylinder
cylRadius = cyl(7);

% Project points onto the open (infinite) cylinder
ptProj(1,:) = projPointOnCylinder(pts(1,:), cyl, 'open');
ptProj(2,:) = projPointOnCylinder(pts(2,:), cyl, 'open');

% Create a transformation for the points into the local cylinder coordinate
% system. Align the cylinder axis with the z axis and translate the
% starting point of the cylinder to the origin.
TFM = createRotationVector3d(cyl(4:6)-cyl(1:3), [0 0 1])*createTranslation3d(-cyl(1:3));
% Transform the points.
ptTfm = transformPoint3d(ptProj, TFM);
% Convert the transformed points to cylindrical coordinates.
[ptsTheta, ptsRadius, ptsHeight] = cart2cyl(ptTfm);
assert(ismembertol(ptsRadius(1),ptsRadius(2)))
assert(ismembertol(ptsRadius(1),cylRadius))

% Copy thetas for the conjugate geodesic
ptsTheta(:,:,2) = ptsTheta;
ptsTheta(1,1,2) = ptsTheta(1,1,2) + 2*pi;

geoCyl = nan(n,3,size(ptsTheta,3));
arcLength = nan(1,size(ptsTheta,3));
for t = 1:size(ptsTheta,3)
    [geoCyl(:,:,t), arcLength(t)] = geoCurve(ptsTheta(:,:,t), cylRadius, ptsHeight, n);
end

% Select the shortest geodesic
if arcLength(1) <= arcLength(2)
    % Transform the geodesics back to the global coordinate system
    geo = transformPoint3d(geoCyl(:,:,1), inv(TFM));
    conGeo = transformPoint3d(geoCyl(:,:,2), inv(TFM));
    geoLength = arcLength(1);
    conGeoLength = arcLength(2);
else
    % Transform the geodesics back to the global coordinate system
    geo = transformPoint3d(geoCyl(:,:,2), inv(TFM));
    conGeo = transformPoint3d(geoCyl(:,:,1), inv(TFM));
    geoLength = arcLength(2);
    conGeoLength = arcLength(1);
end

end

function [geo, arcLength] = geoCurve(theta, r, z, n)
% Parametric expression of the geodesic curve
u = linspace(theta(1),theta(2),n)';
geo(:,1) = r*cos(u);
geo(:,2) = r*sin(u);
geo(:,3) = (z(2)-z(1))/(theta(2)-theta(1))*u + (z(1)*theta(2)-z(2)*theta(1))/(theta(2)-theta(1));
if all(isnan(geo(:,3)))
    geo(:,3) = linspace(z(1),z(2),n)';
end
arcLength = sqrt(r^2*(theta(2)-theta(1))^2+(z(2)-z(1))^2);
end
