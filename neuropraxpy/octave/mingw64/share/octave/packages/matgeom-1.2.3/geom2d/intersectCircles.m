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

function points = intersectCircles(circle1, circle2)
%INTERSECTCIRCLES Intersection points of two circles.
%
%   POINTS = intersectCircles(CIRCLE1, CIRCLE2)
%   Computes the intersetion point of the two circles CIRCLE1 and CIRCLE1.
%   Both circles are given with format: [XC YC R], with (XC,YC) being the
%   coordinates of the center and R being the radius.
%   POINTS is a 2-by-2 array, containing coordinate of an intersection
%   point on each row. 
%   In the case of tangent circles, the intersection is returned twice. It
%   can be simplified by using the 'unique' function.
%
%   Example
%     % intersection points of two distant circles
%     c1 = [0  0 10];
%     c2 = [10 0 10];
%     pts = intersectCircles(c1, c2)
%     pts =
%         5   -8.6603
%         5    8.6603
%
%     % intersection points of two tangent circles
%     c1 = [0  0 10];
%     c2 = [20 0 10];
%     pts = intersectCircles(c1, c2)
%     pts =
%         10    0
%         10    0
%     pts2 = unique(pts, 'rows')
%     pts2 = 
%         10    0
%
%   References
%   http://local.wasp.uwa.edu.au/~pbourke/geometry/2circle/
%   http://mathworld.wolfram.com/Circle-CircleIntersection.html
%
%   See also
%   circles2d, intersectLineCircle, radicalAxis
%
%
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2011-01-20,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2011 INRA - Cepia Software Platform.

%   HISTORY
%   2011-06-06 add support for multiple inputs


% adapt sizes of inputs
n1 = size(circle1, 1);
n2 = size(circle2, 1);
if n1 ~= n2
    if n1 > 1 && n2 == 1
        circle2 = repmat(circle2, n1, 1);
    elseif n2 > 1 && n1 == 1
        circle1 = repmat(circle1, n2, 1);
    else 
        error('Both input should have same number of rows');
    end
end
   
% extract center and radius of each circle
center1 = circle1(:, 1:2);
center2 = circle2(:, 1:2);
r1 = circle1(:,3);
r2 = circle2(:,3);

% allocate memory for result
nPoints = length(r1);
points = NaN * ones(2*nPoints, 2);

% distance between circle centers
d12 = distancePoints(center1, center2, 'diag');

% get indices of circle couples with intersections
inds = d12 >= abs(r1 - r2) & d12 <= (r1 + r2);

if sum(inds) == 0
    return;
end

% angle of line from center1 to center2
angle = angle2Points(center1(inds,:), center2(inds,:));

% position of intermediate point, located at the intersection of the
% radical axis with the line joining circle centers
d1m  = d12(inds) / 2 + (r1(inds).^2 - r2(inds).^2) ./ (2 * d12(inds));
tmp = polarPoint(center1(inds, :), d1m, angle);

% distance between intermediate point and each intersection point
h   = sqrt(r1(inds).^2 - d1m.^2);

% indices of valid intersections
inds2 = find(inds)*2;
inds1 = inds2 - 1;

% create intersection points
points(inds1, :) = polarPoint(tmp, h, angle - pi/2);
points(inds2, :) = polarPoint(tmp, h, angle + pi/2);
