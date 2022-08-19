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

function [edge, isInside] = clipRay(ray, bb)
% Clip a ray with a box.
%
%   EDGE = clipRay(RAY, BOX);
%   RAY is a straight ray given as a 4 element row vector: [x0 y0 dx dy],
%   with (x0 y0) being the origin of the ray and (dx dy) its direction
%   vector, BOX is the clipping box, given by its extreme coordinates: 
%   [xmin xmax ymin ymax].
%   The result is given as an edge, defined by the coordinates of its 2
%   extreme points: [x1 y1 x2 y2].
%   If the ray does not intersect the box, [NaN NaN NaN NaN] is returned.
%   
%   Function works also if RAY is a N-by-4 array, if BOX is a Nx4 array, or
%   if both RAY and BOX are N-by-4 arrays. In these cases, EDGE is a N-by-4
%   array.
%      
%   See also:
%     rays2d, boxes2d, edges2d, clipLine, drawRay
%

% ------
% Author: David Legland
% e-mail: david.legland@inrae.fr
% Created: 2010-05-13,    using Matlab 7.4.0.287 (R2007a)
% Copyright 2010 INRA - Cepia Software Platform.

%   HISTORY
%   2010-05-13 create from clipLine
%   2017-09-21 simplify code

% adjust size of two input arguments
if size(ray, 1) == 1
    ray = repmat(ray, size(bb, 1), 1);
elseif size(bb, 1) == 1
    bb = repmat(bb, size(ray, 1), 1);
elseif size(ray, 1) ~= size(bb, 1)
    error('bad sizes for input');
end

% first compute clipping of supporting line
edge = clipLine(ray, bb);

% detects valid edges (edges outside box are all NaN)
inds = find(isfinite(edge(:, 1)));

% compute position of edge extremities relative to the ray
pos1 = linePosition(edge(inds,1:2), ray(inds,:), 'diag');
pos2 = linePosition(edge(inds,3:4), ray(inds,:), 'diag');

% if first point is before ray origin, replace by origin
edge(inds(pos1 < 0), 1:2) = ray(inds(pos1 < 0), 1:2);

% if last point of edge is before origin, set all edge to NaN
edge(inds(pos2 < 0), :) = NaN;

% eventually returns result about inside or outside
if nargout > 1
    isInside = isfinite(edge(:,1));
end
