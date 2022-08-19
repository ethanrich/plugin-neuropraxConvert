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

function b = isPointOnLine3d(point, line, varargin)
%ISPOINTONLINE3D Test if a 3D point belongs to a 3D line.
%
%   B = isPointOnLine3d(POINT, LINE)
%   with POINT being [xp yp zp], and LINE being [x0 y0 z0 dx dy dz].
%   Returns 1 if point lies on the line, 0 otherwise.
%
%   If POINT is an N-by-3 array of points, B is a N-by-1 array of booleans.
%
%   If LINE is a N-by-6 array of lines, B is a N-by-1 array of booleans.
%
%   B = isPointOnLine3d(POINT, LINE, TOL)
%   Specifies the tolerance used for testing location on 3D line.
%
%   See also: 
%   lines3d, distancePointLine3d, linePosition3d, isPointOnLine
%

% ---------
% author : David Legland 
% e-mail: david.legland@inra.fr
% INRA - TPV URPOI - BIA IMASTE
% created the 31/10/2003.
%

%   HISTORY
%   17/12/2013 create from isPointOnLine

% extract computation tolerance
tol = 1e-14;
if ~isempty(varargin)
    tol = varargin{1};
end

% size of inputs
np = size(point,1);
nl = size(line, 1);

if np == 1 || nl == 1 || np == nl
    % test if lines are colinear, using norm of the cross product
    b = bsxfun(@rdivide, vectorNorm3d( ...
        crossProduct3d(bsxfun(@minus, line(:,1:3), point), line(:,4:6))), ...
        vectorNorm3d(line(:,4:6))) < tol;
else
    % same test, but after reshaping arrays to manage difference of
    % dimensionality
    point = reshape(point, [np 1 3]);
    line = reshape(line, [1 nl 6]);
    b = bsxfun(@rdivide, vectorNorm3d( ...
        cross(bsxfun(@minus, line(:,:,1:3), point), line(ones(1,np),:,4:6), 3)), ...
        vectorNorm3d(line(:,:,4:6))) < tol;
end
