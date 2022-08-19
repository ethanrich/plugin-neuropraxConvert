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

function [dist, pos] = distancePointLine(point, line)
%DISTANCEPOINTLINE Minimum distance between a point and a line.
%
%   D = distancePointLine(POINT, LINE)
%   Return the euclidean distance between line LINE and point POINT. 
%
%   LINE has the form: [x0 y0 dx dy], and POINT is [x y].
%
%   If LINE is N-by-4 array, result is N-by-1 array computes for each line.
%
%   If POINT is N-by-2, then result is computed for each point.
%
%   If both POINT and LINE are array, result is computed for each couple of
%   point and line, and is returned in a NP-by-NL array, where NP is the
%   number of points, and NL is the number of lines.
%
%
%   See also:
%   lines2d, points2d, distancePoints, distancePointEdge
%
   
% ------
% Author: David Legland
% e-mail: david.legland@nantes.inra.fr
% Created: 2005-06-24
% Copyright 2016 INRA - BIA-BIBS.

%   HISTORY:
%   2012-10-24 rewrite using bsxfun

% direction vector of each line (row vectors)
vx = line(:, 3)';
vy = line(:, 4)';

% squared norm of direction vectors, with a check of validity
delta = (vx .* vx + vy .* vy);
invalidEdges = delta < eps;
delta(invalidEdges) = 1; 

% difference of coordinates between point and line origins
% (NP-by-NE arrays)
dx  = bsxfun(@minus, point(:, 1), line(:, 1)');
dy  = bsxfun(@minus, point(:, 2), line(:, 2)');

% compute position of points projected on the line, by using normalised dot
% product 
% (result is a NP-by-NL array) 
pos = bsxfun(@rdivide, bsxfun(@times, dx, vx) + bsxfun(@times, dy, vy), delta);

% ensure degenerated lines are correclty processed (consider the line
% origin as closest point)
pos(:, invalidEdges) = 0;

% compute distance between point and its projection on the line
dist = hypot(bsxfun(@times, pos, vx) - dx, bsxfun(@times, pos, vy) - dy);


% if size(line, 1)==1 && size(point, 1)>1
%     line = repmat(line, [size(point, 1) 1]);
% end
% 
% if size(point, 1)==1 && size(line, 1)>1
%     point = repmat(point, [size(line, 1) 1]);
% end
% 
% dx = line(:, 3);
% dy = line(:, 4);
% 
% % compute position of points projected on line
% tp = ((point(:, 2) - line(:, 2)).*dy + (point(:, 1) - line(:, 1)).*dx) ./ (dx.*dx+dy.*dy);
% p0 = line(:, 1:2) + [tp tp].*[dx dy];
% 
% 
% % compute distances between points and their projections
% dx = point - p0;
% dist  = sqrt(sum(dx.*dx, 2));



