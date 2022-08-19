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

function vect = polygonOuterNormal(poly, iVertex)
% Outer normal vector for a given vertex(ices).
%
%   NV = polygonOuterNormal(POLY, VIND)
%   Where POLY is a polygon and VIND is the index of a vertex, returns the
%   outer normal vector of the specified vertex.
%   The normal is computed by averaging the tangent vectors of the two
%   neighbor edges, i.e. by computing a finite difference of the neighbor
%   vertices.
%   
%   NV = polygonOuterNormal(POLY)
%   Returns an array with as many vectors as the number of vertices of the
%   input polygon, containing the outer normal of each vertex.
%
%
%   Example
%     % compute outer normals to an ellipse
%     elli = [50 50 40 20 30];
%     poly = ellipseToPolygon(elli, 200);
%     figure; hold on;
%     drawPolygon(poly, 'b'); axis equal; axis([0 100 10 90]);
%     inds = 1:10:200; pts = poly(inds, :); drawPoint(pts, 'bo')
%     vect = polygonOuterNormal(poly, inds);
%     drawVector(pts, vect*10, 'b');
%
%   See also
%     polygons2d, polygonPoint, polygonNormalAngle
%
 
% ------
% Author: David Legland
% e-mail: david.legland@inrae.fr
% Created: 2017-11-23,    using Matlab 8.6.0.267246 (R2015b)
% Copyright 2017 INRA - Cepia Software Platform.

% number of vertices
nv = size(poly, 1);

% if indices not specified, compute for all vertices
if nargin == 1
    iVertex = 1:nv;
end

% allocate memory
vect = zeros(length(iVertex), 2);

% compute normal vector of each result vertex
for i = 1:length(iVertex)
    iNext = mod(iVertex(i), nv) + 1;
    iPrev = mod(iVertex(i)-2, nv) + 1;
    tangent = (poly(iNext,:) - poly(iPrev,:)) / 2;
    vect(i,:) = [tangent(2) -tangent(1)];
end
