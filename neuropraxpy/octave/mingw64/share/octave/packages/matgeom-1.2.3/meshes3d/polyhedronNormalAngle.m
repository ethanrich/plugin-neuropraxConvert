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

function theta = polyhedronNormalAngle(varargin)
%POLYHEDRONNORMALANGLE Compute normal angle at a vertex of a 3D polyhedron.
%
%   THETA = polyhedraNormalAngle(NODES, EDGES, FACES, IND);
%   THETA = polyhedraNormalAngle(NODES, FACES, IND);
%   where NODES is a set of 3D points, and FACES a set of faces, whose
%   elements are indices to NODES array, compute the normal angle at the
%   vertex whose index is given by IND.
%
%   THETA = polyhedraNormalAngle(GRAPH, IND);
%   Uses a graph structure. GRAPH should contain at least fields : 'nodes'
%   and 'faces'.
%
%   Example :
%   % create a simple (irregular) tetrahedra
%   nodes = [0 0 0;1 0 0;0 1 0;0 0 1];
%   faces = [1 2 3;1 2 4;1 3 4;2 3 4];
%   % compute normal angle at each vertex
%   theta = polyhedronNormalAngle(nodes, faces, 1:size(nodes, 1));
%   % sum of normal angles should be equal to 4*pi :
%   sum(theta)
%
%
%   TODO works only for polyhedra with convex faces ! ! !
%
%   See also
%   polyhedra, polygon3dNormalAngle
%
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2005-11-30
% Copyright 2005 INRA - CEPIA Nantes - MIAJ (Jouy-en-Josas).


if length(varargin)==4
    nodes = varargin{1};
    faces = varargin{3};
    ind   = varargin{4};
    
elseif length(varargin)==3
    nodes = varargin{1};
    faces = varargin{2};
    ind   = varargin{3};
    
elseif length(varargin)==2
    graph = varargin{1};
    nodes = graph.nodes;
    faces = graph.faces;
    ind   = varargin{2};
else
    error('wrong number of arguments');
end


% number of angles to compute
na = length(ind);

theta = zeros(na, 1);
for i=1:na
    
    thetaf = [];
    
    % find faces containing given vertex,
    % and compute normal angle at each face containing vertex
    if iscell(faces)
        for j=1:length(faces)
            if ismember(ind(i), faces{j})
                % create 3D polygon
                face = nodes(faces{j}, :);
                
                % index of point in polygon
                indp = find(faces{j}==i);
                
                % compute normal angle of vertex
                thetaf = [thetaf polygon3dNormalAngle(face, indp)]; %#ok<AGROW>
            end
        end
    else
        indf = find(sum(ismember(faces, ind(i)), 2));
        
        thetaf = zeros(length(indf), 1);
        for j=1:length(indf)
            ind2 = faces(indf(j), :);
            face = nodes(ind2, :);
            indp = find(ind2==ind(i));
            thetaf(j) = pi - polygon3dNormalAngle(face, indp);
        end
    end
    

    % compute normal angle of polyhedron, by use of angle defect formula
    theta(i) = 2*pi - sum(thetaf);
    
end
