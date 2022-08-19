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

function elli = polygonInertiaEllipse(poly)
%POLYGONINERTIAELLIPSE Compute ellipse with same inertia moments as polygon.
%
%   ELLI = polygonInertiaEllipse(POLY)
%
%   Example
%     % convert an ellipse to polygon, and check that inertia ellipse is
%     % close to original ellipse
%     elli = [50 50 50 30 20];
%     poly = ellipseToPolygon(elli, 1000);
%     polygonInertiaEllipse(poly)
%     ans =
%        50.0000   50.0000   49.9998   29.9999   20.0000
%
%     % compute inertia ellipse of more complex figure
%     img = imread('circles.png');
%     img = imfill(img, 'holes');
%     figure; imshow(img); hold on;
%     B = bwboundaries(img);
%     poly = B{1}(:,[2 1]);
%     drawPolygon(poly, 'r');
%     elli = polygonInertiaEllipse(poly);
%     drawEllipse(elli, 'color', 'g', 'linewidth', 2);
%
%
%   See also
%     polygons2d, polygonSecondAreaMoments, polygonCentroid, inertiaEllipse
%     ellipseToPolygon
%
 
% ------
% Author: David Legland
% e-mail: david.legland@inra.fr
% Created: 2017-09-08,    using Matlab 9.1.0.441655 (R2016b)
% Copyright 2017 INRA - Cepia Software Platform.

warning('MatGeom:deprecated', ...
    'function ''polygonInertiaEllipse'' is obsolete, use ''polygonEquivalentEllipse'' instead');

% first re-center the polygon
centroid = polygonCentroid(poly);
poly = bsxfun(@minus, poly, centroid);

% compute non-normalized inertia moments
[Ix, Iy, Ixy] = polygonSecondAreaMoments(poly);

% noralaize with polygon area
area = polygonArea(poly);
Ix = Ix / area;
Iy = Iy / area;
Ixy = Ixy / area;

% compute ellipse semi-axis lengths
common = sqrt( (Ix - Iy)^2 + 4 * Ixy^2);
ra = sqrt(2) * sqrt(Ix + Iy + common);
rb = sqrt(2) * sqrt(Ix + Iy - common);

% compute ellipse angle and convert into degrees
% (different formula from the inertiaEllipse function, as the definition
% for Ix and Iy do not refer to same axes)
theta = atan2(2 * Ixy, Iy - Ix) / 2;
theta = theta * 180 / pi;

% compute centroid and concatenate results into ellipse format
elli = [centroid ra rb theta];
