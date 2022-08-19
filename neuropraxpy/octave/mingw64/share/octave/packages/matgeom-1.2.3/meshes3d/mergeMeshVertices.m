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

function [vertices, faces] = mergeMeshVertices(vertices, faces, vertexInds, varargin)
%MERGEMESHVERTICES Merge two vertices and removes eventual degenerated faces.
%
%   output = mergeMeshVertices(input)
%
%   Example
%   mergeMeshVertices
%
%   See also
%
 
% ------
% Author: David Legland
% e-mail: david.legland@inra.fr
% Created: 2019-01-31,    using Matlab 9.5.0.944444 (R2018b)
% Copyright 2019 INRA - Cepia Software Platform.

newPos = vertices(vertexInds(1), :);
if nargin > 3
    newPos = varargin{1};
end

vertices(vertexInds(1), :) = newPos;
vertices(vertexInds(2:end), :) = NaN;

% replace face-vertex indices by index of first vertex
faces(ismember(faces, vertexInds)) = vertexInds(1);

% need to check existence of degenerated faces with same vertex twice
nFaces = size(faces, 1);
dgnFaces = false(nFaces, 1);
dims = [1 2;1 3;2 3];
for i = 1:3
    dgnFaces = dgnFaces | faces(:,dims(i,1)) == faces(:,dims(i,2));
end

% remove degenerated faces
faces(dgnFaces, :) = [];
