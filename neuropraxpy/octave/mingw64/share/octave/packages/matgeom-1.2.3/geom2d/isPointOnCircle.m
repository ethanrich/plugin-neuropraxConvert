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

function b = isPointOnCircle(point, circle, varargin)
%ISPOINTONCIRCLE Test if a point is located on a given circle.
%
%   B = isPointOnCircle(POINT, CIRCLE) 
%   return true if point is located on the circle, i.e. if the distance to
%   the circle center equals the radius up to an epsilon value.
%
%   B = isPointOnCircle(POINT, CIRCLE, TOL) 
%   Specifies the tolerance value.
%
%   Example:
%   isPointOnCircle([1 0], [0 0 1])
%   returns true, whereas
%   isPointOnCircle([1 1], [0 0 1])
%   return false
%
%   See also:
%   circles2d, isPointInCircle
%
%   ---------
%   author : David Legland 
%   INRA - TPV URPOI - BIA IMASTE
%   created the 07/04/2004.
%

%   HISTORY
%   22/05/2009 rename to isPointOnCircle, add psb to specify tolerance

tol = 1e-14;
if ~isempty(varargin)
    tol = varargin{1};
end

d = sqrt(sum(power(point - circle(:,1:2), 2), 2));
b = abs(d-circle(:,3))<tol;
    
