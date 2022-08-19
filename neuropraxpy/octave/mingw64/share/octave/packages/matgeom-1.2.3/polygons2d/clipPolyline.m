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

function res = clipPolyline(poly, box)
%CLIPPOLYLINE Clip an open polyline with a rectangular box.
%
%   POLY2 = clipPolyline(POLY, BOX);
%   POLY is N-by-2 array of vertex coordinates.
%   BOX has the form: [XMIN XMAX YMIN YMAX].
%   Returns the set of polylines created by the intersection of the
%   polyline POLY and the bounding box BOX. The result is a cell array with
%   as many cells as the number of curve clips.
%
%
%   Example
%     circle = [5 5 6];
%     poly = circleToPolygon(circle, 200);
%     box = [0 10 0 10];
%     res = clipPolyline(poly, box);
%     figure;
%     hold on; axis equal; axis([-2 12 -2 12]);
%     drawCircle(circle, 'b:')
%     drawBox(box, 'k')
%     drawPolyline(res, 'linewidth', 2, 'color', 'b')
% 
%   See also:
%     polygons2d, boxes2d, clipPolygon, clipEdge
%

% ---------
% author : David Legland 
% created the 14/05/2005.
% Copyright 2010 INRA - Cepia Software Platform.

%   HISTORY
%   2007/09/14 fix doc

% check case of polylines stored in cell array
if iscell(poly)
    res = cell(1, length(poly));
    for i = 1:length(poly)
        res{i} = clipPolyline(poly{i}, box);
    end
    return;
end

% check case of empty polylines
N = size(poly, 1);
if N == 0
    res = cell(0, 0);
    return
end

% create edges array of polyline
edges = [poly(1:N-1, :) poly(2:N, :)];

% clip edges
edges = clipEdge(edges, box);

% select non empty edges, and get their vertices
% find clipped edges within box 
inds = sum(abs(edges), 2) > 1e-14;

% find list of adjacent edges within box
dinds = diff(inds);
inds0 = find(dinds == 1) + 1;
if inds(1) == 1
    inds0 = [1 inds0];
end
inds1 = find(dinds == -1);
if inds(end) == 1
    inds1 = [inds1 N-1];
end

nClips = length(inds0);
res = cell(1, nClips);
for iClip = 1:nClips
    range = inds0(iClip):inds1(iClip);
    poly2 = [edges(range, 1:2) ; edges(range(end), 3:4)];
    res{iClip} = poly2;
end
