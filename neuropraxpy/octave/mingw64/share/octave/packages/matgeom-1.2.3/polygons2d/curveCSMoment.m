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

function m = curveCSMoment(curve, p, q)
%CURVECSMOMENT  Compute centered scaled moment of a 2D curve.
%   M = curveCSMoment(CURVE, P, Q)
%
%   Example
%   curveCSMoment
%
%   See also
%   polygons2d, curveMoment, curveCMoment
%
%   Reference
%   Based on ideas and references in:
%   "Affine curve moment invariants for shape recognition"
%   Dongmin Zhao and Jie Chen
%   Pattern Recognition, 1997, vol. 30, pp. 865-901
%
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2009-03-25,    using Matlab 7.7.0.471 (R2008b)
% Copyright 2009 INRA - Cepia Software Platform.

% compute curve centroid
centroid = polylineCentroid(curve);

% compute perimeter
L   = polylineLength(curve);

% coordinate of vertices
px  = curve(:,1)-centroid(1);
py  = curve(:,2)-centroid(2);

% compute centroids of line segments
cx  = (px(1:end-1)+px(2:end))/2;
cy  = (py(1:end-1)+py(2:end))/2;

% compute length of each line segment
dl  = hypot(px(2:end)-px(1:end-1), py(2:end)-py(1:end-1));

% compute moment
m = zeros(size(p));
for i=1:length(p(:))
    d = (p(i)+q(i))/2+1;
    m(i) = sum(cx(:).^p(i) .* cy(:).^q(i) .* dl(:)) / L^d;
end
