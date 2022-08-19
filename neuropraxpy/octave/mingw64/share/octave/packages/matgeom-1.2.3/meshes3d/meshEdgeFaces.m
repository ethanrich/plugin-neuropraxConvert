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

function edgeFaces = meshEdgeFaces(vertices, edges, faces) %#ok<INUSL>
%MESHEDGEFACES Compute index of faces adjacent to each edge of a mesh.
%
%   EF = meshEdgeFaces(V, E, F)
%   Compute index array of faces adjacent to each edge of a mesh.
%   V, E and F define the mesh: V is vertex array, E contains vertex
%   indices of edge extremities, and F contains vertex indices of each
%   face, either as a numerical array or as a cell array.
%   The result EF has as many rows as the number of edges, and two column.
%   The first column contains index of faces located on the left of the
%   corresponding edge, whereas the second column contains index of the
%   face located on the right. Some indices may be 0 if the mesh is not
%   'closed'.
%   
%   Note: a faster version is available for triangular meshes.
%
%   Example
%   meshEdgeFaces
%
%   See also
%   meshes3d, trimeshEdgeFaces, meshDihedralAngles, polyhedronMeanBreadth

% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2010-10-04,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2010 INRA - Cepia Software Platform.

Ne = size(edges, 1);

% indices of faces adjacent to each edge
edgeFaces = zeros(Ne, 2);

% different method for extracting current face depending if faces are
% stored as index 2D array or as cell array of 1D arrays.
if isnumeric(faces)
    Nf = size(faces, 1);
    for i = 1:Nf
        face = faces(i, :);
        processFace(face, i)
    end
elseif iscell(faces)
    Nf = length(faces);
    for i = 1:Nf
        face = faces{i};
        processFace(face, i)
    end
end

    function processFace(face, indFace)
        % iterate on face edges
        for j = 1:length(face)
            % build edge: array of vertices
            j2 = mod(j, length(face)) + 1;
            
            % do not process edges with same vertices
            if face(j) == face(j2)
                continue;
            end
            
            % vertex indices of current edge
            currentEdge = [face(j) face(j2)];
            
            % find index of current edge, assuming face is left-located
            b1 = ismember(edges, currentEdge, 'rows');
            indEdge = find(b1);
            if ~isempty(indEdge)
                if edgeFaces(indEdge, 1) ~= 0
                    error('meshes3d:IllegalTopology', ...
                        'Two faces were found on left side of edge %d ', indEdge);
                end
                
                edgeFaces(indEdge, 1) = indFace;
                continue;
            end
                
            % otherwise, assume the face is right-located
            b2 = ismember(edges, currentEdge([2 1]), 'rows');
            indEdge = find(b2);
            if ~isempty(indEdge)
                if edgeFaces(indEdge, 2) ~= 0
                    error('meshes3d:IllegalTopology', ...
                        'Two faces were found on left side of edge %d ', indEdge);
                end
                
                edgeFaces(indEdge, 2) = indFace;
                continue;
            end
            
            % If face was neither left nor right, error
            warning('meshes3d:IllegalTopology', ...
                'Edge %d of face %d was not found in edge array', ...
                j, indFace);
            continue;
        end
    end

end
