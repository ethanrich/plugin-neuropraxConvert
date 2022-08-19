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

function breadth = polyhedronMeanBreadth(vertices, edges, faces)
%POLYHEDRONMEANBREADTH Mean breadth of a convex polyhedron.
%
%   BREADTH = polyhedronMeanBreadth(V, E, F)
%   Return the mean breadth (average of polyhedron caliper diameter over
%   all direction) of a convex polyhedron.
%
%   The mean breadth is computed using the sum, over the edges of the
%   polyhedron, of the edge dihedral angles multiplied by the edge length, 
%   the final sum being divided by (4*PI).
%
%   Note: the function assumes that the faces are correctly oriented. The
%   face vertices should be indexed counter-clockwise when considering the
%   supporting plane of the plane, with the outer normal oriented outwards
%   of the polyhedron.
%
%   Typical values for classical polyhedra are:
%     cube side a               breadth = (3/2)*a
%     cuboid sides a, b, c      breadth = (a+b+c)/2
%     tetrahedron side a        breadth = 0.9123*a
%     octaedron side a          beradth = 1.175*a
%     dodecahedron, side a      breadth = 15*arctan(2)*a/(2*pi)
%     icosaehdron, side a       breadth = 15*arcsin(2/3)*a/(2*pi)
%
%   Example
%   [v e f] = createCube;
%   polyhedronMeanBreadth(v, e, f)
%   ans = 
%       1.5
%
%   See also
%   meshes3d, meshEdgeFaces, meshDihedralAngles, checkMeshAdjacentFaces
%   trimeshMeanBreadth
%
%   References
%   Stoyan D., Kendall W.S., Mecke J. (1995) "Stochastic Geometry and its
%       Applications", John Wiley and Sons, p. 26
%   Ohser, J., Muescklich, F. (2000) "Statistical Analysis of
%       Microstructures in Materials Sciences", John Wiley and Sons, p.352

% ------
% Author: David Legland
% e-mail: david.legland@inra.fr
% Created: 2010-10-04,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2010 INRA - Cepia Software Platform.


% compute dihedral angle of each edge
alpha = meshDihedralAngles(vertices, edges, faces);

% compute length of each edge
lengths = meshEdgeLength(vertices, edges);

% compute product of length by angles 
breadth = sum(alpha.*lengths)/(4*pi);
