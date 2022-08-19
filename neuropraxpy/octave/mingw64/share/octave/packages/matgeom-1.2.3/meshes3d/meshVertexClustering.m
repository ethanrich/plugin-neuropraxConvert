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

function varargout = meshVertexClustering(vertices, faces, spacing, varargin)
%MESHVERTEXCLUSTERING Simplifies a mesh using vertex clustering.
%
%   [V2, F2] = meshVertexClustering(V, F, SPACING)
%   [V2, F2] = meshVertexClustering(MESH, SPACING)
%   MESH2 = meshVertexClustering(...)
%
%   Simplifies a mesh using vertex clustering. Input mesh is specified
%   either by a pair V, F containing the vertex coordinates and the faces
%   informations, or by a structure with fields 'vertices' and 'faces'.
%
%   The SPACING input defines the size of the grid. It can be either a
%   scalar (uniform grid) or a 1-by-3 row vector. 
%
%   The output is specified either in two outputs, or in a structure with
%   fields 'vertices' and 'faces'.
%
%   Example
%     [x, y, z]  = meshgrid(1:100, 1:100, 1:100);
%     img = hypot3(x-51.12, y-52.23, z-53.34);
%     [faces, vertices] = isosurface(img, 45);
%     [v2, f2] = meshVertexClustering(vertices, faces, 10);
%     figure; axis equal; axis([0 100 0 100 0 100]);
%     drawMesh(v2, f2);
%
%   See also
%     reducepatch, smoothMesh
 
% ------
% Author: David Legland
% e-mail: david.legland@inra.fr
% Created: 2019-01-28,    using Matlab 9.5.0.944444 (R2018b)
% Copyright 2019 INRA - Cepia Software Platform.


%% Initialisation

if isstruct(vertices)
    if nargin > 2
        varargin = [{spacing} varargin(:)];
    end
    spacing = faces;

    mesh = vertices;
    vertices = mesh.vertices;
    faces = mesh.faces;
end

% ensure input mesh is a triangulation
faces = triangulateFaces(faces);

% ensure spacing is a 1-by-3 array
if isscalar(spacing)
    spacing = [spacing spacing spacing];
end

% extract grid origin
origin = [0 0 0];
if ~isempty(varargin)
    origin = varargin{1};
end


%% Apply grid simplification

% identify the vertices belonging to the same grid
[v2, I, J] = unique(round(bsxfun(@rdivide, bsxfun(@minus, vertices, origin), spacing)), 'rows');


%% compute reduced vertex coordinates

% compute coordinates of new vertices
for iVertex = 1:length(I)
    gridVertices = vertices(J == iVertex, :);
    v2(iVertex, :) = mean(gridVertices, 1);
end


%% Compute new faces

% create empty array
faces2 = zeros(0, 3);

% iterate over old faces, and keep only faces whose vertices belong to
% different cell grids
nFaces = size(faces, 1);
for iFace = 1:nFaces
    % current face
    face = faces(iFace, :);
    
    % equivalent face with new vertices
    face2 = J(face)';
    
    % some vertices may belong to same cell, so we need to adjust
    % processing
    nInds = length(unique(face2));
    if nInds == 3
        % vertices belong to three different cells -> create a new face
        
        % keep smaller vertex at first position
        [tmp, indMin] = min(face2); %#ok<ASGLU>
        face2 = circshift(face2, [1-indMin 0]);
        
        % append the new face to the array
        faces2 = [faces2 ; face2]; %#ok<AGROW>
    end
end

% remove duplicate faces
faces2 = unique(faces2, 'rows');

if nargout == 1
    varargout{1} = struct('vertices', v2, 'faces', faces2);
else
    varargout = {v2, faces2};
end
