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

function varargout = createDodecahedron()
%CREATEDODECAHEDRON Create a 3D mesh representing a dodecahedron.
%
%   [V, E, F] = createDodecahedron;
%   Create a 3D mesh representing a dodecahedron
%   V is the 20-by-3 array of vertex coordinates
%   E is the 30-by-2 array of edge vertex indices
%   F is the 12-by-5 array of face vertex indices
%
%   [V, F] = createDodecahedron;
%   Returns only the vertices and the face vertex indices.
%
%   MESH = createDodecahedron;
%   Returns the data as a mesh structure, with fields 'vertices', 'edges'
%   and 'faces'.
%
%   Example
%   [v, e, f] = createDodecahedron;
%   drawMesh(v, f);
%
%   Use values given by P. Bourke, see:
%   http://local.wasp.uwa.edu.au/~pbourke/geometry/platonic/
%   faces are re-oriented to have normals pointing outwards.
%
%   See also
%   meshes3d, drawMesh
%   createCube, createOctahedron, createIcosahedron, createTetrahedron
%

%   ---------
%   author : David Legland 
%   e-mail: david.legland@inra.fr
%   INRA - TPV URPOI - BIA IMASTE
%   created the 29/07/2010.
%

%   HISTORY

% golden ratio
phi = (1+sqrt(5))/2;

% coordinates pre-computations
b = 1 / phi ; 
c = 2 - phi ;

% use values given by P. Bourke, see:
% http://local.wasp.uwa.edu.au/~pbourke/geometry/platonic/
tmp = [ ...
 c  0  1 ;   b  b  b ;   0  1  c  ; -b  b  b  ; -c  0  1 ;  ...
-c  0  1 ;  -b -b  b ;   0 -1  c  ;  b -b  b  ;  c  0  1 ;   ...
 c  0 -1 ;   b -b -b ;   0 -1 -c  ; -b -b -b  ; -c  0 -1 ;  ...
-c  0 -1 ;  -b  b -b ;   0  1 -c  ;  b  b -b  ;  c  0 -1 ; ...
 0  1 -c ;   0  1  c ;   b  b  b  ;  1  c  0  ;  b  b -b ; ...
 0  1  c ;   0  1 -c ;  -b  b -b  ; -1  c  0  ; -b  b  b ; ...
 0 -1 -c ;   0 -1  c ;  -b -b  b  ; -1 -c  0  ; -b -b -b ; ...
 0 -1  c ;   0 -1 -c ;   b -b -b  ;  1 -c  0  ;  b -b  b ; ...
 1  c  0 ;   b  b  b ;   c  0  1  ;  b -b  b  ;  1 -c  0 ;  ...
 1 -c  0 ;   b -b -b ;   c  0 -1  ;  b  b -b  ;  1  c  0 ; ...
-1  c  0 ;  -b  b -b ;  -c  0 -1  ; -b -b -b  ; -1 -c  0 ; ...
-1 -c  0 ;  -b -b  b ;  -c  0  1  ; -b  b  b  ; -1  c  0 ;  ...
];

% extract coordinates of unique vertices
[verts, M, N] = unique(tmp, 'rows', 'first'); %#ok<ASGLU>

% compute indices of face vertices, put result in a 12-by-5 index array
ind0 = reshape((1:60), [5 12])';
faces = N(ind0);

% extract edges from faces
edges = [reshape(faces(:, 1:5), [60 1]) reshape(faces(:, [2:5 1]), [60 1])];
edges = unique(sort(edges, 2), 'rows');


% format output
varargout = formatMeshOutput(nargout, verts, edges, faces);
