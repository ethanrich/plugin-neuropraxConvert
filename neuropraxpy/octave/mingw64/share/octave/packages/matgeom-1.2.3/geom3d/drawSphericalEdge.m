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

function varargout = drawSphericalEdge(sphere, edge, varargin)
%DRAWSPHERICALEDGE Draw an edge on the surface of a sphere.
%
%   drawSphericalEdge(SPHERE, EDGE)
%   EDGE is given as a couple of 3D coordinates corresponding to edge
%   extremities. The shortest spherical edge joining the two extremities is
%   drawn on the current axes.
%
%   Example
%   drawSphericalEdge
%
%   See also
%   drawSphericalPolygon
%
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2012-02-09,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2012 INRA - Cepia Software Platform.


% extract data of the sphere
origin = sphere(:, 1:3);

% extremities of current edge
point1  = edge(1:3);
point2  = edge(4:6);

% compute plane containing current edge
plane   = createPlane(origin, point1, point2);

% intersection of the plane with unit sphere
circle  = intersectPlaneSphere(plane, sphere);

% find the position (in degrees) of the 2 vertices on the circle
angle1  = circle3dPosition(point1, circle);
angle2  = circle3dPosition(point2, circle);

% ensure angles are in right direction
if mod(angle2 - angle1 + 360, 360) > 180
    tmp     = angle1;
    angle1  = angle2;
    angle2  = tmp;
end

% compute angle extent of the circle arc
angleExtent = mod(angle2 - angle1 + 360, 360);

% create circle arc
arc = [circle angle1 angleExtent];

% draw the arc
h = drawCircleArc3d(arc, varargin{:});

if nargout > 0
    varargout = {h};
end
