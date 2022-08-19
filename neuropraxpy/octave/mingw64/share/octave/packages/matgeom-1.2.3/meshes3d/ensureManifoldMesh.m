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

function varargout = ensureManifoldMesh(varargin)
%ENSUREMANIFOLDMESH Apply several simplification to obtain a manifold mesh.
%
%   Try to transform an input mesh into a manifold mesh.
%
%   Not all cases of "non-manifoldity" are checked, so please use with
%   care.
%
%   [V2, F2] = ensureManifoldMesh(V, F);
%   [V2, F2] = ensureManifoldMesh(MESH);
%   MESH2 = ensureManifoldMesh(...);
%
%   Example
%   ensureManifoldMesh
%
%   See also
%    meshes3d, isManifoldMesh
 
% ------
% Author: David Legland
% e-mail: david.legland@inra.fr
% Created: 2019-02-01,    using Matlab 9.5.0.944444 (R2018b)
% Copyright 2019 INRA - Cepia Software Platform.


%% Parse input arguments

[vertices, faces] = parseMeshData(varargin{:});
verbose = true;


%% Pre-processing

% remove duplicate faces if any
if verbose
    disp('remove duplicate faces');
end
faces = removeDuplicateFaces(faces);


%% Iterative processing of multiple edges
% Reduces all edges connected to more than two faces, by collapsing second
% vertex onto the first one.

% iter = 0;
% while ~isManifoldMesh(vertices, faces) && iter < 10
%     iter = iter + 1;
    if verbose
        disp('collapse edges with many faces');
    end
    
    [vertices, faces] = collapseEdgesWithManyFaces(vertices, faces);
% end



%% Format output

varargout = formatMeshOutput(nargout, vertices, faces);

