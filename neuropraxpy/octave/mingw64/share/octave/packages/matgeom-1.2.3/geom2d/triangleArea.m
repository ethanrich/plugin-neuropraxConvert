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

function area = triangleArea(pt1, pt2, pt3)
%TRIANGLEAREA Signed area of a triangle.
%
%   AREA = triangleArea(P1, P2, P3)
%   Computes area of the triangle whose vertices are given by P1, P2 and
%   P3. Each vertex is a 1-by-2 row vector. 
%
%   AREA = triangleArea(PTS)
%   Concatenates vertex coordinates in a 3-by-2 array. Each row of the
%   array contains coordinates of one vertex.
%
%
%   Example
%   % Compute area of a Counter-Clockwise (CCW) oriented triangle
%     triangleArea([10 10], [30 10], [10 40])
%     ans = 
%         300
%
%   % Compute area of a Clockwise (CW) oriented triangle
%     triangleArea([10 40], [30 10], [10 10])
%     ans = 
%         -300
%
%   See also
%   polygonArea, triangleArea3d
%
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2011-08-23,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2011 INRA - Cepia Software Platform.

% if data is given as one array, split vertices
if nargin == 1
    pt2 = pt1(2,:);
    pt3 = pt1(3,:);
    pt1 = pt1(1,:);
end

% compute individual vectors
v12 = bsxfun(@minus, pt2, pt1);
v13 = bsxfun(@minus, pt3, pt1);

% compute area from cross product
area = (v13(:,2) .* v12(:,1) - v13(:,1) .* v12(:,2)) / 2;
