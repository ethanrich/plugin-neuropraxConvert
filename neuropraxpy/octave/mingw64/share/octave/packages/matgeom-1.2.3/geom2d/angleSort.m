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

function varargout = angleSort(pts, varargin)
%ANGLESORT Sort points in the plane according to their angle to origin.
%
%
%   PTS2 = angleSort(PTS);
%   Computes angle of points with origin, and sort points with increasing
%   angles in Counter-Clockwise direction.
%
%   PTS2 = angleSort(PTS, PTS0);
%   Computes angles between each point of PTS and PT0, which can be
%   different from origin.
%
%   PTS2 = angleSort(..., THETA0);
%   Specifies the starting angle for sorting.
%
%   [PTS2, I] = angleSort(...);
%   Also returns in I the indices of PTS, such that PTS2 = PTS(I, :);
%
%   [PTS2, I, ANGLES] = angleSort(...);
%   Also returns the ANGLES in corresponding order to PTS2.
%
%   See Also:
%   points2d, angles2d, angle2points, normalizeAngle
%
%
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2005-11-24
% Copyright 2010 INRA - Cepia Software Platform.


%   HISTORY :

% default values
pt0 = [0 0];
theta0 = 0;

if length(varargin)==1
    var = varargin{1};
    if size(var, 2)==1
        % specify angle
        theta0 = var;
    else
        pt0 = var;
    end
elseif length(varargin)==2
    pt0 = varargin{1};
    theta0 = varargin{2};
end


n = size(pts, 1);
pts2 = pts - repmat(pt0, [n 1]);
angle = lineAngle([zeros(n, 2) pts2]);
angle = mod(angle - theta0 + 2*pi, 2*pi);

[angles, I] = sort(angle); 

% format output
switch nargout
    case 1
        varargout{1} = pts(I, :);
    case 2
        varargout{1} = pts(I, :);
        varargout{2} = I;
    case 3
        varargout{1} = pts(I, :);
        varargout{2} = I;
        varargout{3} = angles;
end

        
