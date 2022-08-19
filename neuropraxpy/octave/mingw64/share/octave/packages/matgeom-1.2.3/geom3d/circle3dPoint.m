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

function point = circle3dPoint(circle, pos)
%CIRCLE3DPOINT Coordinates of a point on a 3D circle from its position.
%
%   output = circle3dPoint(input)
%
%   Example
%   % Draw some points on a 3D circle
%     figure('color','w'); hold on; view(130,-10);
%     circle = [10 20 30 50 90 45 0];
%     drawCircle3d(circle)
%     % origin point
%     pos1 = 0;
%     drawPoint3d(circle3dPoint(circle, pos1), 'ro')
%     % few points regularly spaced
%     drawPoint3d(circle3dPoint(circle, 10:10:40), '+')
%     % Draw point opposite to origin
%     drawPoint3d(circle3dPoint(circle, 180), 'k*')
%   
%
%   See also
%   circles3d, circle3dPosition
%
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2011-06-21,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2011 INRA - Cepia Software Platform.

pos=pos(:);

% extract circle coordinates
xc  = circle(1);
yc  = circle(2);
zc  = circle(3);
r   = circle(4);

theta   = circle(5);
phi     = circle(6);
psi     = circle(7);

% convert position to angle
t = pos * pi / 180;

% compute position on base circle
x   = r * cos(t);
y   = r * sin(t);
z   = zeros(length(pos),1);
pt0 = [x y z];

% compute transformation from local basis to world basis
trans   = localToGlobal3d(xc, yc, zc, theta, phi, psi);

% compute points of transformed circle
point   = transformPoint3d(pt0, trans);

