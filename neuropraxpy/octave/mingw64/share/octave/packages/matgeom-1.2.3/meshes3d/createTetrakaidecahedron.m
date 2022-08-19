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

function varargout = createTetrakaidecahedron()
%CREATETETRAKAIDECAHEDRON Create a 3D mesh representing a tetrakaidecahedron.
%
%   [V, E, F] = createTetrakaidecahedron;
%   Create a mesh structure representing a tetrakaidecahedron, composed of
%   both square and hexagonal faces. Tetrakaidecahedron can be used to tile
%   the 3D Euclidean space.
%
%   V is a 24-by-3 array with vertex coordinates,
%   E is a 36-by-2 array containing indices of neighbour vertices,
%   F is a 14-by-1 cell array containing vertex indices array of each face.
%
%   [V, F] = createTetrakaidecahedron;
%   Returns only the vertices and the face vertex indices.
%
%   MESH = createTetrakaidecahedron;
%   Returns the data as a mesh structure, with fields 'vertices', 'edges'
%   and 'faces'.
%
%   Example
%   [n, e, f] = createTetrakaidecahedron;
%   drawMesh(n, f);
%   
%   See also
%   meshes3d, drawMesh

%   ---------
%   author : David Legland 
%   e-mail: david.legland@inra.fr
%   INRA - TPV URPOI - BIA IMASTE
%   created the 10/02/2005.
%

%   HISTORY
%   04/01/2007: remove unused variables

nodes = [...
    1 0 2;0 1 2;-1 0 2;0 -1 2;...
    2 0 1;0 2 1;-2 0 1;0 -2 1;...
    2 1 0;1 2 0;-1 2 0;-2 1 0;-2 -1 0;-1 -2 0;1 -2 0;2 -1 0;...
    2 0 -1;0 2 -1;-2 0 -1;0 -2 -1;...
    1 0 -2;0 1 -2;-1 0 -2;0 -1 -2];

edges = [...
    1 2;1 4;1 5;2 3;2 6;3 4;3 7;4 8;...
    5 9;5 16;6 10;6 11;7 12;7 13;8 14;8 15;...
    9 10;9 17;10 18;11 12;11 18;12 19;13 14;13 19;14 20;15 16;15 20;16 17;....
    17 21;18 22;19 23;20 24;21 22;21 24;22 23;23 24];
    
    
faces = {...
    [1 2 3 4], ...
    [1 4 8 15 16 5], [1 5 9 10 6 2], [2 6 11 12 7 3], [3 7 13 14 8 4],...
    [5 16 17 9], [6 10 18 11], [7 12 19 13], [8 14 20 15],...
    [9 17 21 22 18 10], [11 18 22 23 19 12], [13 19 23 24 20 14], [15 20 24 21 17 16], ...
    [21 24 23 22]};
faces = faces';
    
% format output
varargout = formatMeshOutput(nargout, nodes, edges, faces);

