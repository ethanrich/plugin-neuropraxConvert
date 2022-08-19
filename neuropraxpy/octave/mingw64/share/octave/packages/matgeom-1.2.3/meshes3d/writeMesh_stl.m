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

function writeMesh_stl(fileName, vertices, faces, varargin)
%WRITEMESH_STL Write mesh data in the STL format.
%
%   writeMesh_stl(FNAME, VERTICES, FACES)
%
%   writeMesh_stl(FNAME, MESH)
%
%   writeMesh_stl(FNAME, VERTICES, FACES, ...) see stlwrite for additonal
%   options
%
%   Example
%   mesh = cylinderMesh([60 50 40 10 20 30 5], 1);
%   writeMesh_stl('Cylinder.stl', mesh, 'bin');
%
%   References
%   Wrapper function for MATLAB's build-in stlwrite.
%
%   See also
%   meshes3d, writeMesh, writeMesh_off, writeMesh_ply

% ------
% Author: oqilipo
% Created: 2021-02-13, using Matlab 9.9.0.1538559 (R2020b)
% Copyright 2021

%% Check inputs
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

%% Write STL
TR = triangulation(faces, vertices);
stlwrite(TR,fileName, varargin{:})

end
