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

function [trans, points] = registerPoints3dAffine(points, target, varargin)
% Fit 3D affine transform using iterative algorithm.
%
%   TRANS = registerPoints3dAffine(POINTS, TARGET)
%   Computes the affine transform that maps the shape defines by POINTS
%   onto the shape defined by the points TARGET. Both POINTS and TARGET are
%   N-by-3 array of point coordinates, not necessarily the same size.
%   The result TRANS is a 4-by-4 affine transform.
%
%   TRANS = registerPoints3dAffine(POINTS, TARGET, NITER)
%   Specifies the number of iterations for the algorithm.
%
%   [TRANS, POINTS2] = registerPoints3dAffine(...)
%   Also returns the set of transformed points.
%
%   Example
%     registerPoints3dAffine
%
%   See also
%     transforms3d, fitAffineTransform3d
%
 
% ------
% Author: David Legland
% e-mail: david.legland@inra.fr
% Created: 2015-02-24,    using Matlab 8.4.0.150421 (R2014b)
% Copyright 2015 INRA - Cepia Software Platform.


nIters = 10;
if ~isempty(varargin)
    nIters = varargin{1};
end

% keep original points to transform them at each
trans = [1 0 0 0;0 1 0 0;0 0 1 0;0 0 0 1];

for i = 1:nIters
    % identify target points for each source point
    inds = findClosestPoint(points, target);
    corrPoints = target(inds, :);
    
    % compute transform for current iteration
    trans_i = fitAffineTransform3d(points, corrPoints);

    % apply transform, and update cumulated transform
    points = transformPoint3d(points, trans_i);
    trans = trans_i * trans;
end
