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

function degree = grNodeInnerDegree(node, edges)
%GRNODEINNERDEGREE Inner degree of a node in a graph.
%
%   DEG = grNodeInnerDegree(NODE, EDGES);
%   Returns the inner degree of a node in the given edge list, i.e. the
%   number of edges arriving to it.
%   NODE is the index of the node, and EDGES is a liste of couples of
%   indices (origin and destination node).   
% 
%   Note: Also works when node is a vector of indices
%
%   See Also:
%   grNodeDegree, grNodeOuterDegree
%
%
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2006-01-17
% Copyright 2006 INRA - CEPIA Nantes - MIAJ (Jouy-en-Josas).
%

%   HISTORY
%   2008-08-07 pre-allocate memory, update doc

% allocate memory
N = size(node, 1);
degree = zeros(N, 1);

% compute inner degree of each vertex
for i=1:length(node)
    degree(i) = sum(edges(:,2)==node(i));
end
