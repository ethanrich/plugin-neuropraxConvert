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

function ell = equivalentEllipsoid(points)
% Equivalent ellipsoid of a set of 3D points.
%
%   ELL = equivalentEllipsoid(PTS)
%   Compute the equivalent ellipsoid of the set of points PTS. The result
%   is an ellipsoid defined by:
%   ELL = [XC YC ZC  A B C  PHI THETA PSI]
%   where [XC YC ZY] is the center, [A B C] are the lengths of the
%   semi-axes (in decreasing order), and [PHI THETA PSI] are Euler angles
%   representing  the ellipsoid orientation, in degrees.
%
%   Example
%     pts = randn(300, 3);
%     pts = transformPoint3d(pts, createScaling3d([6 4 2]));
%     pts = transformPoint3d(pts, createRotationOx(pi/6));
%     pts = transformPoint3d(pts, createRotationOy(pi/4));
%     pts = transformPoint3d(pts, createRotationOz(pi/3));
%     pts = transformPoint3d(pts, createTranslation3d([5 4 3]));
%     elli = equivalentEllipsoid(pts);
%     figure; drawPoint3d(pts); axis equal;
%     hold on; drawEllipsoid(elli, ...
%         'drawEllipses', true, 'EllipseColor', 'b', 'EllipseWidth', 3);
%
%   See also
%     spheres, drawEllipsoid, equivalentEllipse, principalAxes
%     principalAxesTransform, rotation3dToEulerAngles

% ------
% Author: David Legland
% e-mail: david.legland@inrae.fr
% Created: 2011-03-12,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2011 INRA - Cepia Software Platform.

% number of points
n = size(points, 1);

% compute centroid
center = mean(points);

% compute the covariance matrix
covPts = cov(points)/n;

% perform a principal component analysis with 3 variables, 
% to extract equivalent axes
[U, S] = svd(covPts);

% extract length of each semi axis
radii = sqrt(5) * sqrt(diag(S)*n)';

% sort axes from greater to lower
[radii, ind] = sort(radii, 'descend');

% format U to ensure first axis points to positive x direction
U = U(ind, :);
if U(1,1) < 0
    U = -U;
    % keep matrix determinant positive
    U(:,3) = -U(:,3);
end

% convert axes rotation matrix to Euler angles
angles = rotation3dToEulerAngles(U);

% concatenate result to form an ellipsoid object
ell = [center, radii, angles];
