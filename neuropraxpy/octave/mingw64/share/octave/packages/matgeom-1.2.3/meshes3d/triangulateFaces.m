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

function [tri, inds] = triangulateFaces(faces)
%TRIANGULATEFACES Convert face array to an array of triangular faces.
%
%   TRI = triangulateFaces(FACES)
%   Returns a 3-columns array of indices, based on the data stored in the
%   argument FACES:
%   - if FACES is a N-by-3 array, returns the same array
%   - if FACES is a N-by-4 array, returns an array with 2*N rows and 3
%       columns, splitting each square into 2 triangles (uses first and
%       third vertex of each square as diagonal).
%   - if FACES is a cell array, split each face into a set of triangles,
%       and returns the union of all triangles. Faces are assumed to be
%       convex.
%
%   [TRI INDS] = triangulateFaces(FACES)
%   Also returns original face index of each new triangular face. INDS has
%   the same number of rows as TRI, and has values between 1 and the
%   number of rows of the original FACES array.
%
%
%   Example
%     % create a basic shape
%     [n e f] = createCubeOctahedron;
%     % draw with plain faces
%     figure;
%     drawMesh(n, f);
%     % draw as a triangulation
%     tri = triangulateFaces(f);
%     figure;
%     patch('vertices', n, 'faces', tri, 'facecolor', 'r');
%
%   See also
%     meshes3d, drawMesh, mergeCoplanarFaces
%

% ------
% Author: David Legland
% e-mail: david.legland@inra.fr
% Created: 2008-09-08,    using Matlab 7.4.0.287 (R2007a)
% Copyright 2008 INRA - BIA PV Nantes - MIAJ Jouy-en-Josas.

%% Tri mesh case: return original set of faces

if isnumeric(faces) && size(faces, 2) == 3
    tri = faces;
    if nargout > 1
        inds = (1:size(faces, 1))';
    end
    return;
end


%% Square faces: split each square into 2 triangles

if isnumeric(faces) && size(faces, 2) == 4
    nf = size(faces, 1);
    tri = zeros(nf * 2, 3);
    tri(1:2:end, :) = faces(:, [1 2 3]);
    tri(2:2:end, :) = faces(:, [1 3 4]);
    
    if nargout > 1
        inds = kron(1:size(faces, 1), ones(1,2))';
    end
    
    return;
end


%% Pentagonal faces (for dodecahedron...): split into 3 triangles

if isnumeric(faces) && size(faces, 2) == 5
    nf = size(faces, 1);
    tri = zeros(nf * 3, 3);
    tri(1:3:end, :) = faces(:, [1 2 3]);
    tri(2:3:end, :) = faces(:, [1 3 4]);
    tri(3:3:end, :) = faces(:, [1 4 5]);
    
    if nargout > 1
        inds = kron(1:size(faces, 1), ones(1,2))';
    end
    
    return;
end


%% Faces as cell array 

% number of faces
nf  = length(faces);

% compute total number of triangles
ni = zeros(nf, 1);
for i = 1:nf
    % as many triangles as the number of vertices minus 1
    ni(i) = length(faces{i}) - 2;
end
nt = sum(ni);

% allocate memory for triangle array
tri = zeros(nt, 3);
inds = zeros(nt, 1);

% convert faces to triangles
t = 1;
for i = 1:nf
    face = faces{i};
    nv = length(face);
    v0 = face(1);
    for j = 3:nv
        tri(t, :) = [v0 face(j-1) face(j)];
        inds(t) = i;
        t = t + 1;
    end
end

