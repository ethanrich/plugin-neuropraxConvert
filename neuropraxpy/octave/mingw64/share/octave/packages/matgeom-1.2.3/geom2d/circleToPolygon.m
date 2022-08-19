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

function varargout = circleToPolygon(circle, varargin)
%CIRCLETOPOLYGON Convert a circle into a series of points.
%
%   PTS = circleToPolygon(CIRC, N);
%   Converts the circle CIRC into an array of  N-by-2 of double, containing
%   x and y positions of vertices. 
%   CIRC is given as [x0 y0 r], where x0 and y0 are coordinate of center,
%   and r is the radius. 
%
%   P = circleToPolygon(CIRCLE);
%   uses a default value of N=64 vertices.
%
%   Example
%     poly = circleToPolygon([30 20 15], 16);
%     figure; hold on;
%     axis equal;axis([0 50 0 50]);
%     drawPolygon(poly, 'b');
%     drawPoint(poly, 'bo');
%
%   See also:
%   circles2d, polygons2d, circleArcToPolyline, ellipseToPolygon
%

% ---------
% author : David Legland 
% created the 06/04/2005.
% Copyright 2010 INRA - Cepia Software Platform.
%

% HISTORY
% 2007-04-20 return a closed polygon with N+1 vertices, use default N=64
% 2011-12-09 rename to 'circleToPolygon'
% 2017-08-31 returns N vertices instead of N+1

% determines number of points
N = 64;
if ~isempty(varargin)
    N = varargin{1};
end

% create circle
t = linspace(0, 2*pi, N+1)';
t(end) = [];

% coordinates of circle points
x = circle(1) + circle(3) * cos(t);
y = circle(2) + circle(3) * sin(t);

% foramt output
if nargout == 1
    varargout{1} = [x y];
elseif nargout == 2
    varargout{1} = x;
    varargout{2} = y;    
end
