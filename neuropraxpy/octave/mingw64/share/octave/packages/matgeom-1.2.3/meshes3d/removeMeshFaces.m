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

function varargout = removeMeshFaces(v, f, fI)
%REMOVEMESHFACES Remove faces from a mesh by face indices.
%   [V2, F2] = removeMeshFaces(V, F, FI) removes faces from the mesh by
%   the face indices FI into faces F of the mesh. The mesh is represented 
%   by the vertex array V and the face array F. The result is the new set 
%   of vertices V2 and faces F2 without the faces indexed by FI. FI can be
%   either a linear or a logical index.
%
%   [V2, F2] = removeMeshFaces(MESH, FI) with the struct MESH containing 
%   the fields "vertices" (V) and "faces" (F)
%   
%   MESH2 = removeMeshFaces(V, F, FI) with the struct MESH2 containing the
%   fields "vertices" (V2) and "faces" (F2)
%   
%   MESH2 = removeMeshFaces(MESH, FI) with the structs MESH and MESH2 
%   containing the fields "vertices" (V, V2) and "faces" (F, F2)
%   
%   Example
%     [v, f] = createSoccerBall;
%     f = triangulateFaces(f);
%     fI = true(length(f),1);
%     fI(1:length(f)/2) = false;
%     [v2, f2] = removeMeshFaces(v, f, fI);
%     drawMesh(v, f, 'faceColor', 'none', 'faceAlpha', .2);
%     drawMesh(v2, f2, 'faceAlpha', .7);
%     view(3); axis equal
%   
%   See also
%   meshes3d, drawMesh
%   
% ---------
% Authors: oqilipo, David Legland
% Created: 2017-07-04

% parse inputs
narginchk(2,3)
nargoutchk(1,2)

if nargin == 2
    fI = f;
    [v, f] = parseMeshData(v);
end

p = inputParser;
isIndexToFaces = @(x) ...
    (islogical(x) && isequal(length(x), size(f,1))) || ...
    (all(floor(x)==x) && min(x)>=1 && max(x)<=size(f,1));
addRequired(p,'fI',isIndexToFaces)
parse(p, fI);
if ~islogical(p.Results.fI)
    fI=false(size(f,1),1);
    fI(p.Results.fI)=true;
else
    fI=p.Results.fI;
end
    

% algorithm
f2 = f(~fI,:);
[unqVertIds, ~, newVertIndices] = unique(f2);
v2 = v(unqVertIds,:);
f2 = reshape(newVertIndices,size(f2));


% parse outputs
if nargout == 1
    mesh2.vertices=v2;
    mesh2.faces=f2;
    varargout{1}=mesh2;
else
    varargout{1}=v2;
    varargout{2}=f2;
end

end
