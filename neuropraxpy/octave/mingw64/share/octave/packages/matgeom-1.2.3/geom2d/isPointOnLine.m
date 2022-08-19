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

function b = isPointOnLine(point, line, varargin)
%ISPOINTONLINE Test if a point belongs to a line.
%
%   B = isPointOnLine(POINT, LINE)
%   with POINT being [xp yp], and LINE being [x0 y0 dx dy].
%   Returns 1 if point lies on the line, 0 otherwise.
%
%   If POINT is an N-by-2 array of points, B is a N-by-1 array of booleans.
%
%   If LINE is a N-by-4 array of line, B is a 1-by-N array of booleans.
%
%   B = isPointOnLine(POINT, LINE, TOL)
%   Specifies the tolerance used for testing location on 3D line. Default value is 1e-14.
%
%   See also: 
%   lines2d, points2d, isPointOnEdge, isPointOnRay, isLeftOriented
%

%   ---------
%   author : David Legland 
%   INRA - TPV URPOI - BIA IMASTE
%   created the 31/10/2003.
%

%   HISTORY
%   11/03/2004 support for multiple inputs
%   08/12/2004 complete implementation, add doc
%   22/05/2009 rename to isPointOnLine, add psb to specify tolerance
%   17/12/2013 replace repmat by bsxfun (faster)

% extract computation tolerance
tol = 1e-14;
if ~isempty(varargin)
    tol = varargin{1};
end

% test if lines are colinear, using third coordinate of 3D cross-product
% same test as:
% b = abs((xp-x0).*dy-(yp-y0).*dx)./hypot(dx, dy).^2 < tol;
b = bsxfun(...
    @rdivide, abs(...
    bsxfun(@times, bsxfun(@minus, point(:,1), line(:,1)'), line(:,4)') - ...
    bsxfun(@times, bsxfun(@minus, point(:,2), line(:,2)'), line(:,3)')), ...
    (line(:,3).^2 + line(:,4).^2)') < tol;

