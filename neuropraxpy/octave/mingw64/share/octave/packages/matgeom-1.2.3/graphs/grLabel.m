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

function labels = grLabel(nodes, edges)
%GRLABEL Associate a label to each connected component of the graph.
%
%   LABELS = grLabel(NODES, EDGES)
%   Returns an array with as many rows as the array NODES, containing index
%   number of each connected component of the graph. If the graph is
%   totally connected, returns an array of 1.
%
%   Example
%       nodes = rand(6, 2);
%       edges = [1 2;1 3;4 6];
%       labels = grLabel(nodes, edges);
%   labels =
%       1
%       1
%       1
%       2
%       3
%       2   
%
%   See also
%   getNeighborNodes
%
%
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2007-08-14,    using Matlab 7.4.0.287 (R2007a)
% Copyright 2007 INRA - BIA PV Nantes - MIAJ Jouy-en-Josas.

% init
Nn = size(nodes, 1);
labels = (1:Nn)';

% iteration until stability
modif = true;
while modif
    modif = false;
    
    % compute the minimum label in the neighborhood of each node
    for i = 1:Nn
        neigh = grAdjacentNodes(edges, i);
        neighLabels = labels([i;neigh]);
        
        % check for a modification
        if length(unique(neighLabels)) > 1
            modif = true;
        end
        
        % put new labels
        labels(ismember(labels, neighLabels)) = min(neighLabels);
    end
end

% renumbering to have fewer labels
labels2 = unique(labels);
for i = 1:length(labels2)
    labels(labels == labels2(i)) = i;
end

