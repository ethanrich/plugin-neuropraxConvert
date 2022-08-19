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

function [res, inds] = polylineSubcurve(poly, t0, t1)
% Extract a portion of a polyline.
%
%   POLY2 = polylineSubcurve(POLYLINE, POS0, POS1)
%   Create a new polyline, by keeping vertices located between positions
%   POS0 and POS1, and adding points corresponding to positions POS0 and
%   POS1 if they are not already vertices.
%
%   [POLY2, INDS] = polylineSubcurve(POLYLINE, POS0, POS1)
%   Also returns the indices of the original polyline that were selected.
%   The size of the array INDS may be smaller than the array POLY, due to
%   the addition of new vertices at the extremities.
%
%   Example
%     Nv = 100;
%     poly = circleAsPolygon([10 20 30], Nv);
%     poly2 = polylineSubcurve(poly, 15, 65);
%     drawCurve(poly2);
%
%   See also
%     polygons2d, polygonSubCurve
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
    t1 = min(t1, Nv-1);
end

% indices of extreme vertices inside subcurve
ind0 = ceil(t0)+1;
ind1 = floor(t1)+1;

% get the portion of polyline between 2 extremities
if t0 < t1
    inds = ind0:ind1;
else
    inds = [ind0:Nv 1:ind1];
end

res = poly(inds, :);

% add first point if it is not already a vertex
if t0 ~= ind0-1
    res = [polylinePoint(poly, t0); res];
end

% add last point if it is not already a vertex
if t1 ~= ind1-1
    res = [res; polylinePoint(poly, t1)];
end
    
