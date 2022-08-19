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

function below = isBelowPlane(point, varargin)
%ISBELOWPLANE Test whether a point is below or above a plane.
%
%   BELOW = isBelowPlane(POINT, PLANE)
%   where POINT is given as coordinate row vector [XP YP ZP], and PLANE is
%   given as a row containing initial point and 2 direction vectors, 
%   return TRUE if POINT lie below PLANE.
%
%   Example
%   isBelowPlane([1 1 1], createPlane([1 2 3], [1 1 1]))
%   ans =
%       1
%   isBelowPlane([3 3 3], createPlane([1 2 3], [1 1 1]))
%   ans =
%       0
%
%   See also
%   planes3d, points3d, linePosition3d, planePosition
%
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2007-01-05
% Copyright 2007 INRA - BIA PV Nantes - MIAJ Jouy-en-Josas.

if length(varargin)==1
    plane = varargin{1};
elseif length(varargin)==2
    plane = createPlane(varargin{1}, varargin{2});
end

% ensure same dimension for parameters
if size(point, 1)==1
    point = repmat(point, [size(plane, 1) 1]);
end
if size(plane, 1)==1
    plane = repmat(plane, [size(point, 1) 1]);
end
    
% compute position of point projected on 3D line corresponding to plane
% normal, and returns true for points locatd below the plane (pos<=0).
below = linePosition3d(point, [plane(:, 1:3) planeNormal(plane)]) <= 0;
