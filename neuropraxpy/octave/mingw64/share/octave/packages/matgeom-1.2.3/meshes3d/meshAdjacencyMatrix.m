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

function adj = meshAdjacencyMatrix(faces, varargin)
%MESHADJACENCYMATRIX Compute adjacency matrix of a mesh from set of faces.
%
%   ADJMAT = meshAdjacencyMatrix(FACES)
%   Returns a sparse NV-by-NV matrix (NV being the largest vertex index)
%   containing vertex adjacency of the mesh represented by FACES.
%   FACES is either a NF-by-3, a NF-by-4 index array, or a Nf-by-1 cell
%   array.
%
%   Example
%     [v f] = createCube;
%     adj = meshAdjacencyMatrix(f);
%
%   See also
%     meshes3d, triangulateFaces, smoothMesh

% ------
% Author: David Legland
% e-mail: david.legland@inra.fr
% Created: 2013-04-30,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2013 INRA - Cepia Software Platform.

% Ensures faces is a N-by-3 or N-by-4 array
if iscell(faces) || (isnumeric(faces) && size(faces, 2) > 4)
    faces = triangulateFaces(faces);
end

% forces faces to be floating point array, for sparse function
if ~isfloat(faces)
    faces = double(faces);
end
nv = max(faces(:));
    
% populate a sparse matrix
if size(faces, 2) == 3
    adj = sparse(...
        [faces(:,1); faces(:,1); faces(:,2); faces(:,2); faces(:,3); faces(:,3)], ...
        [faces(:,3); faces(:,2); faces(:,1); faces(:,3); faces(:,2); faces(:,1)], ...
        1.0, nv, nv);
elseif size(faces, 2) == 4
    adj = sparse(...
        [faces(:,1); faces(:,1); faces(:,2); faces(:,2); faces(:,3); faces(:,3); faces(:,4); faces(:,4)], ...
        [faces(:,4); faces(:,2); faces(:,1); faces(:,3); faces(:,2); faces(:,4); faces(:,3); faces(:,1)], ...
        1.0, nv, nv);
end
   
% remove double adjacencies
adj = min(adj, 1);
