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

function FE = meshFaceEdges(vertices, edges, faces)
%MESHFACEEDGES Computes edge indices of each face.
%
%   FE = meshFaceEdges(V, E, F)
%   Returns a 1-by-NF cell array containing for each face, the set of edge
%   indices corresponding to adjacent edges.
%
%   Example
%   meshFaceEdges
%
%   See also
%     meshes3d, meshEdgeFaces

% ------
% Author: David Legland
% e-mail: david.legland@inra.fr
% Created: 2013-08-22,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2013 INRA - Cepia Software Platform.

nFaces = meshFaceNumber(vertices, faces);

FE = cell(nFaces, 1);

% impose ordering of edge indices
edges = sort(edges, 2);

for iFace = 1:nFaces
    % extract vertex indices of current face
    face = meshFace(faces, iFace);
    nv = length(face);
    
    % for each couple of adjacent vertices, find the index of the matching
    % row in the edges array
    fei = zeros(1, nv);
    for iEdge = 1:nv
        % compute index of each edge vertex
        edge = sort([face(iEdge) face(mod(iEdge, nv) + 1)]);
        v1 = edge(1);
        v2 = edge(2);

        % find the matching row 
        ind = find(edges(:,1) == v1 & edges(:,2) == v2);
        fei(iEdge) = ind;
        
    end
    FE{iFace} = fei;
end
