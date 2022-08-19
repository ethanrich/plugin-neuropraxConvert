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

function points = randomPointInPolygon(poly, varargin)
%RANDOMPOINTINPOLYGON Generate random point(s) in a polygon.
%
%   POINT = randomPointInPolygon(POLY)
%   POINTS = randomPointInPolygon(POLY, NPTS)
%   Generate random point(s) within the specified polygon. If the number of
%   points is not specified, only one point is generated.
%   
%   POINT = randomPointInPolygon(POLY, NPTS, QRS)
%   Specifies a Quasi-random number generator QRS used to generate point.
%   coordinates (requires the statistics toolbox).
%
%   Example
%     % generate an ellipse-like polygon, and fill it with points
%     elli = [50 50 50 30 30];
%     poly = ellipseToPolygon(elli, 200);
%     pts = randomPointInPolygon(poly, 500);
%     figure; hold on;
%     drawPolygon(poly, 'k');
%     drawPoint(pts, 'b.');
%     axis equal; axis([0 100 0 100]);
%
%     % use halton sequence to distribute points within the polygon
%     qrs = haltonset(2, 'Skip', 1e3, 'Leap', 1e2);
%     pts = randomPointInPolygon(poly, 500, qrs);
%     figure; hold on;
%     drawPolygon(poly, 'k');
%     drawPoint(pts, 'b.');
%     axis equal; axis([0 100 0 100]);
%
%   See also
%     polygons2d, randomPointInBox, drawPolygon
%
 
% ------
% Author: David Legland
% e-mail: david.legland@inra.fr
% Created: 2017-08-28,    using Matlab 9.1.0.441655 (R2016b)
% Copyright 2017 INRA - Cepia Software Platform.

% determine number of points to generate
nPts = 1;
if nargin > 1
    nPts = varargin{1};
    varargin(1) = [];
end

% if additional input arg is provided, use it as quasi-random generator
stream = [];
if ~isempty(varargin)
    stream = qrandstream(varargin{1});
end

% polygon extreme coordinates
box = polygonBounds(poly);
xmin = box(1);  xmax = box(2);
ymin = box(3);  ymax = box(4);

% compute size of box
boxSizeX = xmax - xmin;
boxSizeY = ymax - ymin;

% allocate memory for result
points = zeros(nPts, 2);

% contains indices of remaining points to process
ind = (1:nPts)';

% iterate until all points have been sampled within the polygon
if isempty(stream)
    % use default random number generator
    while ~isempty(ind)
        NI = length(ind);
        x = rand(NI, 1) * boxSizeX + xmin;
        y = rand(NI, 1) * boxSizeY + ymin;
        points(ind, :) = [x y];

        ind = ind(~polygonContains(poly, points(ind, :)));
    end

else
    % use specified quasi-random generator
    while ~isempty(ind)
        NI = length(ind);
        pts = qrand(stream, NI);
        x = pts(:, 1) * boxSizeX + xmin;
        y = pts(:, 2) * boxSizeY + ymin;
        points(ind, :) = [x y];

        ind = ind(~polygonContains(poly, points(ind, :)));
    end
    
end
