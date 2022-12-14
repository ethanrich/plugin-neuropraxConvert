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

function pts2 = grFaceToPolygon(varargin)
%GRFACETOPOLYGON Compute the polygon corresponding to a graph face.
%
%   PTS2 = grFaceToPolygon(NODES, EDGES, FACES, INDF)
%   PTS2 = grFaceToPolygon(NODES, FACES, INDF)
%   Where NODES, EDGES, and FACES are internal data of graph, and INDF is
%   the index of the face to extract. The result is the (ordered) set of
%   points composing the face.
%
%   
%   PTS2 = grFaceToPolygon(GRAPH, INDF)
%   use structure representation for graph. The structure GRAPH must
%   contain data for fields 'nodes' and 'faces'.
%   
%   If several indices face indices are specified, result is a cell array
%   of polygons.
%
%   The number of columns of PTS2 is the same as for NODES.
%
%
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2005-11-30
% Copyright 2005 INRA - CEPIA Nantes - MIAJ (Jouy-en-Josas).

%   HISTORY
%   27/07/2007: cleanup code

if length(varargin)==2
    % argument is a graph structure
    graph = varargin{1};
    nodes = graph.nodes;
    faces = graph.faces;
    indf  = varargin{2};
    
elseif length(varargin)==3
    % arguments are nodes, faces and indices
    nodes = varargin{1};
    faces = varargin{2};
    indf  = varargin{3};
    
elseif length(varargin)==4
    % arguments are nodes, edges, faces and indices, we forget edges
    nodes = varargin{1};
    faces = varargin{3};
    indf  = varargin{4};
end


if iscell(faces)
    % faces is a cell array
    if length(indf)==1
        face = faces{indf};
        pts2 = nodes(face, :);
    else
        pts2 = cell(length(indf), 1);
        for i=1:length(indf)
            face = faces{indf(i)};
            pts2{i} = nodes(face, :);
        end
    end
else
    % faces is an indices array: all faces have same number of vertices
    if length(indf)==1
        face = faces(indf, :);
        pts2 = nodes(face, :);
    else
        pts2 = cell(length(indf), 1);
        for i=1:length(indf)
            face = faces(indf(i), :);
            pts2{i} = nodes(face, :);
        end
    end
end

