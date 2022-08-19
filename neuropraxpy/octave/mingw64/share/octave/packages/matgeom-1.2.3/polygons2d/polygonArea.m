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

function area = polygonArea(poly, varargin)
% Compute the signed area of a polygon.
%
%   A = polygonArea(POINTS);
%   Compute area of a polygon defined by POINTS. POINTS is a N-by-2 array
%   of double containing coordinates of vertices.
%   
%   Vertices of the polygon are supposed to be oriented Counter-Clockwise
%   (CCW). In this case, the signed area is positive.
%   If vertices are oriented Clockwise (CW), the signed area is negative.
%
%   If polygon is self-crossing, the result is undefined.
%
%   Examples
%     % compute area of a simple shape
%     poly = [10 10;30 10;30 20;10 20];
%     area = polygonArea(poly)
%     area = 
%         200
%
%     % compute area of CW polygon
%     area2 = polygonArea(poly(end:-1:1, :))
%     area2 = 
%         -200
%
%     % Computes area of a paper hen
%     x = [0 10 20  0 -10 -20 -10 -10  0];
%     y = [0  0 10 10  20  10  10  0 -10];
%     poly = [x' y'];
%     area = polygonArea(poly)
%     area =
%        400
%
%     % Area of unit square with 25% hole
%     pccw = [0 0; 1 0; 1 1; 0 1];
%     pcw = pccw([1 4 3 2], :) * .5 + .25;
%     polygonArea ([pccw; nan(1,2); pcw])
%     ans =
%        0.75
%
%   References
%   algo adapted from P. Bourke web page
%   http://paulbourke.net/geometry/polygonmesh/
%
%   See also:
%   polygons2d, polygonCentroid, polygonSecondAreaMoments, triangleArea
%

%   ---------
%   author : David Legland 
%   INRA - TPV URPOI - BIA IMASTE
%   created the 05/05/2004.
%

%   HISTORY
%   25/04/2005: add support for multiple polygons
%   12/10/2007: update doc


%% Process special cases

% in case of polygon sets, computes the sum of polygon areas
if iscell(poly)
    area = 0;
    for i = 1:length(poly)
        area = area + polygonArea(poly{i});
    end
    return;
end

% check there are enough points
if size(poly, 1) < 2
    area = 0;
    return;
end

% case of polygons with holes -> computes the sum of areas
if any(isnan(poly))
    area = sum(polygonArea(splitPolygons(poly)));
    return;
end


%% Process single polygons or single rings

% extract coordinates
if nargin == 1
    % polygon given as N-by-2 array
    px = poly(:, 1);
    py = poly(:, 2);
    
elseif nargin == 2
    % poylgon given as two N-by-1 arrays
    px = poly;
    py = varargin{1};
end

% indices of next vertices
N = length(px);
iNext = [2:N 1];

% compute area (vectorized version)
area = sum(px .* py(iNext) - px(iNext) .* py) / 2;
