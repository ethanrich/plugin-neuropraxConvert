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

function pos = planePosition(point, plane)
%PLANEPOSITION Compute position of a point on a plane.
%
%   PT2 = planePosition(POINT, PLANE)
%   POINT has format [X Y Z], and plane has format
%   [X0 Y0 Z0  DX1 DY1 DZ1  DX2 DY2 DZ2], where :
%   - (X0, Y0, Z0) is a point belonging to the plane
%   - (DX1, DY1, DZ1) is a first direction vector
%   - (DX2, DY2, DZ2) is a second direction vector
%
%   Result PT2 has the form [XP YP], with [XP YP] coordinate of the point
%   in the coordinate system of the plane.
%
%   
%   CAUTION:
%   WORKS ONLY FOR PLANES WITH ORTHOGONAL DIRECTION VECTORS
%
%   Example
%     plane = [10 20 30  1 0 0  0 1 0];
%     point = [13 24 35];
%     pos = planePosition(point, plane)
%     pos = 
%         3   4
%
%   See also:
%   geom3d, planes3d, points3d, planePoint

%   ---------
%   author : David Legland 
%   INRA - TPV URPOI - BIA IMASTE
%   created the 21/02/2005.
%

%   HISTORY
%   24/11/2005 add support for multiple inputs

% size of input arguments
npl = size(plane, 1);
npt = size(point, 1);

% check inputs have compatible sizes
if npl ~= npt && npl > 1 && npt > 1
    error('geom3d:planePoint:inputSize', ...
        'plane and point should have same size, or one of them must have 1 row');
end

% origin and direction vectors of the plane
p0 = plane(:, 1:3);
d1 = plane(:, 4:6);
d2 = plane(:, 7:9);

% Compute dot products with direction vectors of the plane
if npl > 1 || npt == 1
    s = dot(bsxfun(@minus, point, p0), d1, 2) ./ vectorNorm3d(d1);
    t = dot(bsxfun(@minus, point, p0), d2, 2) ./ vectorNorm3d(d2);
else
    % we have npl == 1 and npt > 1
    d1 = d1 / vectorNorm3d(d1);
    d2 = d2 / vectorNorm3d(d2);
    inds = ones(npt,1);
    s = dot(bsxfun(@minus, point, p0), d1(inds, :), 2);
    t = dot(bsxfun(@minus, point, p0), d2(inds, :), 2);
end

% % old version:
% s = dot(point-p0, d1, 2) ./ vectorNorm3d(d1);
% t = dot(point-p0, d2, 2) ./ vectorNorm3d(d2);

pos = [s t];

