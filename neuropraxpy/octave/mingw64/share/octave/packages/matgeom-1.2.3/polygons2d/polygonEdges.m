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

function edges = polygonEdges(poly)
%POLYGONEDGES Return the edges of a simple or multiple polygon.
%
%   EDGES = polygonEdges(POLY)
%   Return the set of edges of the polygon specified by POLY. POLY may be
%   either a simple polygon given as a N-by-2 array of vertices, or a
%   multiple polygon given by a cell array of linear rings, each ring being
%   given as N-by-2 array of vertices.
%
%
%   Example
%     poly = [50 10;60 10;60 20;50 20];
%     polygonEdges(poly)
%     ans =
%         50    10    60    10
%         60    10    60    20
%         60    20    50    20
%         50    20    50    10
%
%   See also
%     polygons2d, polygonVertices
 
% ------
% Author: David Legland
% e-mail: david.legland@inra.fr
% Created: 2017-08-29,    using Matlab 9.1.0.441655 (R2016b)
% Copyright 2017 INRA - Cepia Software Platform.

% test presence of NaN values
if isnumeric(poly) && any(isnan(poly(:)))
    poly = splitPolygons(poly);
end

% create the array of polygon edges
if iscell(poly)
    % process multiple polygons
    edges = zeros(0, 4);
    for i = 1:length(poly)
        pol = poly{i};
        N = size(pol, 1);
        edges = [edges; pol(1:N, :) pol([2:N 1], :)]; %#ok<AGROW>
    end
else
    % get edges of a simple polygon
    N = size(poly, 1);
    edges = [poly(1:N, :) poly([2:N 1], :)];
end
