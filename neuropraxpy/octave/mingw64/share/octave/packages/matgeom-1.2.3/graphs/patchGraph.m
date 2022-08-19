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

function varargout = patchGraph(nodes, edges, faces) %#ok<INUSL>
%PATCHGRAPH Transform 3D graph (mesh) into a patch handle.
%
%   [PX, PY, PZ] = PATCHGRAPH(NODES, EDGES, FACES)
%   Transform the graph defined as a set of nodes, edges and faces in a
%   patch which can be drawn usind matlab function 'patch'.
%   The result is a set of 3 array of size [NV*NF], with NV being the
%   number of vertices per face, and NF being the total number of faces.
%   each array contains one coordinate of vertices of each patch.
%
%
%   ---------
%
%   author : David Legland 
%   INRA - TPV URPOI - BIA IMASTE
%   created the 28/06/2004.
%

if iscell(faces)
    p = zeros(length(faces), 1);
    for i = 1:length(faces)
        p(i) = patch( ...
            'Faces', faces{i}, ...
            'Vertices', nodes, ...
            'FaceColor', 'r', ...
            'EdgeColor', 'none') ;
    end    
else    
    p = patch( ...
        'Faces', faces, ...
        'Vertices', nodes, ...
        'FaceColor', 'r', ...
        'EdgeColor', 'none') ;
end

if nargout>0
    varargout{1}=p;
end
