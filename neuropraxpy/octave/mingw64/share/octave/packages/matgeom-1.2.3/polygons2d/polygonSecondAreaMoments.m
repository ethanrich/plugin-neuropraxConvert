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

function [Ixx, Iyy, Ixy] = polygonSecondAreaMoments(poly)
%POLYGONSECONDAREAMOMENTS Compute second-order area moments of a polygon.
%
%   [IXX, IYY, IXY] = polygonSecondAreaMoments(POLY)
%   Compute the second-order inertia moments of a polygon. The polygon is
%   specified by the N-by-2 list of vertex coordinates.
%
%   Example
%   polygonSecondAreaMoments
%
%   References
%   * http://paulbourke.net/geometry/polygonmesh/
%   * https://en.wikipedia.org/wiki/Second_moment_of_area
%
%   See also
%     polygons2d, polygonEquivalentEllipse, polygonArea, polygonCentroid
 
% ------
% Author: David Legland
% e-mail: david.legland@inra.fr
% Created: 2017-09-08,    using Matlab 9.1.0.441655 (R2016b)
% Copyright 2017 INRA - Cepia Software Platform.

% get vertex coordinates, and recenter polygon
centroid = polygonCentroid(poly);
px = poly(:,1) - centroid(1);
py = poly(:,2) - centroid(2);

% vertex indices
N = length(px);
iNext = [2:N 1];

% compute twice signed area of each triangle
common = px .* py(iNext) - px(iNext) .* py;

% compute each term
Ixx = sum( (py.^2 + py .* py(iNext) + py(iNext).^2) .* common) / 12;
Iyy = sum( (px.^2 + px .* px(iNext) + px(iNext).^2) .* common) / 12;
Ixy = sum( ...
    (px .* py(iNext) + 2 * px .* py + 2 * px(iNext) .* py(iNext) ...
    + px(iNext) .* py ) .* common) / 24;
