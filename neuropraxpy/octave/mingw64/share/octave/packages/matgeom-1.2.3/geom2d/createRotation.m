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

function trans = createRotation(varargin)
%CREATEROTATION Create the 3*3 matrix of a rotation.
%
%   TRANS = createRotation(THETA);
%   Returns the rotation corresponding to angle THETA (in radians)
%   The returned matrix has the form :
%   [cos(theta) -sin(theta)  0]
%   [sin(theta)  cos(theta)  0]
%   [0           0           1]
%
%   TRANS = createRotation(POINT, THETA);
%   TRANS = createRotation(X0, Y0, THETA);
%   Also specifies origin of rotation. The result is similar as performing
%   translation(-X0, -Y0), rotation(THETA), and translation(X0, Y0).
%
%   Example
%     % apply a rotation on a polygon
%     poly = [0 0; 30 0;30 10;10 10;10 20;0 20];
%     trans = createRotation([10 20], pi/6);
%     polyT = transformPoint(poly, trans);
%     % display the original and the rotated polygons
%     figure; hold on; axis equal; axis([-10 40 -10 40]);
%     drawPolygon(poly, 'k');
%     drawPolygon(polyT, 'b');
%
%   See also:
%   transforms2d, transformPoint, createRotation90, createTranslation
%

%   ---------
%   author : David Legland 
%   INRA - TPV URPOI - BIA IMASTE
%   created the 06/04/2004.
%

%   HISTORY
%   22/04/2009: rename as createRotation

% default values
cx = 0;
cy = 0;
theta = 0;

% get input values
if length(varargin)==1
    % only angle
    theta = varargin{1};
elseif length(varargin)==2
    % origin point (as array) and angle
    var = varargin{1};
    cx = var(1);
    cy = var(2);
    theta = varargin{2};
elseif length(varargin)==3
    % origin (x and y) and angle
    cx = varargin{1};
    cy = varargin{2};
    theta = varargin{3};
end

% compute coefs
cot = cos(theta);
sit = sin(theta);
tx =  cy*sit - cx*cot + cx;
ty = -cy*cot - cx*sit + cy;

% create transformation matrix
trans = [cot -sit tx; sit cot ty; 0 0 1];
