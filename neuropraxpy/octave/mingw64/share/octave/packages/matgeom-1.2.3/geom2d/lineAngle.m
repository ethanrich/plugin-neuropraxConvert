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

function theta = lineAngle(varargin)
%LINEANGLE Computes angle between two straight lines.
%
%   A = lineAngle(LINE);
%   Returns the angle between horizontal, right-axis and the given line.
%   Angle is given in radians, between 0 and 2*pi, in counter-clockwise
%   direction.
%
%   A = lineAngle(LINE1, LINE2);
%   Returns the directed angle between the two lines. Angle is given in
%   radians between 0 and 2*pi, in counter-clockwise direction.
%
%   See also
%   lines2d, angles2d, createLine, normalizeAngle
%
%   ---------
%   author : David Legland 
%   INRA - TPV URPOI - BIA IMASTE
%   created the 31/10/2003.
%

%   HISTORY
%   2004-02-19 added support for multiple lines.
%   2011-01-20 use bsxfun

nargs = length(varargin);
if nargs == 1
    % angle of one line with horizontal
    line = varargin{1};
    theta = mod(atan2(line(:,4), line(:,3)) + 2*pi, 2*pi);
    
elseif nargs==2
    % angle between two lines
    theta1 = lineAngle(varargin{1});
    theta2 = lineAngle(varargin{2});
    theta = mod(bsxfun(@minus, theta2, theta1)+2*pi, 2*pi);
end
