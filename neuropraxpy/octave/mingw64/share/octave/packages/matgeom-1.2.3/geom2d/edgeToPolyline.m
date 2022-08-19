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

function poly = edgeToPolyline(edge, N)
%EDGETOPOLYLINE Convert an edge to a polyline with a given number of segments.
%
%   POLY = edgeToPolyline(EDGE, N)
%   
%   Example
%     edge = [10 20 60 40];
%     poly = edgeToPolyline(edge, 10);
%     drawEdge(edge, 'lineWidth', 2);
%     hold on
%     drawPoint(poly);
%     axis equal;
%
%   See also
%     edges2d, drawEdge, drawPolyline   
%
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2011-11-25,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2011 INRA - Cepia Software Platform.

if N < 1
    error('number of segments must be greater than 1');
end


if length(edge) == 4
    % case of planar edges
    p1 = edge(1:2);
    p2 = edge(3:4);
    poly = [linspace(p1(1), p2(1), N+1)' linspace(p1(2), p2(2), N+1)'];
    
else
    % case of 3D edges
    p1 = edge(1:3);
    p2 = edge(4:6);
    poly = [...
        linspace(p1(1), p2(1), N+1)' ...
        linspace(p1(2), p2(2), N+1)' ...
        linspace(p1(3), p2(3), N+1)'];
end
