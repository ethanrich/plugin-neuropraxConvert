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

function writeMesh(fileName, vertices, faces, varargin)
% Write 3D mesh data by inferring format from file name.
%
%   writeMesh(FNAME, V, F)
%
%   writeMesh(FNAME, MESH)
%
%   Example
%   writeMesh
%
%   See also
%     meshes3d, readMesh, writeMesh_off, writeMesh_ply, writeMesh_stl
%

% ------
% Author: David Legland
% e-mail: david.legland@inrae.fr
% INRAE - BIA Research Unit - BIBS Platform (Nantes)
% Created: 2020-11-20,    using Matlab 9.8.0.1323502 (R2020a)
% Copyright 2020 INRAE.

% check inputs
if ~ischar(fileName)
    error('First argument must contain the name of the file');
end

% optionnaly parses data
if isstruct(vertices)
    if nargin > 2
        varargin = [{faces} varargin{:}];
    end
    faces = vertices.faces;
    vertices = vertices.vertices;
end

[~, ~, ext] = fileparts(fileName);
switch lower(ext)
    case '.off'
        writeMesh_off(fileName, vertices, faces);
    case '.ply'
        writeMesh_ply(fileName, vertices, faces, varargin{:});
    case '.stl'
        writeMesh_stl(fileName, vertices, faces, varargin{:});
    otherwise
        error('Unrecognized file format for rezading mesh: %s', ext);
end
