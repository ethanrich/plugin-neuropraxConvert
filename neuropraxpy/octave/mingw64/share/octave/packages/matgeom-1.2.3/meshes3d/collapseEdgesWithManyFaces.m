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

function [vertices, faces] = collapseEdgesWithManyFaces(vertices, faces, varargin)
% removes mesh edges adjacent to more than two faces
%
%   [V2, F2] = collapseEdgesWithManyFaces(V, F)
%   Count the number of faces adjacent to each edge, and collapse the edges
%   adjacent to more than two faces. 
%
%
%   Example
%   collapseEdgesWithManyFaces
%
%   See also
%       trimMesh, isManifoldMesh
 
% ------
% Author: David Legland
% e-mail: david.legland@inra.fr
% Created: 2019-01-31,    using Matlab 9.5.0.944444 (R2018b)
% Copyright 2019 INRA - Cepia Software Platform.

verbose = false;
while length(varargin) > 1 && ischar(varargin{1})
    name = varargin{1};
    if strcmpi(name, 'verbose')
        verbose = varargin{2};
    else
        error(['Unknown optional argument: ' name]);
    end
    varargin(1:2) = [];
end

while true
    % compute edge to vertex mapping
    edges = meshEdges(faces);
    
    % compute number of faces incident to each edge
    edgeFaces = trimeshEdgeFaces(faces);
    edgeFaceDegrees = sum(edgeFaces > 0, 2);
    
    inds = find(edgeFaceDegrees > 2);
    
    if isempty(inds)
        break;
    end
    
    edge = edges(inds(1), :);
    if verbose
        fprintf('remove edge with index %d: (%d, %d)\n', inds(1), edge);
    end
    [vertices, faces] = mergeMeshVertices(vertices, faces, edge);
end

% trim
[vertices, faces] = trimMesh(vertices, faces);
