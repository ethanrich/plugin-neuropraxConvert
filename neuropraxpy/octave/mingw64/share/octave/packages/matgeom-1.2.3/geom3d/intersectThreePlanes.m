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

function point = intersectThreePlanes(plane1, plane2, plane3)
%INTERSECTTHREEPLANES Return intersection point between 3 planes in space.
%
%   LINE = intersectThreePlanes(PLANE1, PLANE2, PLANE3)
%   Returns the point or straight line belonging to three planes.
%   PLANE:  [x0 y0 z0  dx1 dy1 dz1  dx2 dy2 dz2]
%   POINT:  [x0 y0 z0]
%   IF rank of the coefficient matrix r1 = 3 and
%   Rank of the augmented matrix r2 = 3 return point
%   Otherwise returns point with NaN values.
%
%   See also:
%   planes3d, intersectPlanes, intersectLinePlane
%
%   ---------
%   author : Roozbeh Geraili Mikola
%   email  : roozbehg@berkeley.edu or roozbehg@live.com
%   created the 09/20/2017.
%

%   HISTORY

% plane normal
n1 = normalizeVector3d(cross(plane1(:,4:6), plane1(:, 7:9), 2));
n2 = normalizeVector3d(cross(plane2(:,4:6), plane2(:, 7:9), 2));
n3 = normalizeVector3d(cross(plane3(:,4:6), plane3(:, 7:9), 2));

% Uses Hessian form, ie : N.p = d
% I this case, d can be found as : -N.p0, when N is normalized
d1 = dot(n1, plane1(:,1:3), 2);
d2 = dot(n2, plane2(:,1:3), 2);
d3 = dot(n3, plane3(:,1:3), 2);

% create coefficient and augmented matrices
A = [n1;n2;n3];
D = [d1;d2;d3];
AD = [n1,d1;n2,d2;n3,d3];

% calculate rank of the coefficient and augmented matrices
r1 = rank(A);
r2 = rank(AD);

% if rank of the coefficient matrix r1 = 3 and
% rank of the augmented matrix r2 = 3 return point
% and if r1 = 2 and r2 = 2 return line, 
% otherwise returns point with NaN values.
if r1 == 3 && r2 == 3
    % Intersecting at a point
    point = (A\D)';
else
    point = [NaN NaN NaN];
end

