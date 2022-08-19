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

function [hull, inds] = convexHull(points, varargin)
%CONVEXHULL Convex hull of a set of points.
%
%   POLY = convexHull(POINTS)
%   Computes the convex hull of the set of points POINTS. This function is
%   mainly a wrapper to the convhull function, that format the result to a
%   polygon.
%
%   [POLY, INDS] = convexHull(POINTS)
%   Also returns the indices of convex hull vertices within the original
%   array of points.
%
%   ... = convexHull(POINTS, 'simplify', BOOL)
%   specifies the 'simplify' option use dfor calling convhull. By default,
%   the convexHull functions uses simplify equals to TRUE (contrary to the
%   convhull function), resulting in a more simple convex polygon.
%   
%   
%   Example
%     % Draws the convex hull of a set of random points
%     pts = rand(30,2);
%     drawPoint(pts, '.');
%     hull = convexHull(pts);
%     hold on; 
%     drawPolygon(hull);
%
%     % Draws the convex hull of a paper hen
%     x = [0 10 20  0 -10 -20 -10 -10  0];
%     y = [0  0 10 10  20  10  10  0 -10];
%     poly = [x' y'];
%     hull = convexHull(poly);
%     figure; drawPolygon(poly);
%     hold on; axis equal;
%     drawPolygon(hull, 'm');
%
%   See also
%   polygons2d, convhull
%

% ------
% Author: David Legland
% e-mail: david.legland@nantes.inra.fr
% Created: 2011-04-08,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2011 INRA - Cepia Software Platform.

% checkup on array size
if size(points, 1) < 3
    hull = points;
    inds = 1:size(points, 1);
    return;
end

% parse simplify option
simplify = true;
if nargin > 2 && strcmpi(varargin{1}, 'simplify')
    simplify = varargin{2};
end

% compute convex hull by calling the 'convhull' function
inds = convhull(points(:,1), points(:,2), 'simplify', simplify);
hull = points(inds, :);
