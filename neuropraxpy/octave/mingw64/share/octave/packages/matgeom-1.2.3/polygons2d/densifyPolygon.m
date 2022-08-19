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

function poly2 = densifyPolygon(poly, N)
%DENSIFYPOLYGON Add several points on each edge of the polygon.
%
%   POLY2 = densifyPolygon(POLY, N)
%   POLY is a NV-by-2 array containing polygon coordinates. The function
%   iterates on polygon edges, divides it into N subedges (by inserting N-1
%   new vertices on each edges), and return the resulting polygon.
%   The new polygon POLY has therefore N*NV vertices.
%
%   Example
%     % Densifies a simple polygon
%     poly = [0 0 ; 10 0;5 10;15 15;5 20;-5 10];
%     poly2 = densifyPolygon(poly, 10);
%     figure; drawPolygon(poly); axis equal
%     hold on; drawPoint(poly2);
%
%   See also
%     drawPolygon, edgeToPolyline
%
%
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2011-11-25,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2011 INRA - Cepia Software Platform.

% number of vertices, and of edges
Nv = size(poly, 1);

% number of vertices in new polygon
N2 = N * Nv;
poly2 = zeros(N2, 2);

% iterate on polygon edges
for i = 1:Nv
    % extract current edge
    v1 = poly(i, :);
    v2 = poly(mod(i, Nv) + 1, :);
    
    % convert current edge to polyline
    newVertices = edgeToPolyline([v1 v2], N);
    
    % indices of current polyline to resulting polygon
    i1 = (i-1)*N + 1;
    i2 = i * N;
    
    % fill up polygon
    poly2(i1:i2, :) = newVertices(1:end-1, :);
end

