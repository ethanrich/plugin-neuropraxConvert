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

function tri = triangulatePolygon(poly)
%TRIANGULATEPOLYGON Compute a triangulation of the polygon.
%
%   TRI = triangulatePolygon(POLY)
%   Computes a triangulation TRI of the polygon defined by POLY
%   POLY contains the polygon vertices, as a Nv-by-2 array of double. 
%   TRI is a Nt-by-3 array containing indices of vertices forming the
%   triangles. 
%
%   Example
%     % creates a simple polygon and computes its Delaunay triangulation
%     poly = [0 0 ; 10 0;5 10;15 15;5 20;-5 10];
%     figure;drawPolygon(poly); axis equal
%     tri = triangulatePolygon(poly);
%     figure;
%     % patch('Faces', tri, 'Vertices', poly, 'facecolor', 'c');
%     drawMesh(poly, tri, 'facecolor', 'c');
%     axis equal
%
%     % Another example for which constrains were necessary
%     poly2 = [10 10;80 10; 140 20;30 20; 80 30; 140 30; 120 40;10 40];
%     tri2 = triangulatePolygon(poly2);
%     figure; drawMesh(poly2, tri2);
%     hold on, drawPolygon(poly2, 'linewidth', 2);
%     axis equal
%     axis([0 150 0 50])
%
%   See also
%     delaunayTriangulation, drawMesh, patch
%

% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2011-11-25,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2011 INRA - Cepia Software Platform.

% compute constraints
nv = size(poly, 1);
cons = [(1:nv)' [2:nv 1]'];

if verLessThan('matlab', '8.1')
    % Code for versions before R2013a
    
    % delaunay triangulation
    dt = DelaunayTri(poly(:,1), poly(:, 2), cons); %#ok<DDELTRI>
    
    % find which triangles are contained in polygon
    centers = incenters(dt);
    inds = isPointInPolygon(centers, poly);
    
    % keep selected triangles
    tri = dt.Triangulation(inds, :);

else
    % Code for versions R2013a and later

    % delaunay triangulation 
    % dt = DelaunayTri(poly(:,1), poly(:, 2), cons);
    dt = delaunayTriangulation(poly(:,1), poly(:, 2), cons);

    % find which triangles are contained in polygon
    % centers = incenters(dt);
    centers = incenter(dt);
    inds = isPointInPolygon(centers, poly);

    % keep selected triangles
    % tri = dt.Triangulation(inds, :);
    tri = dt.ConnectivityList(inds, :);
end
