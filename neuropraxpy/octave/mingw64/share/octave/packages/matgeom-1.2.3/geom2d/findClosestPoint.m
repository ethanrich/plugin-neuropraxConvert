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

function [index, minDist] = findClosestPoint(coord, points)
%FINDCLOSESTPOINT Find index of closest point in an array.
%
%   INDEX = findClosestPoint(POINT, POINTARRAY)
%
%   [INDEX, MINDIST] = findClosestPoint(POINT, POINTARRAY)
%   Also returns the distance between POINT and closest point in
%   POINTARRAY.
%
%   Example
%     pts = rand(10, 2);
%     findClosestPoint(pts(4, :), pts)
%     ans =
%         4
%
%   See also
%    points2d, minDistancePoints, distancePoints
%
 
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2015-02-24,    using Matlab 8.4.0.150421 (R2014b)
% Copyright 2015 INRA - Cepia Software Platform.
% number of points

% number of point in first input to process
np = size(coord, 1);

% allocate memory for result
index = zeros(np, 1);
minDist = zeros(np, 1);

for i = 1:np
    % compute squared distance between current point and all point in array
    dist = sum(bsxfun(@minus, coord(i,:), points) .^ 2, 2);
    
    % keep index of closest point
    [minDist(i), index(i)] = min(dist);
end
