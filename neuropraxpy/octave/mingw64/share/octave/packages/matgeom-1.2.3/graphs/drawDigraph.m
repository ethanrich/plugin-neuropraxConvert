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

function varargout = drawDigraph(varargin)
%DRAWDIGRAPH Draw a directed graph, given as a set of vertices and edges.
%
%   drawDigraph(NODES1, NODES2, EDGES) 
%   NODES1 are originating vertices
%   NODES2 are destination vertices
%   EDGES is an array, with first column containing index of origin vertex
%   (index in NODES1), and second column containing index of destination
%   vertex (index in NODES2).
%   Edges are drawn with arrows.
%
%   H = drawDigraph(...) 
%   return handle to the set of edges.
%   
%   
%   -----
%
%   author : David Legland 
%   INRA - TPV URPOI - BIA IMASTE
%   created the 17/08/2004.
%


%% Initialisations

% check number of arguments
if nargin < 3
    help drawDigraph;
    return;
end

% initialisations
sn1 = 'bo';     % nodes are red circles
sn2 = 'ro';     % nodes are red circles


%% process input arguments


% First extract the graph structure
n1 = varargin{1};
n2 = varargin{2};
e  = varargin{3};
varargin = varargin(4:length(varargin));

% extract drawing style 
if ~isempty(varargin)
    sn1 = varargin{1};
end

if length(varargin)>1
    sn2 = varargin{2};
end


%% main drawing processing

hold on;

nodes = [n1 ; n2];
e(:,2) = e(:,2)+length(n1);

% Draw a 2 dimensional directed graph ----------------------

    
% Draw 2D Edges ----------------------
%if ~strcmp(se, 'none') & size(e, 1)>0
%    he = plot([n1(e(:,1),1) n2(e(:,2),1)]', [n1(e(:,1),2) n2(e(:,2),2)]', se);
%end
he = drawDirectedEdges(nodes, e);

hn = [];
% Draw 2D nodes ----------------------
if ~strcmp(sn1, 'none')
    hn = plot(n1(:,1), n1(:,2), sn1);   
end

 % Draw 2D nodes ----------------------
if ~strcmp(sn2, 'none')
    hn = plot(n2(:,1), n2(:,2), sn2);   
end
    
   
%% format output arguments

if nargout==1
    varargout{1} = he;
end

if nargout==2
    varargout{1} = hn;
    varargout{2} = he;
end

