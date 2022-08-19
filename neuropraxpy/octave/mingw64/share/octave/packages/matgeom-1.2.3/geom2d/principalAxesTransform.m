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

function varargout = principalAxesTransform(pts)
% Align a set of points along its principal axes.
%
%   TRANSFO = principalAxesTransform(PTS)
%   Computes the affine transform that will transform the input array PTS
%   such that its principal axes become aligned with main axes.
%
%   [TRANSFO, PTS2] = principalAxesTransform(PTS)
%   Also returns the result of the transform applied to the points.
%
%   Example
%   principalAxesTransform
%
%   See also
%     principalAxes, equivalentEllipse, equivalentEllipsoid
%
 
% ------
% Author: David Legland
% e-mail: david.legland@inrae.fr
% Created: 2020-03-06,    using Matlab 8.6.0.267246 (R2015b)
% Copyright 2020 INRAE - Cepia Software Platform.

% computes principal axes
[center, rotMat] = principalAxes(pts);

% concatenate into affine matrix
nd = size(pts, 2);
transfo = inv([rotMat center'; zeros(1, nd) 1]);


% format output
if nargout < 2
    varargout = transfo;
else
    if nd == 2
        pts2 = transformPoint(pts, transfo);
    else
        pts2 = transformPoint3d(pts, transfo);
    end
    varargout = {transfo, pts2};
end
