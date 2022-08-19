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

function varargout = angleSort3d(pts, varargin)
%ANGLESORT3D Sort 3D coplanar points according to their angles in plane.
%
%   PTS2 = angleSort3d(PTS);
%   Considers all points are located on the same plane, and sort them
%   according to the angle on plane. PTS is a [Nx2] array. Note that the
%   result depends on the plane orientation: points can be in reverse order
%   compared to expected. The reference plane is computed based on the
%   first three points.
%
%   PTS2 = angleSort3d(PTS, PTS0);
%   Computes angles between each point of PTS and PT0. By default, uses
%   centroid of points.
%
%   PTS2 = angleSort3d(PTS, PTS0, PTS1);
%   Specifies the point which will be used as a start.
%
%   [PTS2, I] = angleSort3d(...);
%   Also return in I the indices of PTS, such that PTS2 = PTS(I, :);
%
%   See also:
%   points3d, angles3d, angleSort
%
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2005-11-24
% Copyright 2005 INRA - CEPIA Nantes - MIAJ (Jouy-en-Josas).


%   HISTORY :
%   04/01/2007: remove unused variables

% default values
pt0     = mean(pts, 1);
pt1     = pts(1,:);

if length(varargin)==1
    pt0 = varargin{1};
elseif length(varargin)==2
    pt0 = varargin{1};
    pt1 = varargin{2};
end

% create support plane
plane   = createPlane(pts(1:3, :));

% project points onto the plane
pts2d   = planePosition(pts, plane);
pt0     = planePosition(pt0, plane);
pt1     = planePosition(pt1, plane);

% compute origin angle
theta0  = atan2(pt1(2)-pt0(2), pt1(1)-pt0(1));
theta0  = mod(theta0 + 2*pi, 2*pi);

% translate to reference point
n       = size(pts, 1);
pts2d   = pts2d - repmat(pt0, [n 1]);

% compute angles
angle   = atan2(pts2d(:,2), pts2d(:,1));
angle   = mod(angle - theta0 + 4*pi, 2*pi);

% sort points according to angles
[angle, I] = sort(angle); %#ok<ASGLU>


% format output
if nargout<2
    varargout{1} = pts(I, :);
elseif nargout==2
    varargout{1} = pts(I, :);
    varargout{2} = I;
end

