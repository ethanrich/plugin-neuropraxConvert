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

function varargout = principalAxes(points)
%PRINCIPALAXES Principal axes of a set of ND points.
%
%   [CENTER, ROTMAT] = principalAxes(PTS)
%   [CENTER, ROTMAT, SCALES] = principalAxes(PTS)
%   Computes the principal axes of a set of points given in a N-by-ND array
%   and returns the result in two or three outputs:
%   CENTER  is the centroid of the points, as a 1-by-ND row vector
%   ROTMAT  represents the orientation of the point cloud, as a ND-by-ND
%           rotation matrix
%   SCALES  is the scaling factor along each dimension, as a 1-by-ND row
%           vector.
%
%   Example
%     pts = randn(100, 2);
%     pts = transformPoint(pts, createScaling(5, 2));
%     pts = transformPoint(pts, createRotation(pi/6));
%     pts = transformPoint(pts, createTranslation(3, 4));
%     [center, rotMat] = principalAxes(pts);
%
%   See also
%     equivalentEllipse, equivalentEllipsoid, principalAxesTransform
%
 
% ------
% Author: David Legland
% e-mail: david.legland@inrae.fr
% Created: 2019-08-12,    using Matlab 9.6.0.1072779 (R2019a)
% Copyright 2019 INRAE - Cepia Software Platform.

% number and dimension of points
n = size(points, 1);
nd = size(points, 2);

% compute centroid
center = mean(points);

% compute the covariance matrix
covPts = cov(points) / n;

% perform a principal component analysis to extract principal axes
[rotMat, S] = svd(covPts);

% extract length of each semi axis
radii = sqrt(diag(S) * n);

% sort axes from greater to lower
[radii, ind] = sort(radii, 'descend');
radii = radii';

% format U to ensure first axis points to positive x direction
rotMat = rotMat(ind, :);
if rotMat(1,1) < 0 && nd > 2
    rotMat = -rotMat;
    % keep matrix determinant positive
    rotMat(:,3) = -rotMat(:,3);
end

% format output
if nargout == 2
    varargout = {center, rotMat};
elseif nargout == 3
    varargout = {center, rotMat, radii};
end
