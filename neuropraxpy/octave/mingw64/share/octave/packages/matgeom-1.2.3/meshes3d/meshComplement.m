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

function varargout = meshComplement(varargin)
% Reverse the normal of each face in the mesh.
%
%   [V2, F2] = meshComplement(V, F)
%
%   Example
%     [v, f] = createOctahedron;
%     meshVolume(v, f)
%     ans =
%         1.3333
%     [v2, f2] = meshComplement(v, f);
%     meshVolume(v2, f2)
%     ans =
%        -1.3333
%
%   See also
%     meshes3d, meshVolume
 
% ------
% Author: David Legland
% e-mail: david.legland@inrae.fr
% INRAE - BIA Research Unit - BIBS Platform (Nantes)
% Created: 2020-01-22,    using Matlab 9.7.0.1247435 (R2019b) Update 2
% Copyright 2020 INRAE.

% extract mesh data
mesh = parseMeshData(varargin{:});
faces = mesh.faces;

% iterate over faces to invert order of vertex indices
if isnumeric(faces)
    for i = 1:size(faces, 1)
        faces(i,:) = faces(i, end:-1:1);
    end
else
    for i = 1:size(faces, 1)
        faces{i} = faces{i}(end:-1:1);
    end
end

% create new mesh data
varargout = formatMeshOutput(nargout, mesh.vertices, faces);
