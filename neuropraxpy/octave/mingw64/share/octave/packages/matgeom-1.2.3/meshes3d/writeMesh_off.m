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

function writeMesh_off(fileName, vertices, faces)
%WRITEMESH_OFF Write a mesh into a text file in OFF format.
%
%   writeMesh_off(FNAME, V, F)
%
%   Example
%   writeMesh_off
%
%   See also
%      meshes3d, writeMesh, readMesh_off, writeMesh_ply
 
% ------
% Author: David Legland
% e-mail: david.legland@inrae.fr
% Created: 2018-04-26,    using Matlab 9.4.0.813654 (R2018a)
% Copyright 2018 INRA - Cepia Software Platform.

if ~ischar(fileName)
    error('First argument must contain the name of the file');
end

% optionnaly parses data
if isstruct(vertices)
    faces = vertices.faces;
    vertices = vertices.vertices;
end

% open file for writing text
f = fopen(fileName, 'wt');
if (f == -1)
	error('Couldn''t open the file %s', fileName);
end

% write the header line
fprintf(f, 'OFF\n');

% write number of vertices and of faces
nVertices = size(vertices, 1);
nFaces = size(faces, 1);
if iscell(faces)
    nFaces = length(faces);
end
fprintf(f, '%d %d 0\n', nVertices, nFaces);

% Write vertex info
format = '%g %g %g\n';
for iv = 1:nVertices
    fprintf(f, format, vertices(iv, :));
end

% Write face info
if isnumeric(faces)
    % simply write face vertex indices
    ns = size(faces, 2);
    format = ['%d' repmat(' %d', 1, ns) '\n'];
    for iFace = 1:nFaces
        fprintf(f, format, ns, faces(iFace, :)-1);
    end
else
    % if faces are stored in a cell array, the number of vertices in each
    % face may be different, and we need to process each face individually
    for iFace = 1:nFaces
        ns = length(faces{iFace});
        format = ['%d' repmat(' %d', 1, ns) '\n'];
        fprintf(f, format, ns, faces{iFace}-1);
    end
end

% close the file
fclose(f);
