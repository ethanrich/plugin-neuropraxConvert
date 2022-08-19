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

function [intersects, edgeIndices] = intersectRayPolygon(ray, poly, varargin)
%INTERSECTRAYPOLYGON Intersection points between a ray and a polygon.
%
%   P = intersectRayPolygon(RAY, POLY)
%   Returns the intersection points of the ray RAY with polygon POLY. 
%   RAY is a 1x4 array containing parametric representation of the ray
%   (in the form [x0 y0 dx dy], see createRay for details). 
%   POLY is a Nx2 array containing coordinate of polygon vertices
%   
%   P = intersectRayPolygon(RAY, POLY, TOL)
%   Specifies the tolerance for geometric tests. Default is 1e-14.
%
%   [P IND] = intersectRayPolygon(...)
%   Also returns index of polygon intersected edge(s). See
%   intersectLinePolygon for details.
%
%   See also
%   rays2d, polygons2d, intersectLinePolygon
%

%   ---------
%   author : David Legland 
%   INRA - TPV URPOI - BIA IMASTE
%   created the 26/01/2010


%   HISTORY
%   2010/01/26 creation from intersectLinePolygon
%   2013-02-11 also returns edgeIndices

% compute intersections with supporting line
[intersects, edgeIndices] = intersectLinePolygon(ray, poly, varargin{:});

% compute position of intersects on the supporting line
pos = linePosition(intersects, ray);

% keep only intersects with non-negative position on line
indPos = pos >= 0;
intersects  = intersects(indPos, :);
edgeIndices = edgeIndices(indPos);
