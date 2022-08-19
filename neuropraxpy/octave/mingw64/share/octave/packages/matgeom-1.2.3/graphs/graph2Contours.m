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

function varargout = graph2Contours(nodes, edges) %#ok<INUSL>
%GRAPH2CONTOURS Convert a graph to a set of contour curves.
% 
%   CONTOURS = GRAPH2CONTOURS(NODES, EDGES)
%   NODES, EDGES is a graph representation (type "help graphs" for details)
%   The algorithm assume every node has degree 2, and the set of edges
%   forms only closed loops. The result is a list of indices arrays, each
%   array containing consecutive point indices of a contour.
%
%   To transform contours into drawable curves, please use :
%   CURVES{i} = NODES(CONTOURS{i}, :);
%
%
%   NOTE : contours are not oriented. To manage contour orientation, edges
%   also need to be oriented. So we must precise generation of edges.
%
%   -----
%
%   author : David Legland 
%   INRA - TPV URPOI - BIA IMASTE
%   created the 05/08/2004.
%


curves = {};
c = 0;

while size(edges,1)>0
	% find first point of the curve
	n0 = edges(1,1);   
    curve = n0;
    
    % second point of the curve
	n = edges(1,2);	
	e = 1;
    
	while true
        % add current point to the curve
		curve = [curve n];         %#ok<AGROW>
		
        % remove current edge from the list
        edges = edges((1:size(edges,1))~=e,:);
		
		% find index of edge containing reference to current node
		e = find(edges(:,1)==n | edges(:,2)==n);		    
        e = e(1);
        
		% get index of next current node
        % (this is the other node of the current edge)
		if edges(e,1)==n
            n = edges(e,2);
		else
            n = edges(e,1);
		end
		
        % if node is same as start node, loop is closed, and we stop 
        % node iteration.
        if n==n0
            break;
        end
	end
    
    % remove the last edge of the curve from edge list.
    edges = edges((1:size(edges,1))~=e,:);
    
    % add the current curve to the list, and start a new curve
    c = c+1;
    curves{c} = curve; %#ok<AGROW>
end

if nargout == 1
    varargout = {curves};
end
