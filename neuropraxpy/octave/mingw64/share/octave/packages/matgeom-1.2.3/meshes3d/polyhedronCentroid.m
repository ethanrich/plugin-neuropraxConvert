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

function centroid = polyhedronCentroid(vertices, faces) %#ok<INUSD>
%POLYHEDRONCENTROID Compute the centroid of a 3D convex polyhedron.
%
%   CENTRO = polyhedronCentroid(V, F)
%   Computes the centroid (center of mass) of the polyhedron defined by
%   vertices V and faces F.
%   The polyhedron is assumed to be convex.
%
%   Example
%     % Creates a polyhedron centered on origin, and add an arbitrary
%     % translation
%     [v, f] = createDodecahedron;
%     v2 = bsxfun(@plus, v, [3 4 5]);
%     % computes the centroid, that should equal the translation vector
%     centroid = polyhedronCentroid(v2, f)
%     centroid =
%         3.0000    4.0000    5.0000
%
%
%   See also
%   meshes3d, meshVolume, meshSurfaceArea, polyhedronMeanBreadth
%

% ------
% Author: David Legland
% e-mail: david.legland@nantes.inra.fr
% Created: 2012-04-05,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2012 INRA - Cepia Software Platform.

% 2015.11.13 use delaunayTriangulation instead of delaunayn (strange bug
%       with icosahedron...)

% compute set of elementary tetrahedra
DT = delaunayTriangulation(vertices);
T = DT.ConnectivityList;

% number of tetrahedra
nT  = size(T, 1);

% initialize result
centroid = zeros(1, 3);
vt = 0;

% Compute the centroid and the volume of each tetrahedron
for i = 1:nT
    % coordinates of tetrahedron vertices
    tetra = vertices(T(i, :), :);
    
    % centroid is the average of vertices. 
    centi = mean(tetra);
    
    % compute volume of tetrahedron
    vol = det(tetra(1:3,:) - tetra([4 4 4],:)) / 6;
    
    % add weighted centroid of current tetraedron
    centroid = centroid + centi * vol;
    
    % compute the sum of tetraedra volumes
    vt = vt + vol;
end

% compute by sum of tetrahedron volumes
centroid = centroid / vt;
