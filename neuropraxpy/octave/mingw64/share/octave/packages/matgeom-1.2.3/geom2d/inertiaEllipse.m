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

function ell = inertiaEllipse(points)
%INERTIAELLIPSE Inertia ellipse of a set of points.
%
%   Note: Deprecated! Use equivalentEllipse instead.
%
%   ELL = inertiaEllipse(PTS);
%   where PTS is a N*2 array containing coordinates of N points, computes
%   the inertia ellipse of the set of points.
%
%   The result has the form:
%   ELL = [XC YC A B THETA],
%   with XC and YC being the center of mass of the point set, A and B are
%   the lengths of the inertia ellipse (see below), and THETA is the angle
%   of the main inertia axis with the horizontal (counted in degrees
%   between 0 and 180). 
%   A and B are the standard deviations of the point coordinates when
%   ellipse is aligned with the principal axes.
%
%   Example
%   pts = randn(100, 2);
%   pts = transformPoint(pts, createScaling(5, 2));
%   pts = transformPoint(pts, createRotation(pi/6));
%   pts = transformPoint(pts, createTranslation(3, 4));
%   ell = inertiaEllipse(pts);
%   figure(1); clf; hold on;
%   drawPoint(pts);
%   drawEllipse(ell, 'linewidth', 2, 'color', 'r');
%
%   See also
%     equivalentEllipse
%

% ------
% Author: David Legland
% e-mail: david.legland@inra.fr
% Created: 2008-02-21,    using Matlab 7.4.0.287 (R2007a)
% Copyright 2008 INRA - BIA PV Nantes - MIAJ Jouy-en-Josas.

% HISTORY
% 2009-07-29 take into account ellipse orientation
% 2011-03-12 rewrite using inertia moments

% deprecation warning
warning('geom2d:deprecated', ...
    [mfilename ' is deprecated, use ''equivalentEllipse'' instead']);

% ellipse center
xc = mean(points(:,1));
yc = mean(points(:,2));

% recenter points
x = points(:,1) - xc;
y = points(:,2) - yc;

% number of points
n = size(points, 1);

% inertia parameters
Ixx = sum(x.^2) / n;
Iyy = sum(y.^2) / n;
Ixy = sum(x.*y) / n;

% compute ellipse semi-axis lengths
common = sqrt( (Ixx - Iyy)^2 + 4 * Ixy^2);
ra = sqrt(2) * sqrt(Ixx + Iyy + common);
rb = sqrt(2) * sqrt(Ixx + Iyy - common);

% compute ellipse angle in degrees
theta = atan2(2 * Ixy, Ixx - Iyy) / 2;
theta = rad2deg(theta);

% create the resulting inertia ellipse
ell = [xc yc ra rb theta];
