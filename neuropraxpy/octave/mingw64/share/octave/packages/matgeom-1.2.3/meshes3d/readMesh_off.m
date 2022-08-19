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

function varargout = readMesh_off(fileName)
% Read mesh data stored in OFF format.
%
%   [VERTICES, FACES] = readMesh_off(FILENAME)
%   Read the data stored in file FILENAME and return the vertex and face
%   arrays as NV-by-3 array and NF-by-N array respectively, where NV is the
%   number of vertices and NF is the number of faces.
%
%   MESH = readMesh_off(FILENAME)
%   Read the data stored in file FILENAME and return the mesh into a struct
%   with fields 'vertices' and 'faces'.
%
%   Example
%     [v, f] = readMesh_off('mushroom.off');
%     figure; drawMesh(v, f, 'faceColor', [0 1 0], 'edgeColor', 'none')
%     view([5 80]); light; lighting gouraud
%
%   See also
%     meshes3d, readMesh, writeMesh_off, drawMesh
%

% ------
% Author: David Legland
% e-mail: david.legland@inra.fr
% Created: 2011-12-20,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2011 INRA - Cepia Software Platform.


%% Read header 

% open file
f = fopen(fileName, 'r');
if f == -1 
    error('matGeom:readMesh_off:FileNotFound', ...
        ['Could not find file: ' fileName]);
end

% check format
line = fgetl(f);   % -1 if eof
if ~strcmp(line(1:3), 'OFF')
    error('matGeom:readMesh_off:FileFormatError', ...
        'Not a valid OFF file');    
end

% number of faces and vertices
line = fgetl(f);
vals = sscanf(line, '%d %d');
nVertices = vals(1);
nFaces = vals(2);


%% Read vertex data
[vertices, count] = fscanf(f, '%f ', [3 nVertices]);
if count ~= nVertices * 3
    error('matGeom:readMesh_off:FileFormatError', ...
        ['Could not read all the ' num2str(nVertices) ' vertices']);
end
vertices = vertices';


%% Read Face data
% First try to read faces as an homogeneous array. It if fails, start from
% face offset and parse each face individually. In the latter case, faces
% can have different number of vertices.

% keep position of face info within file
faceOffset = ftell(f);

% read first face to assess number of vertices per face
line = fgetl(f);
if line == -1
    error('matGeom:readMesh_off:FileFormatError', ...
        'Unexpected end of file');
end
tokens = split(line);
face1 = str2double(tokens(2:end))' + 1;
nv = length(face1);

try 
    % attenpt to read the remaining faces assuming they all have the same
    % number of vertices
    pattern = ['%d' repmat(' %d', 1, nv) '\n'];
    [faces, count] = fscanf(f, pattern, [(nv+1) (nFaces-1)]);
    if count ~= (nFaces-1) * (nv+1)
        error('matGeom:readMesh_off:FileFormatError', ...
            'Could not read all the %d faces', nFaces);
    end

    % transpose, remove first column, use 1-indexing, and concatenate with
    % first face
    faces = [face1 ; faces(2:end,:)'+1];

catch
    % if attempt failed, switch to slower face-by-face parsing
    disp('readMesh_off: Inhomogeneous number of vertices per face, switching to face-per-face parsing');
    
    fseek(f, faceOffset, 'bof');
    
    % allocate cell array
    faces = cell(1, nFaces);
    
    % iterate over faces
    for iFace = 1:nFaces
        % read next line
        line = fgetl(f);
        if line == -1
            error('matGeom:readMesh_off:FileFormatError', ...
                'Unexpected end of file');
        end

        % parse vertex indices for current face
        tokens = split(line);
        faces{iFace} = str2double(tokens(2:end))' + 1;
    end
end


%% Post-processing

% close the file
fclose(f);

% format output arguments
if nargout < 2
    mesh.vertices = vertices;
    mesh.faces = faces;
    varargout = {mesh};
else
    varargout = {vertices, faces};
end
