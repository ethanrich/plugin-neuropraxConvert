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

function [trans, points] = registerICP(points, target, varargin)
%REGISTERICP Fit affine transform by Iterative Closest Point algorithm.
%
%   TRANS = registerICP(POINTS, TARGET)
%   Computes the affine transform that maps the shape defines by POINTS
%   onto the shape defined by the points TARGET. Both POINTS and TARGET are
%   N-by-2 array of point coordinates, not necessarily the same size.
%   The result TRANS is a 3-by-3 affine transform.
%
%   TRANS = registerICP(POINTS, TARGET, NITER)
%   Specifies the number of iterations for the algorithm.
%
%   [TRANS, POINTS2] = registerICP(...)
%   Also returns the set of transformed points.
%
%   Example
%   registerICP
%
%   See also
%     transforms2d, fitAffineTransform2d, registerPoints3dAffine
%
 
% ------
% Author: David Legland
% e-mail: david.legland@inra.fr
% Created: 2015-02-24,    using Matlab 8.4.0.150421 (R2014b)
% Copyright 2015 INRA - Cepia Software Platform.


nIter = 10;
if ~isempty(varargin)
    nIter = varargin{1};
end

% keep original points to transform them at each
trans = [1 0 0;0 1 0;0 0 1];

for i = 1:nIter
    % identify target points for each source point
    inds = findClosestPoint(points, target);
    corrPoints = target(inds, :);
    
    % compute transform for current iteration
    trans_i = fitAffineTransform2d(points, corrPoints);

    % apply transform, and update cumulated transform
    points = transformPoint(points, trans_i);
    trans = trans_i * trans;
end
