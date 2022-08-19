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

function varargout = grRemoveMultiplePoints(nodes, edges)
%GRREMOVEMULTIPLEPOINTS Remove groups of close nodes in a graph.
%
%   grRemoveMultiplePoints(nodes, edges)
%   Detects groups of nodes that belongs to the same global node.
%   This function is intended to be used as filter after a binary image
%   skeletonization and vectorization.
%

%   -----
%   author : David Legland 
%   INRA - TPV URPOI - BIA IMASTE
%   created the 13/08/2003.
%

%   HISTORY
%   10/02/2004 doc
%   27/04/2005 function was not working, due to mergeNode modification.


% TODO: accelerate function, by limiting action on nodes with degree>2
% TODO: algo does not work, it can forget some groups.

n = 1;
while n <= length(nodes)
    
    x = nodes(n, 1);
    y = nodes(n, 2);
    
    p1 = findPoint([x-1, y], nodes);
    p2 = findPoint([x+1, y], nodes);
    p3 = findPoint([x, y-1], nodes);
    p4 = findPoint([x, y+1], nodes);
    
    p = [p1 p2 p3 p4];
    p = p(p ~= 0);
        
    if length(p) > 1
        [nodes, edges] = grMergeNodes(nodes, edges, [n p]);
    end
    
    n = n+1;
end

% renumerate edges
b = unique(edges(:));
for i = 1:length(b)
    edges(edges == b(i)) = i;
end

% remove extra nodes
nodes = nodes(b, :);


% process output depending on how many arguments are needed
if nargout == 1
    out{1} = nodes;
    out{2} = edges;
    varargout{1} = out;
end

if nargout == 2
    varargout{1} = nodes;
    varargout{2} = edges;
end

