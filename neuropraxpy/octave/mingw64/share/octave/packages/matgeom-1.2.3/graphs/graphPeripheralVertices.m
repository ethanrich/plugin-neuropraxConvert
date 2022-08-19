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

function inds = graphPeripheralVertices(v, e, l)
%GRAPHPERIPHERALVERTICES Peripheral vertices of a graph.
%
%   INDS = graphPeripheralVertices(V, E)
%   Return indices of peripheral vertices, that is, vertices whose
%   eccentricity is maximal and equal to the diameter of the graph.
%
%   INDS = graphPeripheralVertices(V, E, L)
%   Specify length of each edge. Default is 1 for each edge.
%
%
%   Example
%     nodes = [20 20;20 50;20 80;50 50;80 20;80 50;80 80];
%     edges = [1 2;2 3;2 4;4 6;5 6;6 7];
%     figure; drawGraph(nodes, edges);
%     axis([0 100 0 100]); axis equal; hold on
%     INDP = graphPeripheralVertices(nodes, edges);
%     INDP = 
%         1
%         3
%         5
%         7
%         
%
%   See Also
%   grPropagateDistance, grVertexEccentricity
%   graphCenter, graphDiameter, graphRadius
%
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2010-09-07,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2010 INRA - Cepia Software Platform.

% ensure there is a valid length array
if nargin<3
    l = ones(size(e,1), 1);
end

g = grVertexEccentricity(v, e, l);

inds = find(g==max(g));
