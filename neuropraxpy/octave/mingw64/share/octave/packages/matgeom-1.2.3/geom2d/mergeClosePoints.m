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

function points = mergeClosePoints(points, varargin)
%MERGECLOSEPOINTS Merge points that are closer than a given distance.
%
%   PTS2 = mergeClosePoints(PTS, DIST)
%   Remove points in the array PTS such that no points closer than the
%   distance DIST remain in the array.
%
%   PTS2 = mergeClosePoints(PTS)
%   If the distance is not specified, the default value 1e-14 is used.
%
%
%   Example
%     pts = rand(200, 2);
%     pts2 = mergeClosePoints(pts, .1);
%     figure; drawPoint(pts, '.');
%     hold on; drawPoint(pts2, 'mo');
%
%   See also
%     points2d, removeMultipleVertices
%
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2013-10-04,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2013 INRA - Cepia Software Platform.

% default values
minDist = 1e-14;
if ~isempty(varargin)
    minDist = varargin{1};
end

i = 1;
while i < size(points, 1)
    dist = distancePoints(points(i,:), points);
    inds = dist < minDist;
    inds(i) = 0;
    
    points(inds, :) = [];
    
    % switch to next point
    i = i + 1;
end
