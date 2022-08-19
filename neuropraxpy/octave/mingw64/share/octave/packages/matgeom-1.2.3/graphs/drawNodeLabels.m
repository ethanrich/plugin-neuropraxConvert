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

function varargout = drawNodeLabels(nodes, value, varargin)
%DRAWNODELABELS Draw values associated to graph nodes.
% 
%   Usage:
%   drawNodeLabels(NODES, VALUES);
%   NODES: array of double, containing x and y values of nodes
%   VALUES is an array the same length of EDGES, containing values
%   associated to each edges of the graph.
%
%   H = drawNodeLabels(...) 
%   Returns array of handles to each text structure, making it possible to
%   change font, color, size 
%
%   -----
%   author: David Legland 
%   INRA - TPV URPOI - BIA IMASTE
%   created the 10/02/2003.
%

%   HISTORY
%   10/03/2004 included into lib/graph library

% extract handle of axis to draw on
if isAxisHandle(nodes)
    ax = nodes;
    nodes = value;
    value = varargin{1};
else
    ax = gca;
end

% number and dimension of nodes
Nn = size(nodes, 1);
Nd = size(nodes, 2);

% check input size
if length(value) ~= Nn
    error('Value array must have same length as node number');
end

% allocate memory
h = zeros(Nn, 1);

axes(ax);

if Nd == 2
    % Draw labels of 2D nodes
    for i = 1:Nn
        x = nodes(i, 1);
        y = nodes(i, 2);
        h(i) = text(x, y, sprintf('%3d', floor(value(i))));
    end
    
elseif Nd == 3
    % Draw labels of 3D nodes
    for i = 1:Nn
        x = nodes(i, 1);
        y = nodes(i, 2);
        z = nodes(i, 3);
        h(i) = text(x, y, z, sprintf('%3d', floor(value(i))));
    end
    
else
    error('Node dimension must be 2 or 3');
end

if nargout == 1
    varargout = {h};
end
