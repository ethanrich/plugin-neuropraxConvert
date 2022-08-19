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

function theta = polygonNormalAngle(poly, inds)
% Normal angle at each vertex of a polygon.
%
%   THETA = polygonNormalAngle(POLY);
%   where POLY is a N-by-2 array representing vertex coordinates, computes
%   the normal angle at each vertex of the polygon. THETA is a N-by-1 array
%   containing numeric values between -PI and +PI. The result depends on
%   the orientation of the polygon (counter-clockwise or clockwise).
%
%   THETA = polygonNormalAngle(POLY, IND);
%   Computes the normal angle for each vertex specified by IND. If IND is a
%   vector of vertex indices.
%
%
%   Example
%   % Normal angles at vertices of an isosceles right triangle are pi/2 at
%   % right angle-vertex and 3*pi/4 for the two remaining vertices. 
%     poly = [0 0 ; 1 0 ; 0 1];
%     polygonNormalAngle(poly)
%     ans =
%         1.5708
%         2.3562
%         2.3562
%
%   % Compute normal angles for a slightly more complicated polygon
%     poly = [0 0;0 1;-1 1;0 -1;1 0];
%     % compute normal angle at each vertex
%     theta = polygonNormalAngle(poly);
%     % sum of all normal angle of a non-intersecting polygon equals 2*pi
%     % (can be -2*pi if polygon is oriented clockwise)
%     sum(theta)
%     ans =
%         6.2832
%
%   See also:
%     polygons2d, polygonOuterNormal, normalizeAngle
%

% ------
% Author: David Legland
% e-mail: david.legland@inra.fr
% Created: 2005-11-30
% Copyright 2005 INRA - CEPIA Nantes - MIAJ (Jouy-en-Josas).

% number of polygon  vertices
np = size(poly, 1);

if nargin == 1
    inds = 1:np;
end

% number of angles to compute
nv = length(inds);

theta = zeros(nv, 1);

for i = 1:nv
    % current vertex
    curr = poly(inds(i), :);
    
    % previous and next vertices
    prev = poly(mod(inds(i)-2, np)+1, :);
    next = poly(mod(inds(i), np)+1, :);
    
    theta(i) = angle3Points(prev, curr, next) - pi;
end
