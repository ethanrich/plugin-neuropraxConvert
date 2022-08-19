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

function b = isLeftOriented(point, line)
%ISLEFTORIENTED Test if a point is on the left side of a line.
%
%   B = isLeftOriented(POINT, LINE);
%   Returns TRUE if the point lies on the left side of the line with
%   respect to the line direction.
%   
%   If POINT is a NP-by-2 array, and/or LINE is a NL-by-4 array, the result
%   is a NP-by-NL array containing the result for each point-line
%   combination.
%
%   See also:
%   lines2d, points2d, isCounterClockwise, isPointOnLine, distancePointLine
%

%   ---------
%   author : David Legland 
%   INRA - TPV URPOI - BIA IMASTE
%   created the 31/07/2005.

%   HISTORY
%   2017-09-04 uses bsxfun

% equivalent to:
% b = (xp-x0).*dy-(yp-y0).*dx < 0;
b = bsxfun(@minus, ...
    bsxfun(@times, bsxfun(@minus, point(:,1), line(:,1)'), line(:,4)'), ...
    bsxfun(@times, bsxfun(@minus, point(:,2), line(:,2)'), line(:,3)')) < 0;
    
