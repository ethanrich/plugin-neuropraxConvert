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

function [nodes2, edges2] = pruneGraph(nodes, edges)
%PRUNEGRAPH Remove all edges with a terminal vertex.
%
%   [NODES2, EDGES2] = pruneGraph(NODES, EDGES)
%
%   Example
%     nodes = [...
%         10 30; 30 30; 20 45; 50 30; 40 15; 70 30; 90 30; 80 15; 100 45];
%     edges = [1 2;2 3;2 4;4 5;4 6;6 7;6 8;7 8;7 9];
%     figure; 
%     subplot(2, 1, 1); drawGraph(nodes, edges); 
%     axis equal; axis([0 110 10 50]);
%     [nodes2, edges2] = pruneGraph(nodes, edges);
%     subplot(2, 1, 2); drawGraph(nodes2, edges2); 
%     axis equal; axis([0 110 10 50]);
%
%   See also
%   graphs
 
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2015-02-19,    using Matlab 8.4.0.150421 (R2014b)
% Copyright 2015 INRA - Cepia Software Platform.

nNodes = size(nodes, 1);
degs = grNodeDegree(1:nNodes, edges)';

termNodeInds = find(degs == 1);

[nodes2, edges2] = grRemoveNodes(nodes, edges, termNodeInds);
