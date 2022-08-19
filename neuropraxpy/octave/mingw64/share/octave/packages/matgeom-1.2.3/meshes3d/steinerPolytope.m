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

function [vertices, faces] = steinerPolytope(vectors)
%STEINERPOLYTOPE Create a steiner polytope from a set of vectors.
%
%   [VERTICES FACES] = steinerPolygon(VECTORS)
%   Creates the Steiner polytope defined by the set of vectors VECTORS.
%
%   Example
%     % Creates and display a planar Steiner polytope (ie, a polygon)
%     [v f] = steinerPolytope([1 0;0 1;1 1]);
%     fillPolygon(v);
%
%     % Creates and display a 3D Steiner polytope 
%     [v f] = steinerPolytope([1 0 0;0 1 0;0 0 1;1 1 1]);
%     drawMesh(v, f);
%     view(3); axis vis3d
%
%   See also
%   meshes3d, drawMesh, steinerPolygon, mergeCoplanarFaces
%

% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2006-04-28
% Copyright 2006 INRA - CEPIA Nantes - MIAJ (Jouy-en-Josas).

% History
% 2013-02-22 merge coplanar faces, add management of 2D case, update doc


% compute vectors dimension
nd = size(vectors, 2);

% create candidate vertices
vertices = zeros(1, size(vectors, 2));
for i = 1:length(vectors)
    nv = size(vertices, 1);
    vertices = [vertices; vertices+repmat(vectors(i,:), [nv 1])]; %#ok<AGROW>
end

if nd == 2
    % for planar case, use specific function convhull
    K = convhull(vertices(:,1), vertices(:,2));
    vertices = vertices(K, :);
    faces = 1:length(K);
    
else 
    % Process the general case (tested only for nd==3)
    
    % compute convex hull
    K = convhulln(vertices);
    
    % keep only relevant points, and update faces indices
    ind = unique(K);
    for i = 1:length(ind)
        K(K==ind(i)) = i;
    end
    
    % return results
    vertices = vertices(ind, :);
    faces = K;
    
    % in case of 3D meshes, merge coplanar faces
    if nd == 3
        faces = mergeCoplanarFaces(vertices, faces);
    end
end
