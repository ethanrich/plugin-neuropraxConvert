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

function writeMesh_ply(fileName, vertices, faces, varargin)
%WRITEMESH_PLY Write a mesh into a file in PLY format.
%
%   writeMesh_ply(FNAME, VERTICES, FACES)
%
%   writeMesh_ply(FNAME, MESH)
%
%   writeMesh_ply(..., FORMAT) also specifies a file format for the written
%   file. FORMAT can be either 'binary' (default) or 'ascii'.
%
%   Example
%   mesh = createSoccerBall;
%   fileName = 'SoccerBall.ply';
%   writeMesh_ply(fileName, mesh, 'Bin');
%   mesh2 = readMesh(fileName);
%   drawMesh(mesh2); axis equal
%
%   See also
%   meshes3d, writeMesh, readMesh_ply, writeMesh_off, writeMesh_stl

% ------
% Author: David Legland, oqilipo
% e-mail: david.legland@inrae.fr
% Created: 2018-04-26,    using Matlab 9.4.0.813654 (R2018a)
% Copyright 2018 INRA - Cepia Software Platform.


%% Check inputs

% optionnaly parses data
if isstruct(vertices)
    if nargin > 2
        varargin = [{faces} varargin{:}];
    end
    faces = vertices.faces;
    vertices = vertices.vertices;
end

% Parsing
p = inputParser;
addRequired(p,'fileName',@(x) validateattributes(x,{'char'},{'nonempty'}));
suppModes = {'ascii','binary_little_endian'};
addOptional(p,'mode','binary_little_endian',@(x) any(validatestring(x,suppModes)));
parse(p,fileName,varargin{:});
fileName = p.Results.fileName;
mode = suppModes{startsWith(suppModes, p.Results.mode, 'IgnoreCase',1)};

%% Initializations

% number of vertices and faces
nVertices = size(vertices, 1);
nFaces = size(faces, 1);
if iscell(faces)
    nFaces = length(faces);
end

% open file for writing text
f = fopen(fileName, 'wt');
if (f == -1)
    error('Couldn''t open the file %s', fileName);
end


%% Write Header

% write the header line
fprintf(f, 'ply\n');

% write format (only ASCII supported)
fprintf(f, 'format %s 1.0\n', mode);

% some comments
fprintf(f, 'comment Created by MatGeom for MATLAB\n');

% write declaration for vertices
fprintf(f, 'element vertex %d\n', nVertices);
fprintf(f, 'property double x\n');
fprintf(f, 'property double y\n');
fprintf(f, 'property double z\n');

% write declaration for faces
fprintf(f, 'element face %d\n', nFaces);
fprintf(f, 'property list int int vertex_index\n');

% end of header
fprintf(f, 'end_header\n');

%% Write data

switch mode
    case 'ascii'
        % write vertex info
        format = '%0.17f %0.17f %0.17f\n';
        fprintf(f, format, vertices');
        
        % write face info
        if isnumeric(faces)
            % simply write face vertex indices
            ns = size(faces, 2);
            plyFaces = [ns * ones(nFaces, 1) faces-1];
            format = ['%d' repmat(' %d', 1, ns) '\n'];
            fprintf(f, format, plyFaces');
        else
            % if faces are stored in a cell array, the number of vertices in each
            % face may be different, and we need to process each face individually
            for iFace = 1:nFaces
                ns = length(faces{iFace});
                format = ['%d' repmat(' %d', 1, ns) '\n'];
                fprintf(f, format, ns, faces{iFace} - 1);
            end
        end
    case 'binary_little_endian'
        % close the file
        fclose(f);
        % open file with little-endian format
        f = fopen(fileName,'a','ieee-le');
        % write vertex info
        fwrite(f, vertices', 'double');
        
        % write face info
        if isnumeric(faces)
            % simply write face vertex indices
            plyFaces = [size(faces, 2) * ones(nFaces, 1) faces-1];
            fwrite(f, plyFaces', 'int');
        else
            % if faces are stored in a cell array, the number of vertices in each
            % face may be different, and we need to process each face individually
            for iFace = 1:nFaces
                fwrite(f, [length(faces{iFace}), faces{iFace}-1], 'int');
            end
        end
    otherwise
        error(['Format ''' mode ''' is not supported'])
end

% close the file
fclose(f);

end
