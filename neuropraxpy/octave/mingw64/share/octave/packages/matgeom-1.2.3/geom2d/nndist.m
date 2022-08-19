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

function [dists, neighInds] = nndist(points)
%NNDIST Nearest-neighbor distances of each point in a set.
%
%   DISTS = nndist(POINTS)
%   Returns the distance to the nearest neighbor of each point in an array
%   of points.
%   POINTS is an array of points, NP-by-ND.
%   DISTS is a NP-by-1 array containing the distances to the nearest
%   neighbor.
%
%   This functions first computes the Delaunay triangulation of the set of
%   points, then search for nearest distance in the set of each vertex
%   neighbors. This reduces the overall complexity, but difference was
%   noticed only for large sets (>10000 points)
%
%   Example
%     % Display Stienen diagram of a set of random points in unit square
%     pts = rand(100, 2);
%     [dists, inds] = nndist(pts);
%     figure; drawPoint(pts, 'k.');
%     hold on; drawCircle([pts dists/2], 'b');
%     axis equal; axis([-.1 1.1 -.1 1.1]);
%     % also display edges
%     drawEdge([pts pts(inds, :)], 'b');
%
%   See also
%     points2d, distancePoints, minDistancePoints, findPoint
%

% ------
% Author: David Legland
% e-mail: david.legland@inra.fr
% Created: 2011-12-01,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2011 INRA - Cepia Software Platform.

% number of points
n = size(points, 1);

% allocate memory
dists = zeros(n, 1);
neighInds = zeros(n, 1);

% in case of few points, use direct computation
if n < 3
    inds = 1:n;
    for i = 1:n
        % compute minimal distance
        [dists(i), indN] = minDistancePoints(points(i,:), points(inds~=i, :));
        if indN >= i
            neighInds(i) = inds(indN) + 1;
        else
            neighInds(i) = inds(indN);
        end
    end
    return;
end

% use Delaunay Triangulation to facilitate computations
DT = delaunay (points);

% compute distance to nearest neighbor of each point in the pattern
for i = 1:n
    % find indices of neighbor vertices in Delaunay Triangulation.
    % this set contains the nearest neighbor
    inds = unique(DT(sum(DT == i, 2) > 0, :));
    inds = inds(inds~=i);
    
    % compute minimal distance 
    [dists(i), indN] = min(distancePoints(points(i,:), points(inds, :)));
    neighInds(i) = inds(indN);
end
