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

function varargout = createRhombododecahedron()
%CREATERHOMBODODECAHEDRON Create a 3D mesh representing a rhombododecahedron.
%
%   [V, E, F] = createRhombododecahedron
%   V is a 14-by-3 array with vertex coordinate, 
%   E is a 12-by-2 array containing indices of neighbour vertices,
%   F is a 8-by-3 array containing vertices array of each face.
%
%   [V, F] = createRhombododecahedron;
%   Returns only the vertices and the face vertex indices.
%
%   MESH = createRhombododecahedron;
%   Returns the data as a mesh structure, with fields 'vertices', 'edges'
%   and 'faces'.
%
%   Example
%   [v, e, f] = createRhombododecahedron;
%   drawMesh(v, f);
%
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

nodes = [0 0 2;...
    1 -1 1;1 1 1;-1 1 1;-1 -1 1;...
    2 0 0;0 2 0;-2 0 0;0 -2 0;...
    1 -1 -1;1 1 -1;-1 1 -1;-1 -1 -1;...
    0 0 -2];

edges = [...
    1 2;1 3;1 4;1 5;...
    2 6;2 9;3 6;3 7;4 7;4 8;5 8;5 9;...
    6 10;6 11;7 11;7 12;8 12;8 13;9 10;9 13; ...
    10 14;11 14;12 14;13 14];

faces = [...
    1 2 6 3;...
    1 3 7 4;...
    1 4 8 5;...
    1 5 9 2;...
    2 9 10 6;...
    3 6 11 7;...
    4 7 12 8;...
    5 8 13 9;...
    6 10 14 11;...
    7 11 14 12;...
    8 12 14 13;...
    9 13 14 10];
    
% format output
varargout = formatMeshOutput(nargout, nodes, edges, faces);

