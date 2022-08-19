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

function lines2d(varargin)
%LINES2D  Description of functions operating on planar lines.
%
%   The term 'line' refers to a planar straight line, which is an unbounded
%   curve. Line segments defined between 2 points, which are bounded, are
%   called 'edge', and are presented in file 'edges2d'.
%
%   A straight line is defined by a point (its origin), and a vector (its
%   direction). The parameters are bundled into a 1-by-4 row vector:
%   LINE = [x0 y0 dx dy];
%
%   A line contains all points (x,y) such that:
%       x = x0 + t*dx
%       y = y0 + t*dy;
%   for all t between -infinity and +infinity.
%
%   See also:
%   points2d, vectors2d, edges2d, rays2d
%   createLine, cartesianLine, medianLine, edgeToLine, lineToEdge
%   orthogonalLine, parallelLine, bisector, radicalAxis
%   lineAngle, linePosition, projPointOnLine
%   isPointOnLine, distancePointLine, isLeftOriented
%   intersectLines, intersectLineEdge, clipLine
%   reverseLine, transformLine, drawLine
%   lineFit

% ------
% Author: David Legland
% e-mail: david.legland@inra.fr
% Created: 2008-10-13,    using Matlab 7.4.0.287 (R2007a)
% Copyright 2008 INRA - BIA PV Nantes - MIAJ Jouy-en-Josas.

help('lines2d');
