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

function ori = circle3dOrigin(varargin)
%CIRCLE3DORIGIN Return the first point of a 3D circle.
%
%   P = circle3dOrigin([XC YC ZC R THETA PHI])
%   P = circle3dOrigin([XC YC ZC R THETA PHI PSI])
%   Returns the origin point of the circle, i.e. the first point used for
%   drawing circle.
%
%   See also:
%   circles3d, points3d, circle3dPosition
%
%   ---------
%   author : David Legland 
%   INRA - TPV URPOI - BIA IMASTE
%   created the 21/02/2005
%

%   HISTORY

% get center and radius
circle = varargin{1};
xc = circle(:,1);
yc = circle(:,2);
zc = circle(:,3);
r  = circle(:,4);

% get angle of normal
theta   = circle(:,5);
phi     = circle(:,6);

% get roll
if size(circle, 2)==7
    psi = circle(:,7);
else
    psi = zeros(size(circle, 1), 1);
end

% create origin point
pt0 = [r 0 0];

% compute transformation from local basis to world basis
trans   = localToGlobal3d(xc, yc, zc, theta, phi, psi);

% transform the point
ori = transformPoint3d(pt0, trans);
