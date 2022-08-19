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

function theta = angle2Points(varargin)
%ANGLE2POINTS Compute horizontal angle between 2 points.
%
%   ALPHA = angle2Points(P1, P2),
%   Pi are either [1*2] arrays, or [N*2] arrays, in this case ALPHA is a 
%   [N*1] array. The angle computed is the horizontal angle of the line 
%   (P1 P2)
%   Result is always given in radians, between 0 and 2*pi.
%
%   See Also:
%   points2d, angles2d, angle3points, normalizeAngle, vectorAngle
%
%
% ---------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% created the 02/03/2007.
% Copyright 2010 INRA - Cepia Software Platform.

%   HISTORY:
%   2011-01-11 use bsxfun

% process input arguments
if length(varargin)==2
    p1 = varargin{1};
    p2 = varargin{2};
elseif length(varargin)==1
    var = varargin{1};
    p1 = var(1,:);
    p2 = var(2,:);
end    

% ensure data have correct size
n1 = size(p1, 1);
n2 = size(p2, 1);
if n1~=n2 && min(n1, n2)>1
    error('angle2Points: wrong size for inputs');
end

% angle of line (P2 P1), between 0 and 2*pi.
dp = bsxfun(@minus, p2, p1);
theta = mod(atan2(dp(:,2), dp(:,1)) + 2*pi, 2*pi);

