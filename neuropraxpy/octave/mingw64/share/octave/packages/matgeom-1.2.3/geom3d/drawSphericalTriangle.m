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

function varargout = drawSphericalTriangle(sphere, p1, p2, p3, varargin)
%DRAWSPHERICALTRIANGLE Draw a triangle on a sphere.
%
%   drawSphericalTriangle(SPHERE, PT1, PT2, PT3);
%   Draws the spherical triangle defined by the three input 3D points and
%   the reference sphere. 
%   Points are given as 3D points, and are projected onto the sphere. The
%   order of the points is not relevant. 
%
%   drawSphericalTriangle(SPHERE, PT1, PT2, PT3, OPTIONS);
%   Allows to specify plot options for spherical edges, in the form of
%   parameter name-value pairs.
%
%   Example
%     % Draw a sphere and a spherical triangle on it
%     s = [0 0 0 2];
%     pts = [1 0 0;0 -1 0;0 0 1];
%     drawSphere(s); hold on;
%     drawSphericalTriangle(s, pts(1,:), pts(2,:), pts(3,:), 'linewidth', 2);
%     view(3); axis equal;
%
%   See also
%   drawSphere, fillSphericalTriangle, drawSphericalPolygon,
%   drawSphericalEdge
%
%   ---------
%   author : David Legland 
%   INRA - TPV URPOI - BIA IMASTE
%   created the 22/02/2005
%

%   HISTORY
%   2007-06-27 manage spheres other than origin
%   2008-10-30 replace intersectPlaneLine by intersectLinePlane
%   2012-02-09 put drawing code into the 'drawSphericalEdge' function
%   2012-10-24 add holding facility, updtate doc


% extract data of the sphere
ori = sphere(:, 1:3);

% extract direction vectors for each point
v1  = normalizeVector3d(p1 - ori);
v2  = normalizeVector3d(p2 - ori);
v3  = normalizeVector3d(p3 - ori);

% keep hold state of current axis
h = ishold;

% draw each spherical edge
hold on;
h1 = drawSphericalEdge(sphere, [v1 v2], varargin{:});
h2 = drawSphericalEdge(sphere, [v2 v3], varargin{:});
h3 = drawSphericalEdge(sphere, [v3 v1], varargin{:});

% return to previous hold state if needed
if ~h
    hold off;    
end

if nargout > 0
    varargout = {h1, h2, h3};
end
