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

function varargout = createIcosahedron()
%CREATEICOSAHEDRON Create a 3D mesh representing an Icosahedron.
%
%   MESH = createIcosahedron;
%   [V, E, F] = createIcosahedron;
%   Create a solid with 12 vertices, and 20 triangular faces. Faces are
%   oriented outwards of the mesh.
%
%   [V, F] = createIcosahedron;
%   Returns only the vertices and the face vertex indices.
%
%   MESH = createIcosahedron;
%   Returns the data as a mesh structure, with fields 'vertices', 'edges'
%   and 'faces'.
%
%   Example
%     [n, e, f] = createIcosahedron;
%     drawMesh(n, f);
%   
%   See also
%   meshes3d, drawMesh
%   createCube, createOctahedron, createDodecahedron, createTetrahedron
%

%   ---------
%   author: David Legland 
%   mail: david.legland@inra.fr
%   INRA - TPV URPOI - BIA IMASTE
%   created the 21/03/2005.
%

%   HISTORY
%   2007-01-04 remove unused variables
%   2010-12-06 format output, orient normals outwards


%% Initialisations

theta = 2*pi/5;
l = 1/sin(theta/2)/2;
z1 = sqrt(1-l*l);

t1 = (0:2*pi/5:2*pi*(1-1/5))';
x1 = l*cos(t1);
y1 = l*sin(t1);

t2 = t1 + 2*pi/10;
x2 = l*cos(t2);
y2 = l*sin(t2);

h = sqrt(l*l-.5*.5);
z2 = sqrt(3/4 - (l-h)*(l-h));


%% Create mesh data

nodes = [0 0 0;...
    [x1 y1 repmat(z1, [5 1])]; ...
    [x2 y2 repmat(z1+z2, [5 1])]; ...
    0 0 2*z1+z2];

edges = [...
    1 2;1 3;1 4;1 5;1 6; ...
    2 3;3 4;4 5;5 6;6 2; ...
    2 7;7 3;3 8;8 4;4 9;9 5;5 10;10 6;6 11;11 2; ...
    7 8;8 9;9 10;10 11;11 7; ...
    7 12;8 12;9 12;10 12;11 12];
    
% faces are ordered to have normals pointing outside of the mesh
faces = [...
    1 3  2 ; 1 4  3 ; 1  5  4 ;  1  6  5 ;  1 2  6;...
    2 3  7 ; 3 4  8 ; 4  5  9 ;  5  6 10 ;  6 2 11;...
    7 3  8 ; 8 4  9 ; 9  5 10 ; 10  6 11 ; 11 2  7;...
    7 8 12 ; 8 9 12 ; 9 10 12 ; 10 11 12 ; 11 7 12];

% format output
varargout = formatMeshOutput(nargout, nodes, edges, faces);
