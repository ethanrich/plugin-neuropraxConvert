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

function point = polygonPoint(poly, pos)
%POLYGONPOINT Extract a point from a polygon.
%
%   POINT = polygonPoint(POLYGON, POS)
%   
%
%   Example
%   polygonPoint
%
%   See also
%   polygons2d, polylinePoint
%

% ------
% Author: David Legland
% e-mail: david.legland@nantes.inra.fr
% Created: 2009-04-30,    using Matlab 7.7.0.471 (R2008b)
% Copyright 2009 INRA - Cepia Software Platform.

% eventually copy first point at the end to ensure closed polygon
if sum(poly(end, :) == poly(1,:))~=2
    poly = [poly; poly(1,:)];
end

% number of points to compute
nPoints = length(pos(:));

% number of vertices in polygon
Nv = size(poly, 1)-1;

% allocate memory results
point = zeros(nPoints, 2);

% iterate on points
for i = 1:nPoints
    % compute index of edge (between 0 and Nv)
    ind = floor(pos(i));
    
    % special case of last point of polyline
    if ind==Nv
        point(i,:) = poly(end,:);
        continue;
    end
    
    % format index to ensure being on polygon
    ind = min(max(ind, 0), Nv-1);
    
    % position on current edge
    t = min(max(pos(i)-ind, 0), 1);
    
    % parameters of current edge
    x0 = poly(ind+1, 1);
    y0 = poly(ind+1, 2);
    dx = poly(ind+2,1)-x0;
    dy = poly(ind+2,2)-y0;
    
    % compute position of current point
    point(i, :) = [x0+t*dx, y0+t*dy];
end
