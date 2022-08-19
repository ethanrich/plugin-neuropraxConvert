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

function varargout = drawPolyhedron(nodes, faces, varargin)
%DRAWPOLYHEDRON Draw polyhedron defined by vertices and faces.
%
%   drawPolyhedron(NODES, FACES)
%   Draws the polyhedron defined by vertices NODES and the faces FACES. 
%   NODES is a NV-by-3 array containing coordinates of vertices, and FACES
%   is either a NF-by3 or NF-by-4 array containing indices of vertices of
%   the triangular or rectangular faces.
%   FACES can also be a cell array, in the content of each cell is an array
%   of indices to the nodes of the current face. Faces can have different
%   number of vertices.
%   
%   H = drawPolyhedron(...);
%   Also returns a handle to the created patche.
%
%   Example:
%   [n f] = createSoccerBall;
%   drawPolyhedron(n, f);
%
%   See also:
%   polyhedra, drawMesh, drawPolygon
%
%   ---------
%
%   author : David Legland 
%   INRA - TPV URPOI - BIA IMASTE
%   created the 10/02/2005.
%

%   HISTORY
%   07/11/2005 update doc.
%   04/01/2007 typo
%   18/01/2007 add support for 2D polyhedra ("nodes" is N-by-2 array), and
%       make 'cnodes' a list of points instead of a list of indices
%   14/08/2007 add comment, add support for NaN in faces (complex polygons)
%   14/09/2007 rename as drawPolyhedron
%   16/10/2008 better support for colors
%   27/07/2010 copy to 'drawMesh'


%% Initialisations


% process input arguments
switch length(varargin)
    case 0 
        % default color is red
        varargin = {'facecolor', [1 0 0]};
    case 1
        % use argument as color for faces
        varargin = {'facecolor', varargin{1}};
    otherwise
        % otherwise do nothing
end

% overwrites on current figure
hold on;

% if nodes are 2D points, add a z=0 coordinate
if size(nodes, 2) == 2
    nodes(1,3) = 0;
end


%% main loop : for each face

if iscell(faces)
    % array FACES is a cell array
    h = zeros(length(faces(:)), 1);

    for f = 1:length(faces(:))
        % get nodes of the cell
        face = faces{f};

        if sum(isnan(face))~=0
            % Special processing in case of multiple polygonal face.
            % each polygonal loop is separated by a NaN.
            
            % find indices of loops breaks
            inds = find(isnan(face));
            
            % replace NaNs by index of first vertex of each polygon
            face(inds(2:end))   = face(inds(1:end-1)+1);
            face(inds(1))       = face(1);
            face(length(face)+1)= face(inds(end)+1);            
        end
        
        % draw current face
        cnodes  = nodes(face, :);
        h(f)    = patch(cnodes(:, 1), cnodes(:, 2), cnodes(:, 3), [1 0 0]);
    end

else
    % array FACES is a NC*NV indices array, with NV : number of vertices of
    % each face, and NC number of faces
    h = zeros(size(faces, 1), 1);
    for f = 1:size(faces, 1)
        % get nodes of the cell
        cnodes = nodes(faces(f,:)', :);
        h(f) = patch(cnodes(:, 1), cnodes(:, 2), cnodes(:, 3), [1 0 0]);
    end
end

% set up drawing options
if ~isempty(varargin)
    set(h, varargin{:});
end

% format output parameters
if nargout > 0
    varargout = {h};
end
