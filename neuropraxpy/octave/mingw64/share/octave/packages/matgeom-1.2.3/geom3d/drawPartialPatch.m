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

function drawPartialPatch(u, v, z, varargin)
%DRAWPARTIALPATCH draw surface patch, with 2 parametrized surfaces.
%
%   usage :
%   drawSurfPatch(u, v, zuv)
%   where u, v, and zuv are three matrices the same size, u and
%   corresponding to each parameter, and zuv being equal to a function of u
%   and v.
%
%   drawSurfPatch(u, v, zuv, p0)
%   If p0 is specified, two lines with u(p0(1)) and v(p0(2)) are drawn on
%   the surface
%
%
%   ---------
%
%   author : David Legland 
%   INRA - TPV URPOI - BIA IMASTE
%   created the 24/05/2005.
%

%   HISTORY
%   2005-06-08 add doc.
%   2007-01-04 remove unused variables and change function name
%   2010-03-08 code cleanup, use drawPolyline3d

% prepare figure
hold on;

% draw the surface interior
surf(u, v, z, 'FaceColor', 'g', 'EdgeColor', 'none');

% draw the surface boundaries
drawPolyline3d(u(1,:), v(1,:), z(1,:))
drawPolyline3d(u(end,:), v(end,:), z(end,:))
drawPolyline3d(u(:,end), v(:,end), z(:,end))
drawPolyline3d(u(:,1), v(:,1), z(:,1))

% eventually draw two perpendicular lines on the surface
if ~isempty(varargin)
    pos = varargin{1};
    drawPolyline3d(u(pos(1),:), v(pos(1),:), z(pos(1),:));
    drawPolyline3d(u(:,pos(2)), v(:,pos(2)), z(:,pos(2)));
end
