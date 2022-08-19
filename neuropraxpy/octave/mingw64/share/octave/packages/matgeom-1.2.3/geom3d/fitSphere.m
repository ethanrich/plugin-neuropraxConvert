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

function [sphere, residuals] = fitSphere(x,y,z)
%FITSPHERE Fit a sphere to 3D points using the least squares approach.
%
%   SPHERE = fitSphere(PTS)
%   Fits the equation of a sphere in Cartesian coordinates to the N-by-3 
%   array PTS using the least squares approach. The sphere is represented 
%   by its center [xc yc zc] and its radius r: SPHERE = [xc yc zc r].
%
%   SPHERE = fitSphere(X, Y, Z)
%   Use three vectors X, Y and Z with the length N instead of a the 
%   N-by-3 array PTS.
%  
%   [SPHERE, RESIDUALS] = fitSphere(...)
%   Additionally outputs the residuals in the radial direction.
%
%   Example:
%     center=-100 + 200*rand(1,3);
%     radius = randi([10 100]);
%     [x,y,z]=drawSphere(center, radius);
%     x=x+rand(size(x)); y=y+rand(size(y)); z=z+rand(size(z));
%     sampleIdx = randi(numel(x),[1,randi([4, numel(x)])]);
%     x=x(sampleIdx); y=y(sampleIdx); z=z(sampleIdx);
%     sphere = fitSphere(x,y,z);
%     figure('color','w'); hold on; axis equal tight; view(3)
%     drawPoint3d(x,y,z)
%     drawSphere(sphere,'FaceAlpha',0.5)
%   
%   See also:
%     createSphere, drawSphere, intersectLineSphere, intersectPlaneSphere
%
%   Source:
%     Levente Hunyadi - Fitting quadratic curves and surfaces:
%     https://de.mathworks.com/matlabcentral/fileexchange/45356

% ------
% Author: Levente Hunyadi, oqilipo (minor adaptions for matGeom)
% Created: 2010
% Copyright 2010 Levente Hunyadi

narginchk(1,3);

switch nargin  % n x 3 matrix
    case 1
        n = size(x,1);
        validateattributes(x, {'numeric'}, {'2d','real','size',[n,3]});
        z = x(:,3);
        y = x(:,2);
        x = x(:,1);
    otherwise  % three x,y,z vectors
        n = length(x(:));
        x = x(:);  % force into columns
        y = y(:);
        z = z(:);
        validateattributes(x, {'numeric'}, {'real','size',[n,1]});
        validateattributes(y, {'numeric'}, {'real','size',[n,1]});
        validateattributes(z, {'numeric'}, {'real','size',[n,1]});
end

% need four or more data points
if n < 4
   error('spherefit:InsufficientData', ...
       'At least four points are required to fit a unique sphere.');
end

% solve linear system of normal equations
A = [x, y, z, ones(size(x))];
b = -(x.^2 + y.^2 + z.^2);
a = A \ b;

% return center coordinates and sphere radius
center = -a(1:3)./2;
radius = realsqrt(sum(center.^2)-a(4));
sphere = [center' radius];

% calculate residuals
residuals = radius - sqrt(sum(bsxfun(@minus,[x y z],center.').^2,2));
end
