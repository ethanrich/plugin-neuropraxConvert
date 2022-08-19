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

function varargout = gabrielGraph(pts)
%GABRIELGRAPH  Gabriel Graph of a set of points.
%
%   EDGES = gabrielGraph(PTS)
%   Computes the Gabriel graph of the input set of points PTS. The Gabriel
%   graph is based on the euclidean Delaunay triangulation, and keeps only
%   edges whose circumcircle does not contain any other input point than
%   the edge extremities.
%
%   [NODES, EDGES] = gabrielGraph(PTS)
%   Also returns the initial set of points;
%
%   Example
%     pts = rand(100, 2);
%     edges = gabrielGraph(pts);
%     figure; drawPoint(pts);
%     hold on; axis([0 1 0 1]); axis equal;
%     drawGraph(pts, edges);
%
%   See also
%     graphs, drawGraph, delaunayGraph
%

% ------
% Author: David Legland
% e-mail: david.legland@inrae.fr
% Created: 2012-01-22,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2012 INRA - Cepia Software Platform.

% compute Delaunay triangulation
if verLessThan('matlab', '8.1')
    % Code for versions before R2013a
    dt = DelaunayTri(pts); %#ok<DDELTRI>
else
    % Code for versions R2013a and later
    dt = delaunayTriangulation(pts);
end

% extract edges (N-by-2 array)
eds = dt.edges();

% radius of the circle circumscribed to each edge
rads = edgeLength([pts(eds(:,1), :) pts(eds(:,2), :)]) / 2;

% extract middle point of each edge
midPts = midPoint(pts(eds(:,1), :), pts(eds(:,2), :));

% distance between midpoints and all points
% closest points should be edge vertices
dists = minDistancePoints(midPts, pts);

% geometric tolerance (adapted to point set extent)
tol = max(max(pts) - min(pts)) * eps;

% keep only edges whose circumcircle does not contain any other point
keep = dists >= rads - tol;
edges = eds(keep, :);

% format output depending on number of output arguments
if nargout < 2
    varargout = {edges};
else
    varargout = {pts, edges};
end
