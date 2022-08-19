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

function dist = distancePolygonsNoCross(poly1, poly2)
%DISTANCEPOLYGONSNOCROSS Compute the shortest distance between 2 polygons.
%
%   DIST = distancePolygonsNoCross(POLY1, POLY2)
%   Computes the shortest distance between the boundaries of the two
%   polygons, assuming they do not cross. 
%   Each polygon is given by a N-by-2 array containing the vertex
%   coordinates.
%
%   If the polygons may cross, it is necessary to use the
%   'distancePolygons' function, that adds a potentially costly test on the
%   intersection.
%
%   Example
%     % Computes the distance between a square and a triangle
%     poly1 = [10 10;20 10;20 20;10 20];
%     poly2 = [30 20;50 20;40 45];
%     distancePolygons(poly1, poly2)
%     ans =
%         10
%
%   See also
%   polygons2d, distancePolygons, distancePolylines, distancePointPolygon
%

% ------
% Author: David Legland
% e-mail: david.legland@nantes.inra.fr
% Created: 2009-06-17,    using Matlab 7.7.0.471 (R2008b)
% Copyright 2009 INRA - Cepia Software Platform.

% compute distance of each vertex of a polygon to the other polygon
dist1   = min(distancePointPolygon(poly1, poly2));
dist2   = min(distancePointPolygon(poly2, poly1));

% keep the minimum of the two distances
dist = min(dist1, dist2);
