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

function theta = angle3Points(varargin)
%ANGLE3POINTS Compute oriented angle made by 3 points.
%
%   ALPHA = angle3Points(P1, P2, P3);
%   Computes the angle between the points P1, P2 and P3.
%   Pi are either [1*2] arrays, or [N*2] arrays, in this case ALPHA is a 
%   [N*1] array. The angle computed is the directed angle between line 
%   (P2P1) and line (P2P3).
%   Result is always given in radians, between 0 and 2*pi.
%
%   See Also:
%   points2d, angles2d, angle2points
%
%
%   ---------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% created the 23/02/2004.
% Copyright 2010 INRA - Cepia Software Platform.


%   HISTORY :
%   25/09/2005 : enable single parameter

if length(varargin)==3
    p1 = varargin{1};
    p2 = varargin{2};
    p3 = varargin{3};
elseif length(varargin)==1
    var = varargin{1};
    p1 = var(1,:);
    p2 = var(2,:);
    p3 = var(3,:);
end    

% angle line (P2 P1)
theta = lineAngle(createLine(p2, p1), createLine(p2, p3));

