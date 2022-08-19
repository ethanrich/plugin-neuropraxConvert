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

function index = findPoint(coord, points, varargin)
%FINDPOINT Find index of a point in an set from its coordinates.
% 
%   IND = findPoint(POINT, ARRAY) 
%   Returns the index of point whose coordinates match the 1-by-2 row array
%   POINT in the N-by-2 array ARRAY. If the point is not found, returns 0.
%   If several points are found, keep only the first one.
%
%   If POINT is a M-by-2 array, the result is a M-by-1 array, containing
%   the index in the array of each point given by COORD, or 0 if the point
%   is not found.
%
%   IND = findPoint(POINT, ARRAY, TOL) 
%   use specified tolerance, to find point within a distance of TOL.
%   Default tolerance is zero.
%
%   See also
%    points2d, minDistancePoints, distancePoints, findClosestPoint

%   -----
%   author: David Legland 
%   INRA - TPV URPOI - BIA IMASTE
%   created the 17/07/2003.
%

%   HISTORY
%   10/02/2004 documentation
%   09/08/2004 rewrite faster, and add support for multiple points

% number of points
np = size(coord, 1);

% allocate memory for result
index = zeros(np, 1);

% specify the tolerance
tol = 0;
if ~isempty(varargin)
    tol = varargin{1};
end

if tol == 0
    for i = 1:np
        % indices of matches
        ind = find(points(:,1) == coord(i,1) & points(:,2) == coord(i,2));
        
        % format current result
        if isempty(ind)
            index(i) = 0;
        else
            index(i) = ind(1);
        end
    end
else
    for i = 1:np
        % indices of matches
        ind = find(sqrt(sum(bsxfun(@minus, points, coord) .^ 2, 2)) <= tol);
        
        % format current result
        if isempty(ind)
            index(i) = 0;
        else
            index(i) = ind(1);
        end
    end
end
