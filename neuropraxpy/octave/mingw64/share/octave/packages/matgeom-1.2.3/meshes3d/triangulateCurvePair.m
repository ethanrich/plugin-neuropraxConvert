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

function [vertices, facets] = triangulateCurvePair(curve1, curve2)
%TRIANGULATECURVEPAIR Compute triangulation between a pair of 3D open curves.
%
%   [V, F] = testTriangulateCurvePair(CURVE1, CURVE2)
%
%   Example
%     % triangulate a surface patch between two open curves
%     % create two sample curves
%     t = linspace(0, 2*pi, 100);
%     curve1 = [linspace(0, 10, 100)' 5 * sin(t') zeros(100,1)];
%     curve2 = [linspace(0, 10, 100)' 2 * sin(t') 2*ones(100,1)];
%     figure; hold on;
%     drawPolyline3d(curve1, 'b');
%     drawPolyline3d(curve2, 'g');
%     view(3); axis equal;
%     [v, f] = triangulateCurvePair(curve1, curve2);
%     figure; drawMesh(v, f, 'linestyle', 'none');
%     view(3); axis equal
%
%   See also
%     meshes3D, triangulatePolygonPair, meshSurfaceArea
 
% ------
% Author: David Legland
% e-mail: david.legland@inra.fr
% Created: 2017-05-18,    using Matlab 9.1.0.441655 (R2016b)
% Copyright 2017 INRA - Cepia Software Platform.


%% Memory allocation

% number of vertices on each curve
n1 = size(curve1, 1);
n2 = size(curve2, 1);

% allocate the array of facets (each edge of each curve provides a facet)
nFacets = n1 + n2 - 2;
facets = zeros(nFacets, 3);

% look for the closest ends of two curves and reverse the second curve if
% needed
p1 = curve1(1, :);
if distancePoints(p1, curve2(1,:)) > distancePoints(p1, curve2(end,:))
    curve2 = curve2(end:-1:1,:);
end
currentIndex1 = 1;
currentIndex2 = 1;

% concatenate vertex coordinates for creating mesh
vertices = [curve1 ; curve2];



%% Main iteration
% For each diagonal, consider the two possible facets (one for each 'next'
% vertex on each curve), each create current facet according to the closest
% one. 
% Then update current diagonal for next iteration.

for i = 1:nFacets
    nextIndex1 = mod(currentIndex1, n1) + 1;
    nextIndex2 = mod(currentIndex2, n2) + 1;
    
    % compute lengths of diagonals
    dist1 = distancePoints(curve1(currentIndex1, :), curve2(nextIndex2,:));
    dist2 = distancePoints(curve1(nextIndex1, :), curve2(currentIndex2,:));
    
    if dist1 < dist2
        % keep current vertex of curve1, use next vertex on curve2
        facet = [currentIndex1 currentIndex2+n1 nextIndex2+n1];
        currentIndex2 = nextIndex2;
    else
        % keep current vertex of curve2, use next vertex on curve1
        facet = [currentIndex1 currentIndex2+n1 nextIndex1];
        currentIndex1 = nextIndex1;
    end
    
    % create the facet
    facets(i, :) = facet;
end

