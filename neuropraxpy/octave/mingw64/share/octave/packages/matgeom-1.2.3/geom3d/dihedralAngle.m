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

function theta = dihedralAngle(plane1, plane2)
%DIHEDRALANGLE Compute dihedral angle between 2 planes.
%
%   THETA = dihedralAngle(PLANE1, PLANE2)
%   PLANE1 and PLANE2 are plane representations given in the following
%   format:
%   [x0 y0 z0 dx1 dy1 dz1 dx2 dy2 dz2]
%   THETA is the angle between the two vectors given by plane normals,
%   given between 0 and PI.
%
%   References
%   http://en.wikipedia.org/wiki/Dihedral_angle
%   http://mathworld.wolfram.com/DihedralAngle.html
%
%   See also:
%   planes3d, lines3d, angles3d, planesBisector
%
%   ---------
%   author : David Legland 
%   INRA - TPV URPOI - BIA IMASTE
%   created the 21/02/2005.
%

% HISTORY
% 2009-06-19 change convention for dihedral angle
% 2011-03-20 improve computation precision

% compute plane normals
v1 = planeNormal(plane1);
v2 = planeNormal(plane2);

% number of vectors
n1 = size(v1, 1);
n2 = size(v2, 1);

% ensures vectors have same dimension
if n1 ~= n2
    if n1 == 1
        v1 = repmat(v1, [n2 1]);
    elseif n2 == 1
        v2 = repmat(v2, [n1 1]);
    else
        error('Arguments V1 and V2 must have the same size');
    end
end

% compute dihedral angle(s)
theta = atan2(vectorNorm3d(cross(v1, v2, 2)), dot(v1, v2, 2));

% % equivalent to following formula, but more precise for small angles:
% n1 = normalizeVector3d(planeNormal(plane1));
% n2 = normalizeVector3d(planeNormal(plane2));
% theta = acos(dot(n1, n2, 2));

