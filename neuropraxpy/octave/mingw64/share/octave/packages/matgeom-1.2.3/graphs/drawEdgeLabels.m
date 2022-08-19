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

function varargout = drawEdgeLabels(p, e, value)
%DRAWEDGELABELS Draw values associated to graph edges.
% 
%   usage:
%   drawEdgeLabels(NODES, EDGES, VALUES);
%   NODES: array of double, containing x and y values of nodes
%   EDGES: array of int, containing indices of in and out nodes
%   VALUES is an array the same length of EDGES, containing values
%   associated to each edges of the graph.
%
%   The function computes the center of each edge, and puts the text with
%   associated value.
%   
%   H = drawEdgeLabels(...) return array of handles to each text structure,
%   making possible to change font, color, size
%
%
%   -----
%   author: David Legland 
%   INRA - TPV URPOI - BIA IMASTE
%   created the 10/02/2003.
%

%   HISTORY
%   10/03/2004 included into lib/graph library


if length(p) > 1 && length(e) > 1
    h = zeros(length(e), 1);
    hold on;
    for l=1:length(e)
        % indices of source and target nodes
        n1 = e(l, 1);
        n2 = e(l, 2);
        
        % node coordinates
        x1 = p(n1, 1);
        y1 = p(n1, 2);
        x2 = p(n2, 1);
        y2 = p(n2, 2);
        
        % display the edge
        line([x1 x2], [y1 y2]);
        
        % coordinates of edge label
        xm = (x1 + x2)/2;
        ym = (y1 + y2)/2;
        
        % display label
        h(l) = text(xm, ym, sprintf('%3d', floor(value(l))));
    end
end

if nargout == 1
    varargout = {h};
end
