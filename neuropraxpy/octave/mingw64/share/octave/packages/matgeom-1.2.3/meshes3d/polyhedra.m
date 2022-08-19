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

function polyhedra(varargin)
%POLYHEDRA Index of classical polyhedral meshes.
%   
%   Polyhedra are specific meshes, with additional assumptions:
%   * the set of faces is assumed to enclose a single 3D domain
%   * each face has a neighbor face for each edge
%   * some functions also assume that normals of all faces point outwards 
%
%   Most polyhedron creation functions follow the patterns:
%   * [V, F] = createXXX();     % returns vertex and face arrays
%   * [V, E, F] = createXXX();  % returns also edge array
%   * M = createXXX();          % return a data structure with 'vertices',
%                               % 'edges' and 'faces' fields.
%
%   Example
%   % create a soccer ball mesh and display it
%   [n, f] = createSoccerBall;
%   drawMesh(n, f, 'faceColor', 'g', 'linewidth', 2);
%   axis equal;
%
%   See also
%   meshes3d
%   createCube, createCubeOctahedron, createIcosahedron, createOctahedron
%   createRhombododecahedron, createTetrahedron, createTetrakaidecahedron
%   createDodecahedron, createSoccerBall, createMengerSponge
%   steinerPolytope, minConvexHull
%   polyhedronNormalAngle, polyhedronMeanBreadth
%

% ------
% Author: David Legland
% e-mail: david.legland@inra.fr
% Created: 2008-10-13,    using Matlab 7.4.0.287 (R2007a)
% Copyright 2008 INRA - BIA PV Nantes - MIAJ Jouy-en-Josas.

% HISTORY 
