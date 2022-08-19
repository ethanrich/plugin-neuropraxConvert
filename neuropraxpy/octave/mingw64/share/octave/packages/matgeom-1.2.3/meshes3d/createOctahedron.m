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

function varargout = createOctahedron()
%CREATEOCTAHEDRON Create a 3D mesh representing an octahedron.
%
%   [V, E, F] = createOctahedron;
%   Create a 3D mesh representing an octahedron
%   V is a 6-by-3 array with vertices coordinate, E is a 12-by-2 array
%   containing indices of neighbour vertices, and F is a 8-by-3 array
%   containing array of vertex index for each face.
%
%   [V, F] = createOctahedron;
%   Returns only the vertices and the face vertex indices.
%
%   MESH = createOctahedron;
%   Returns the data as a mesh structure, with fields 'vertices', 'edges'
%   and 'faces'.
%
%   Vertices are located on grid vertices:
%    ( ±1,  0,  0 )
%    (  0, ±1,  0 )
%    (  0,  0, ±1 )
%
%   Edge length of returned octahedron is sqrt(2).
%   Surface area of octahedron is 2*sqrt(3)*a^2, approximately 6.9282 in
%   this case.
%   Volume of octahedron is sqrt(2)/3*a^3, approximately 1.3333 in this
%   case.
%
%   Example
%     [v, e, f] = createOctahedron;
%     drawMesh(v, f);
%
%   See also
%   meshes3d, drawMesh
%   createCube, createIcosahedron, createDodecahedron, createTetrahedron
%   createCubeOctahedron
%

%   ---------
%   author : David Legland 
%   e-mail: david.legland@inra.fr
%   INRA - TPV URPOI - BIA IMASTE
%   created the 10/02/2005.
%

%   HISTORY
%   04/01/2007: remove unused variables

nodes = [1 0 0;0 1 0;-1 0 0;0 -1 0;0 0 1;0 0 -1];

edges = [1 2;1 4;1 5; 1 6;2 3;2 5;2 6;3 4;3 5;3 6;4 5;4 6];

faces = [1 2 5;2 3 5;3 4 5;4 1 5;1 6 2;2 6 3;3 6 4;1 4 6];

% format output
varargout = formatMeshOutput(nargout, nodes, edges, faces);
