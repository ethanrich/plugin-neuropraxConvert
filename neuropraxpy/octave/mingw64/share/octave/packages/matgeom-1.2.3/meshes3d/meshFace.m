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

function face = meshFace(faces, index)
%MESHFACE Return the vertex indices of a face in a mesh.
%
%   FACE = meshFace(FACES, INDEX)
%   Return the vertex indices of the i-th face in the face array. This is
%   mainly an utility function that manages faces stored either as int
%   array (when all faces have same number of sides) or cell array (when
%   faces may have different number of edges).
%
%   Example
%     [v, f] = createCubeOctahedron;
%     % some faces are squares
%     meshFace(f, 1)
%     ans =
%          1     2     3     4
%     % other are triangles
%     meshFace(f, 2)
%     ans =
%          1     5     2
%
%   See also
%     meshes3d, meshFaceCentroid, meshFaceNormals, meshFaceAreas

% ------
% Author: David Legland
% e-mail: david.legland@inra.fr
% Created: 2010-10-06,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2010 INRA - Cepia Software Platform.


% process mesh given as structure
if isstruct(faces)
    if isfield(faces, 'faces')
        faces = faces.faces;
    else
        error('Mesh structure should contains a field ''faces''');
    end
end

% switch between numeric or cell array
if isnumeric(faces)
    face = faces(index, :);
else
    face = faces{index};
end

