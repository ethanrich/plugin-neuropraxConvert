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

function res = parallelEdge(edge, dist)
%PARALLELEDGE Edge parallel to another edge.
%
%   EDGE2 = parallelEdge(EDGE, DIST)
%   Computes the edge parallel to the input edge EDGE and located at the
%   given signed distance DIST.
%
%   Example
%     obox = [30 40 80 40 30];
%     figure; hold on; axis equal;
%     drawOrientedBox(obox, 'LineWidth', 2);
%     edge1 = centeredEdgeToEdge(obox([1 2 3 5]));
%     edge2 = centeredEdgeToEdge(obox([1 2 4 5])+[0 0 0 90]);
%     drawEdge(edge1, 'LineWidth', 2, 'color', 'g');
%     drawEdge(edge2, 'LineWidth', 2, 'color', 'g');
%     drawEdge(parallelEdge(edge1, -30), 'LineWidth', 2, 'color', 'k');
%     drawEdge(parallelEdge(edge2, -50), 'LineWidth', 2, 'color', 'k');
%
%   See also
%     edges2d, parallelLine, drawEdge, centeredEdgeToEdge, edgeToLine
%
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2012-07-31,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2012 INRA - Cepia Software Platform.

% compute the line parallel to the supporting line of edge
line = parallelLine(edgeToLine(edge), dist);

% result edge is given by line positions 0 and 1.
res = [line(:, 1:2) line(:, 1:2)+line(:, 3:4)];
