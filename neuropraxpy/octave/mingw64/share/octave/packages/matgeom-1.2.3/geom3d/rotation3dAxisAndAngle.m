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

function [axis, theta] = rotation3dAxisAndAngle(mat)
%ROTATION3DAXISANDANGLE Determine axis and angle of a 3D rotation matrix.
%
%   [AXIS, ANGLE] = rotation3dAxisAndAngle(MAT)
%   Where MAT is a 4-by-4 matrix representing a rotation, computes the
%   rotation axis (containing the points that remain invariant under the
%   rotation), and the rotation angle around that axis.
%   AXIS has the format [DX DY DZ], constrained to unity, and ANGLE is the
%   rotation angle in radians.
%
%   Note: this method use eigen vector extraction. It would be more precise
%   to use quaternions, see:
%   http://www.mathworks.cn/matlabcentral/newsreader/view_thread/160945
%
%   
%   Example
%     origin = [1 2 3];
%     direction = [4 5 6];
%     line = [origin direction];
%     angle = pi/3;
%     rot = createRotation3dLineAngle(line, angle);
%     [axis angle2] = rotation3dAxisAndAngle(rot);
%     angle2
%     angle2 =
%           1.0472
%
%   See also
%   transforms3d, vectors3d, angles3d, eulerAnglesToRotation3d
%

% ------
% Author: David Legland
% e-mail: david.legland@inra.fr
% Created: 2010-08-11,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2010 INRA - Cepia Software Platform.

% extract the linear part of the rotation matrix
A = mat(1:3, 1:3);

% extract eigen values and eigen vectors
[V, D] = eig(A - eye(3));

% we need the eigen vector corresponding to eigenvalue==1
[dummy, ind] = min(abs(diag(D)-1)); %#ok<ASGLU>

% extract corresponding eigen vector
vector = V(:, ind)';

% compute rotation angle
t = [A(3,2)-A(2,3) , A(1,3)-A(3,1) , A(2,1)-A(1,2)];
theta = atan2(dot(t, vector), trace(A)-1);

% If angle is negative, invert both angle and vector direction
if theta<0
    theta  = -theta; 
    vector = -vector; 
end

% try to get a point on the line
% seems to work, but not sure about stability
[V, D] = eig(mat-eye(4)); %#ok<ASGLU>
origin = V(1:3,4)'/V(4, 4);

% create line corresponding to rotation axis
axis = [origin vector];

