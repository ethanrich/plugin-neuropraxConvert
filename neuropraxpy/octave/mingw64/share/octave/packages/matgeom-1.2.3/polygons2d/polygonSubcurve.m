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

function [res, inds] = polygonSubcurve(poly, t0, t1)
% Extract a portion of a polygon.
%
%   POLY2 = polygonSubcurve(POLYGON, POS0, POS1)
%   Create a new polyline, by keeping vertices located between positions
%   POS0 and POS1, and adding points corresponding to positions POS0 and
%   POS1 if they are not already vertices.
%
%   [POLY2, INDS] = polygonSubcurve(POLYGON, POS0, POS1)
%   Also return indices of polygon vertices comprised between POS0 and
%   POS1. The array INDS may be smaller than the array POLY2.
%
%   Example
%     Nv = 100;
%     poly = circleToPolygon([30 20 15], Nv);
%     arc1 = polygonSubcurve(poly, 15, 45);
%     arc2 = polygonSubcurve(poly, 90, 10); % contains polygon endpoints
%     figure; axis equal, hold on; axis([0 50 0 50]);
%     drawPolyline(arc1, 'linewidth', 4, 'color', 'g');
%     drawPolyline(arc2, 'linewidth', 4, 'color', 'r');
%     drawPolygon(poly, 'color', 'b');
%
%   See also
%     polygons2d, polylineSubcurve, projPointOnPolygon, polygonPoint
%

% ------
% Author: David Legland
% e-mail: david.legland@inrae.fr
% Created: 2009-04-30,    using Matlab 7.7.0.471 (R2008b)
% Copyright 2009 INRAE - Cepia Software Platform.

% number of vertices
Nv = size(poly, 1);

if t0 < t1
    % format positions
    t0 = max(t0, 0);
    t1 = min(t1, Nv);
end

% indices of extreme vertices inside subcurve
ind0 = ceil(t0)+1;
ind1 = floor(t1)+1;

% get the portion of polyline between 2 extremities
if t0 < t1
    % The result polyline does not contain the last vertex
    if ind1 <= Nv
        inds = ind0:ind1;
    else
        inds = 1;
    end
else 
    % polygon contains last vertex
    inds = [ind0:Nv 1:ind1];
end
res = poly(inds, :);

% add first point if it is not already a vertex
if t0 ~= ind0-1
    res = [polygonPoint(poly, t0); res];
end

% add last point if it is not already a vertex
if t1 ~= ind1-1
    res = [res; polygonPoint(poly, t1)];
end
    
