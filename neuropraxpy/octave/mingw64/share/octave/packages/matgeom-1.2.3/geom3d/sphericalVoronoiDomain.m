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

function poly = sphericalVoronoiDomain(refPoint, neighbors)
%SPHERICALVORONOIDOMAIN Compute a spherical voronoi domain.
%
%   POLY = sphericalVoronoiDomain(GERM, NEIGHBORS)
%   GERM is a 1-by-3 row vector representing cartesian coordinates of a
%   point on the unit sphere (in X, Y Z order)
%   NEIGHBORS is a N-by-3 array representing cartesian coordinates of the
%   germ neighbors. It is expected that NEIGHBORS contains only neighbors
%   that effectively contribute to the voronoi domain.
%
%   Example
%   sphericalVoronoiDomain
%
%   See also
%   drawSphericalPolygon
%
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2010-11-17,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2010 INRA - Cepia Software Platform.

% reference sphere
sphere = [0 0 0 1];

% number of neigbors, and number of sides of the domain
nbSides = size(neighbors, 1);

% compute planes containing separating circles
planes = zeros(nbSides, 9);
for i = 1:nbSides
    planes(i,1:9) = normalizePlane(medianPlane(refPoint, neighbors(i,:)));
end

% allocate memory
lines       = zeros(nbSides, 6);
intersects  = zeros(2 * nbSides, 3);

% compute circle-circle intersections
for i = 1:nbSides
    ind2 = mod(i, nbSides) + 1;
    lines(i,1:6) = intersectPlanes(planes(i,:), planes(ind2,:));
    intersects(2*i-1:2*i,1:3) = intersectLineSphere(lines(i,:), sphere);
end

% keep only points in the same direction than refPoint
ind = dot(intersects, repmat(refPoint, [2 * nbSides 1]), 2) > 0;
poly = intersects(ind,:);
