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

function edges2d(varargin)
%EDGES2D  Description of functions operating on planar edges.
%
%   An edge is represented by the coordinate of its extremities:
%   EDGE = [X1 Y1 X2 Y2];
%
%   Centered edges are sometimes used (for example for representing main
%   axes of an ellipse or an oriented box). Centered edges are represented
%   by their center, their length, and their orientation (counted in
%   degrees and counter-clockwise).
%   CEDGE = [XC YC LEN THETA];
%
%   A set of edges is represented by a N-by-4 array, each row representing
%   an edge.
%
%
%   See also:
%   lines2d, rays2d, points2d, createEdge, parallelEdge, 
%   edgeAngle, edgeLength, midPoint, edgeToLine, lineToEdge
%   intersectEdges, intersectLineEdge, isPointOnEdge, edgeToPolyline
%   clipEdge, transformEdge, intersectEdgePolygon, centeredEdgeToEdge
%   drawEdge, drawCenteredEdge
%

% ------
% Author: David Legland
% e-mail: david.legland@inra.fr
% Created: 2008-10-13,    using Matlab 7.4.0.287 (R2007a)
% Copyright 2008 INRA - BIA PV Nantes - MIAJ Jouy-en-Josas.

help('edges2d');
