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

function varargout = parseMeshData(varargin)
%PARSEMESHDATA Conversion of data representation for meshes.
%
%   MESH = parseMeshData(VERTICES, FACES)
%   MESH = parseMeshData(VERTICES, EDGES, FACES)
%   Returns the mesh info into a single structure with fields "vertices",
%   "edges" and "faces".
%
%   [VERTICES, FACES] = parseMeshData(MESH)
%   Returns the mesh info into two output variables containing coordinates
%   of vertices (as a Nv_by_3 array) and the list of vertex indices for
%   each face (either as a Nf-by-3 or Nf-by-4 int array, or as a cell
%   array).
%
%   [VERTICES, EDGES, FACES] = parseMeshData(MESH)
%   Also returns the vertex indices of each edge, as a Ne-by-2 array of
%   vertex indices.
%
%   See also
%   meshes3d, formatMeshOutput
%

% ------
% Author: David Legland
% e-mail: david.legland@inra.fr
% Created: 2010-12-06,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2010 INRA - Cepia Software Platform.

% initialize edges to empty variable
edges = [];

% Process input arguments
switch nargin
    case 1
        % input is a data structure
        mesh = varargin{1};
        vertices = mesh.vertices;
        faces = mesh.faces;
        if isfield(mesh, 'edges')
            edges = mesh.edges;
        end
        
    case 2
        % input are vertices and faces
        vertices = varargin{1};
        faces = varargin{2};
   
    case  3
        % input are vertices, edges and faces
        vertices = varargin{1};
        edges = varargin{2};
        faces = varargin{3};
        
    otherwise
        error('Wrong number of arguments');
end

% returns either a struct or several variables
varargout = formatMeshOutput(nargout, vertices, edges, faces);
