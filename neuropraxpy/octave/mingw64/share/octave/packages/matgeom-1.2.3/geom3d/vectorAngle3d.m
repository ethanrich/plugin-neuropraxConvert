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

function theta = vectorAngle3d(v1, v2)
%VECTORANGLE3D Angle between two 3D vectors.
%
%   THETA = vectorAngle3d(V1, V2)
%   Computes the angle between the 2 3D vectors V1 and V2. The result THETA
%   is given in radians, between 0 and PI.
%
%
%   Example
%   % angle between 2 orthogonal vectors
%   vectorAngle3d([1 0 0], [0 1 0])
%   ans = 
%       1.5708
%
%   % angle between 2 parallel vectors
%   v0 = [3 4 5];
%   vectorAngle3d(3*v0, 5*v0)
%   ans = 
%       0
%
%   See also
%   vectors3d, vectorNorm3d, crossProduct3d
%

% ------
% Author: David Legland
% e-mail: david.legland@inra.fr
% Created: 2010-10-04,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2010 INRA - Cepia Software Platform.

% 2011-03-10 improve computation precision

% compute angle using arc-tangent to get better precision for angles near
% zero, see the discussion in: 
% http://www.mathworks.com/matlabcentral/newsreader/view_thread/151925#381952
theta = atan2(vectorNorm3d(crossProduct3d(v1, v2)), sum(bsxfun(@times, v1, v2),2));

% equivalent to:
% v1 = normalizeVector3d(v1);
% v2 = normalizeVector3d(v2);
% theta = acos(dot(v1, v2, 2));
