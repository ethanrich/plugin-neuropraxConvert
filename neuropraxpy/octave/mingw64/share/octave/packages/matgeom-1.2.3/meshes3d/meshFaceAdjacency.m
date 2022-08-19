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

function adjList = meshFaceAdjacency(vertices, edges, faces)
%MESHFACEADJACENCY Compute adjacency list of face around each face.
%
%
%   Example
%     % Create a sample 3D mesh
%     [v, e, f] = createDodecahedron;
%     adjList = meshFaceAdjacency(v, e, f);
%     figure; hold on; axis equal; view([100 40]);
%     drawMesh(v, f);
%     % draw sample face in a different color
%     drawMesh(v, f(1, :), 'faceColor', 'b');
%     % draw the neighbors of a sample face
%     drawMesh(v, f(adjList{1}, :), 'faceColor', 'g')
%     
% 

% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2010-10-04,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2010 INRA - Cepia Software Platform.


edgeFaceList = meshEdgeFaces(vertices, edges, faces);

% allocate memory for adjacency list
nFaces = max(edgeFaceList(:));
adjList = cell(1, nFaces);

% iterate over edges to populate adjacency list
for iEdge = 1:size(edgeFaceList)
    f1 = edgeFaceList(iEdge, 1);
    f2 = edgeFaceList(iEdge, 2);
    adjList{f1} = [adjList{f1} f2];
    adjList{f2} = [adjList{f2} f1];
end
