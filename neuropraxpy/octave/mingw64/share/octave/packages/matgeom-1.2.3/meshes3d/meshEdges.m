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

function edges = meshEdges(faces, varargin)
%MESHEDGES Computes array of edge vertex indices from face array.
%
%   EDGES = meshEdges(FACES);
%
%   Example
%     meshEdges
%
%   See also
%     meshes3d, meshEdgeFaces, meshFaceEdges

% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2011-06-28,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2011 INRA - Cepia Software Platform.

%   HISTORY
%   2013-08-22 rename from computeMeshEdges to meshEdges, add more control
%       on inputs

%% Process input arguments

if isstruct(faces) && isfield(faces, 'faces')
    % if input is a mesh structure, extract the 'faces' field
    faces = faces.faces;
elseif nargin > 1
    % if two arguments are given, keep the second one
    faces = varargin{1};
end


if ~iscell(faces)
    %% Process faces given as numeric array
    % all faces have same number of vertices, stored in nVF variable
    
    % compute total number of edges
    nFaces  = size(faces, 1);
    nVF     = size(faces, 2);
    nEdges  = nFaces * nVF;
    
    % create all edges (with double ones)
    edges = zeros(nEdges, 2);
    for i = 1:nFaces
        f = faces(i, :);
        edges(((i-1)*nVF+1):i*nVF, :) = [f' f([2:end 1])'];
    end
    
else
    %% faces are given as a cell array
    % faces may have different number of vertices
    
    % number of faces
    nFaces  = length(faces);
    
    % compute the number of edges
    nEdges = 0;
    for i = nFaces
        nEdges = nEdges + length(faces{i});
    end
    
    % allocate memory
    edges = zeros(nEdges, 2);
    ind = 0;
    
    % fillup edge array
    for i = 1:nFaces
        % get vertex indices, ensuring horizontal array
        f = faces{i}(:)';
        nVF = length(f);
        edges(ind+1:ind+nVF, :) = [f' f([2:end 1])'];
        ind = ind + nVF;
    end
    
end

% keep only unique edges, and return sorted result
edges = sortrows(unique(sort(edges, 2), 'rows'));
