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

function varargout = ellipseToPolygon(ellipse, N)
%ELLIPSETOPOLYGON Convert an ellipse into a series of points.
%
%   P = ellipseToPolygon(ELL, N);
%   converts ELL given as [x0 y0 a b] or [x0 y0 a b theta] into a polygon
%   with N edges. The result P is a N-by-2 array containing the coordinates
%   of the N vertices of the polygon.
%
%   P = ellipseToPolygon(ELL);
%   Use a default number of edges equal to 72. This results in one point
%   for each 5 degrees.
%   
%   [X, Y] = ellipseToPolygon(...);
%   Return the coordinates of vertices in two separate arrays.
%
%   Example
%     poly = ellipseToPolygon([50 50 40 30 20], 60);
%     figure; hold on;
%     axis equal; axis([0 100 10 90]);
%     drawPolygon(poly, 'b');
%     drawPoint(poly, 'bo');
%
%   See also:
%   ellipses2d, drawEllipse, circleToPolygon, rectToPolygon
%

%   ---------
%   author : David Legland 
%   INRA - TPV URPOI - BIA IMASTE
%   created the 06/04/2005.
%

% HISTORY
% 2011-03-30 use angles in degrees, add default value for N
% 2011-12-09 rename to ellipseToPolygon
% 2017-08-31 returns N vertices instead of N+1

% default value for N
if nargin < 2
    N = 72;
end

% angle of ellipse
theta = 0;
if size(ellipse, 2) > 4
    theta = ellipse(:,5);
end

% get ellipse parameters
xc = ellipse(:,1);
yc = ellipse(:,2);
a  = ellipse(:,3);
b  = ellipse(:,4);

% create time basis
t = linspace(0, 2*pi, N+1)';
t(end) = [];

% pre-compute trig functions (angles is in degrees)
cot = cosd(theta);
sit = sind(theta);

% position of points
x = xc + a * cos(t) * cot - b * sin(t) * sit;
y = yc + a * cos(t) * sit + b * sin(t) * cot;

% format output depending on number of a param.
if nargout == 1
    varargout = {[x y]};
elseif nargout == 2
    varargout = {x, y};
end
