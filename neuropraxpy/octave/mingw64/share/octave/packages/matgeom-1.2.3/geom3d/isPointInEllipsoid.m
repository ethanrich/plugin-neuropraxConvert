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

function b = isPointInEllipsoid(point, elli, varargin)
% Check if a point is located inside a 3D ellipsoid.
%
%   output = isPointInEllipsoid(input)
%
%   Example
%     % create an ellipsoid
%     elli = [10 20 30   50 30 10   5 10 0];
%     display it
%     figure; hold on;
%     drawEllipsoid(elli, 'FaceColor', 'g', 'FaceAlpha', .5, ...
%         'drawEllipses', true, 'EllipseColor', 'b', 'EllipseWidth', 3);
%     view(3); axis equal;
%     % check for a point inside the ellipsoid
%     p1 = [20 30 35];
%     b1 = isPointInEllipsoid(p1, elli)
%     ans = 
%         1
%     % check for a point outside the ellipsoid
%     p2 = [-20 10 25];
%     b2 = isPointInEllipsoid(p2, elli)
%     ans = 
%         0
%   
%
%   See also
%     equivalentEllipsoid, drawEllipsoid, isPointInEllipse
%
 
% ------
% Author: David Legland
% e-mail: david.legland@inrae.fr
% INRAE - BIA Research Unit - BIBS Platform (Nantes)
% Created: 2020-11-19,    using Matlab 9.8.0.1323502 (R2020a)
% Copyright 2020 INRAE.

% extract computation tolerance
tol = 1e-14;
if ~isempty(varargin)
    tol = varargin{1};
end

% compute ellipse to unit circle transform
rot = eulerAnglesToRotation3d(elli(7:9));
sca = createScaling3d(elli(4:6));
trans = inv(rot * sca);

% transform points to unit sphere basis
pTrans = bsxfun(@minus, point, elli(1:3));
pTrans = transformPoint3d(pTrans, trans);

% test if norm is smaller than 1
b = sqrt(sum(power(pTrans, 2), 2)) - 1 <= tol;
    
