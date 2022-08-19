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

function theta = polygon3dNormalAngle(points, ind)
%POLYGON3DNORMALANGLE Normal angle at a vertex of the 3D polygon.
%
%   THETA = polygon3DNormalAngle(POLYGON, IND)
%   where POLYGON is a set of points, and IND is index of a point in
%   polygon. The function compute the angle of the normal cone localized at
%   this vertex.
%   If IND is a vector of indices, normal angle is computed for each vertex
%   specified by IND.
%
%   Example
%   % create an equilateral triangle in space
%   poly3d = [1 1 0;-1 0 1;0 -1 -1];
%   % compute each normal angle
%   theta = polygon3dNormalAngle(poly3d, 1:size(poly3d, 1));
%   % sum of normal angles must be equal to 2*PI for simple polygons
%   sum(theta)
%
%   IMPORTANT NOTE: works only for convex angles ! ! ! !
%
%   See also
%   polygons3d, faceNormalAngle
%
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2005-11-30
% Copyright 2005 INRA - CEPIA Nantes - MIAJ (Jouy-en-Josas).


% number of points
np = size(points, 1);

% number of angles to compute
nv = length(ind);

theta = zeros(nv, 1);

for i=1:nv
    p0 = points(ind(i), :);
    
    if ind(i)==1
        p1 = points(np, :);
    else
        p1 = points(ind(i)-1, :);
    end
    
    if ind(i)==np
        p2 = points(1, :);
    else
        p2 = points(ind(i)+1, :);
    end
    
    theta(i) = pi - anglePoints3d(p1, p0, p2);
end
