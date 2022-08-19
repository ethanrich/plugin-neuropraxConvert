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

function [d, pt1, pt2] = distanceLines3d(line1, line2)
%DISTANCELINES3D Minimal distance between two 3D lines.
%
%   D = distanceLines3d(LINE1, LINE2);
%   Returns the distance between line LINE1 and the line LINE2, given as:
%   LINE1 : [x0 y0 z0 dx dy dz] (or M-by-6 array)
%   LINE2 : [x0 y0 z0 dx dy dz] (or N-by-6 array)
%   D     : (positive) array M-by-N
%
%   [D, PT1, PT2] = distanceLines3d(LINE1, LINE2);
%   Also returns the points located on LINE1 and LINE2 corresponding to the
%   shortest distance. 
%   One should get the following:
%   distancePoints3d(PT1, PT2) - D == 0
%
%
%   Example
%     line1 = [2 3 4 0 1 0];
%     line2 = [8 8 8 0 0 1];
%     distanceLines3d(line1, line2)
%     ans = 
%         6.0000
%
%   See also:
%   lines3d, distancePoints3d
%
%   ---------
%   authors: Brandon Baker, oqilipo, David Legland
%   created January 19, 2011
%

% number of points of each array
n1 = size(line1, 1);
n2 = size(line2, 1);

if nargout <= 1
    % express line coordinate as n1-by-n2 arrays
    v1x = repmat(line1(:,4), [1 n2]);
    v1y = repmat(line1(:,5), [1 n2]);
    v1z = repmat(line1(:,6), [1 n2]);
    p1x = repmat(line1(:,1), [1 n2]);
    p1y = repmat(line1(:,2), [1 n2]);
    p1z = repmat(line1(:,3), [1 n2]);

    v2x = repmat(line2(:,4)', [n1 1]);
    v2y = repmat(line2(:,5)', [n1 1]);
    v2z = repmat(line2(:,6)', [n1 1]);
    p2x = repmat(line2(:,1)', [n1 1]);
    p2y = repmat(line2(:,2)', [n1 1]);
    p2z = repmat(line2(:,3)', [n1 1]);

    % calculates distance for each set of lines
    vcross = cross([v1x(:) v1y(:) v1z(:)], [v2x(:) v2y(:) v2z(:)]);
    num = ([p1x(:) p1y(:) p1z(:)] - [p2x(:) p2y(:) p2z(:)]) .* vcross;
    t1 = sum(num,2);
    d = abs(t1) ./ (vectorNorm3d(vcross) + eps);
    
    % returns result as n1-by-n2 array
    d = reshape(d, n1, n2);

else
    % check input dimension, as we need to be able to match each pair of
    % lines
    if n1 ~= n2
        error('geom3d:distanceLines3d:IllegalInputArgument', ...
            'when output points are requested, number of lines should be the same');
    end
    
    p1 = line1(:, 1:3);
    p2 = line2(:, 1:3);
    dp = p2 - p1;
    v1 = line1(:, 4:6);
    v2 = line2(:, 4:6);

    % compute distance
    vcross = cross(v1, v2, 2);
    num = dp .* vcross;
    t1 = sum(num, 2);
    d = abs(t1) ./ (vectorNorm3d(vcross) + eps);

    % precomputations
    a = dot(v1, v1, 2);
    b = dot(v1, v2, 2);
    e = dot(v2, v2, 2);
    den = a.*e - b.*b; % 0, if lines are parallel
    
    % vector between origin of both lines
    r = line1(:,1:3) - line2(:,1:3);
    
    % solve linear system
    c = dot(v1, r, 2);
    f = dot(v2, r, 2);
    s = (b .* f - c .* e) ./ den;
    t = (a .* f - c .* b) ./ den;

    % convert to coordinates of points on lines
    pt1 = line1(:,1:3) + v1 .* s;
    pt2 = line2(:,1:3) + v2 .* t;
end
