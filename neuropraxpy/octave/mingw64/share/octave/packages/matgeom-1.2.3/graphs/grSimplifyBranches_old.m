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

function varargout = grSimplifyBranches_old(nodes, edges)
%GRSIMPLIFYBRANCHES_OLD Replace branches of a graph by single edges.
%
%   [NODES2 EDGES2] = grSimplifyBranches(NODES, EDGES)
%   Replaces each branch (composed of a series of edges connected only by
%   2-degree nodes) by a single edge, whose extremities are nodes with
%   degree >= 3.
%

%   -----
%   author : David Legland 
%   INRA - TPV URPOI - BIA IMASTE
%   created the 13/08/2003.
%

%   HISTORY
%   10/02/2004 doc

n = 1;
while n < length(nodes)
    neigh = grAdjacentNodes(edges, n);
    if length(neigh) == 2
        % find other node of first edge
        edge = edges(neigh(1), :);
        if edge(1) == n
            node1 = edge(2);
        else
            node1 = edge(1);
        end

        % replace current node in the edge by the other node
        % of first edge
        edge = edges(neigh(2), :);
        if edge(1) == n
            edges(neigh(2), 1) = node1;
        else
            edges(neigh(2), 2) = node1;
        end
        
        [nodes, edges] = grRemoveNode(nodes, edges, n);
        continue
    end
    
    n = n + 1;
end

% process output depending on how many arguments are needed
if nargout == 1
    out{1} = nodes;
    out{2} = edges;
    varargout = {out};
end

if nargout == 2
    varargout = {nodes, edges};
end
