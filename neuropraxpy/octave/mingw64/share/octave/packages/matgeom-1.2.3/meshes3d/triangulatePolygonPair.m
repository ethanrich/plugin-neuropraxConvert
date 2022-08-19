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

function [vertices, faces] = triangulatePolygonPair(poly1, poly2, varargin)
% Compute triangulation between a pair of 3D closed curves.
%
%   [V, F] = triangulatePolygonPair(POLY1, POLY2)
%
%   [V, F] = triangulatePolygonPair(..., 'recenter', FLAG)
%   Where FLAG is a boolean, specifies whether the second curve should be
%   translated to have the same centroid as the first curve. This can
%   improve mathcing of vertices. Default is true.
%
%
%   Example
%     % triangulate a surface patch between two ellipses
%     % create two sample curves
%     poly1 = ellipseToPolygon([50 50 40 20 0], 36);
%     poly2 = ellipseToPolygon([50 50 40 20 60], 36);
%     poly1 = poly1(1:end-1,:);
%     poly2 = poly2(1:end-1,:);
%     % transform to 3D polygons / curves
%     curve1 = [poly1 10*ones(size(poly1, 1), 1)];
%     curve2 = [poly2 20*ones(size(poly2, 1), 1)];
%     % draw as 3D curves
%     figure(1); clf; hold on;
%     drawPolygon3d(curve1, 'b'); drawPoint3d(curve1, 'bo');
%     drawPolygon3d(curve2, 'g'); drawPoint3d(curve2, 'go');
%     view(3); axis equal;
%     [vertices, faces] = triangulatePolygonPair(curve1, curve2);
%     % display the resulting mesh
%     figure(2); clf; hold on;
%     drawMesh(vertices, faces);
%     drawPolygon3d(curve1, 'color', 'b', 'linewidth', 2);
%     drawPolygon3d(curve2, 'color', 'g', 'linewidth', 2);
%     view(3); axis equal;
%
%   See also
%     meshes3D, triangulateCurvePair, meshSurfaceArea
%
 
% ------
% Author: David Legland
% e-mail: david.legland@inra.fr
% Created: 2017-05-18,    using Matlab 9.1.0.441655 (R2016b)
% Copyright 2017 INRA - Cepia Software Platform.


%% Settings

recenterFlag = true;
while length(varargin) > 1
    pname = varargin{1};
    if strcmpi(pname, 'recenter')
        recenterFlag = varargin{2};
    else
        error('Unknown parameter name: %s', pname);
    end
    varargin(1:2) = [];
end


%% Memory allocation

% concatenate vertex coordinates for creating mesh
vertices = [poly1 ; poly2];

% number of vertices on each polygon
n1 = size(poly1, 1);
n2 = size(poly2, 1);

% allocate the array of facets (each edge of each polygon provides a facet)
nFaces = n1 + n2;
faces = zeros(nFaces, 3);


% Translate the second polygon such that the centroids of the bounding
% boxes coincide. This is expected to improve the matching of the two
% curves.
if recenterFlag
    box1 = boundingBox3d(poly1);
    box2 = boundingBox3d(poly2);
    center1 = (box1(2:2:end) + box1(1:2:end-1)) / 2;
    center2 = (box2(2:2:end) + box2(1:2:end-1)) / 2;
    vecTrans = center1 - center2;
    trans = createTranslation3d(vecTrans);
    poly2 = transformPoint3d(poly2, trans);
end


%% Init iteration

% find the pair of points with smallest distance.
% This will be the current diagonal.
[dists, inds] = minDistancePoints(poly1, poly2);
[dummy, ind1] = min(dists); %#ok<ASGLU>
ind2 = inds(ind1);

% consider two consecutive vertices on each polygon
currentIndex1 = ind1;
currentIndex2 = ind2;


%% Main iteration
% For each diagonal, consider the two possible facets (one for each 'next'
% vertex on each polygon), each create current facet according to the
% closest one. 
% Then update current diagonal for next iteration.

for iFace = 1:nFaces
    nextIndex1 = mod(currentIndex1, n1) + 1;
    nextIndex2 = mod(currentIndex2, n2) + 1;
    
    % compute lengths of diagonals
    dist1 = distancePoints(poly1(currentIndex1, :), poly2(nextIndex2,:));
    dist2 = distancePoints(poly1(nextIndex1, :), poly2(currentIndex2,:));
    
    if dist1 < dist2
        % keep current vertex of curve1, use next vertex on curve2
        face = [currentIndex1 currentIndex2+n1 nextIndex2+n1];
        currentIndex2 = nextIndex2;
    else
        % keep current vertex of curve2, use next vertex on curve1
        face = [currentIndex1 currentIndex2+n1 nextIndex1];
        currentIndex1 = nextIndex1;
    end
    
    % create the facet
    faces(iFace, :) = face;
end

