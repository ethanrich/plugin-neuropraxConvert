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

function len = polygonLength(poly, varargin)
%POLYGONLENGTH Perimeter of a polygon.
%
%   L = polygonLength(POLYGON);
%   Computes the boundary length of a polygon. POLYGON is given by a N-by-2
%   array of vertices. 
%
%   Example
%     % Perimeter of a circle approximation
%     poly = circleToPolygon([0 0 1], 200);
%     polygonLength(poly)
%     ans =
%         6.2829
%
%   See also:
%   polygons2d, polygonCentroid, polygonArea, drawPolygon, polylineLength
%

%   ---------
%   author : David Legland 
%   INRA - TPV URPOI - BIA IMASTE
%   created the 11/05/2005.
%

%   HISTORY
%   2011-03-31 add control for empty polygons, code cleanup
%   2011-05-27 fix bugs

% If first argument is a cell array, this is a multi-polygon, and we simply
% add the lengths of individual polygons
if iscell(poly)
    len = 0;
    for i = 1:length(poly)
        len = len + polygonLength(poly{i});
    end
    return;
end

% case of a polygon given as two coordinate arrays
if nargin == 2
    poly = [poly varargin{1}];
end

% check there are enough points
if size(poly, 1) < 2
    len = 0;
    return;
end

% compute length
if size(poly, 2) == 2
    % polygon in dimension 2 (classical case)
    dp = diff(poly([1:end 1], :), 1, 1);
    len = sum(hypot(dp(:, 1), dp(:, 2)));
else
    % polygon of larger dimension
    len = sum(sqrt(sum(diff(poly([2:end 1], :), 1, 1).^2, 2)));
end
