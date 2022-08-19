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

function varargout = clipMeshVertices(v, f, b, varargin)
%CLIPMESHVERTICES Clip vertices of a surfacic mesh and remove outer faces.
%
%   [V2, F2] = clipMeshVertices(V, F, B)
%   Clip a mesh represented by vertex array V and face array F, with the
%   box represented by B. The result is the set of vertices contained in
%   the box, and a new set of faces corresponding to original faces with
%   all vertices within the box.
%   
%   [V2, F2] = clipMeshVertices(..., 'shape', 'sphere') Specify the shape.
%   Default is 'box'. But it is also possible to use 'sphere' or 'plane'.
%   
%   [V2, F2] = clipMeshVertices(..., 'inside', false) removes the inner 
%   faces instead of the outer faces.
%
%   [V2, F2] = clipMeshVertices(..., 'trimMesh', TF)
%   Also specifies if the isolated vertices need to be removed (TF=true) ot
%   not (TF=false). Default is false.
%
%
%   Example
%     [v, f] = createSoccerBall;
%     f = triangulateFaces(f);
%     box = [0 2 -1 2 -.5 2];
%     [v2, f2] = clipMeshVertices(v, f, box, 'inside', false);
%     figure('color','w'); view(3); axis equal
%     drawMesh(v, f, 'faceColor', 'none', 'faceAlpha', .2);
%     drawBox3d(box)
%     drawMesh(v2, f2, 'faceAlpha', .7);
%
%   See also
%   meshes3d, clipPoints3d
%

% ------
% Author: David Legland, oqilipo
% e-mail: david.legland@inra.fr
% Created: 2011-04-07,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2011 INRA - Cepia Software Platform.

% if input is given as a structure, parse fields
if isstruct(v)
    if nargin > 2
        varargin = [b, varargin]; 
    end
    b = f;
    f = v.faces;
    v = v.vertices;
end

parser = inputParser;
validStrings = {'box', 'sphere', 'plane'};
addParameter(parser, 'shape', 'box', @(x) any(validatestring(x, validStrings)));
addParameter(parser, 'inside', true, @islogical);
addParameter(parser, 'trimMesh', false, @islogical);
parse(parser, varargin{:});

% clip the vertices
[v2, indVertices] = clipPoints3d(v, b,...
    'shape', parser.Results.shape, 'inside', parser.Results.inside);

% create index array for face indices relabeling
refInds = zeros(size(indVertices));
for i = 1:length(indVertices)
    refInds(indVertices(i)) = i;
end

% select the faces with all vertices within the box
if isnumeric(f)
    % Faces given as numeric array
    indFaces = sum(~ismember(f, indVertices), 2) == 0;
    f2 = refInds(f(indFaces, :));
    
elseif iscell(f)
    % Faces given as cell array
    nFaces = length(f);
    indFaces = false(nFaces, 1);
    for i = 1:nFaces
        indFaces(i) = sum(~ismember(f{i}, indVertices), 2) == 0;
    end
    f2 = f(indFaces, :);
    
    % re-label indices of face vertices (keeping horizontal index array)
    for i = 1:length(f2)
        f2{i} = refInds(f2{i})';
    end
end

if parser.Results.trimMesh
    [v2, f2] = trimMesh(v2, f2);
end

varargout = formatMeshOutput(nargout, v2, f2);
