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

function vertices = polygonVertices(poly)
%POLYGONVERTICES Extract all vertices of a (multi-)polygon.
%
%   VERTS = polygonVertices(POLY)
%   Returns the set of verttices from the polygon POLY. POLY can be either:
%   * a N-by-2 array of vertices. In that case, POLY and VERTS are the
%       same.
%   * a N-by-2 array of vertices with pairs of NaN values separating two
%       rings of the polygon. In that case, the array VERTS corresponds to
%       the vertices of the polygon, without copying the NaN values.
%   * a cell array of loops. In that case, the functions recursively
%       process the polygons and populated the vertex array.
%
%
%   Example
%     % create a polygon with a hole, using NaN for separating rings
%     ring1 = [0 0 ; 50 0;50 50;0 50];
%     ring2 = [20 20;20 30;30 30;30 20];
%     poly = [ring1 ; NaN NaN ; ring2];
%     figure; drawPolygon(poly, 'b'); 
%     axis([-10 60 -10 60]); axis equal; hold on;
%     verts = polygonVertices(poly);
%     drawPoint(verts, 'bo');
%
%     % create a polygon with a hole, storing rings in cell array
%     ring1 = [0 0 ; 50 0;50 50;0 50];
%     ring2 = [20 20;20 30;30 30;30 20];
%     poly = {ring1, ring2};
%     figure; drawPolygon(poly, 'b'); 
%     axis([-10 60 -10 60]); axis equal; hold on;
%     verts = polygonVertices(poly);
%     drawPoint(verts, 'bo');
%
%   See also
%     polygons2d, polygonEdges
 
% ------
% Author: David Legland
% e-mail: david.legland@inra.fr
% Created: 2018-06-07,    using Matlab 9.4.0.813654 (R2018a)
% Copyright 2018 INRA - Cepia Software Platform.


if isnumeric(poly)
    % find NaN or infinite values
    inds = sum(isfinite(poly), 2) == 2;
    
    % filter non-finite vertices if necessary
    if any(~inds)
        vertices = poly(inds, :);
    else
        vertices = poly;
    end
elseif iscell(poly)
    % process cell array
    vertices = zeros(0, 2);
    for i = 1:length(poly)
        vertices = [vertices ; polygonVertices(poly{i})]; %#ok<AGROW>
    end
end
