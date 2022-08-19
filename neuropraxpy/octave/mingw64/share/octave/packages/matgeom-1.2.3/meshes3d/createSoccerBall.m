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

function varargout = createSoccerBall()
%CREATESOCCERBALL Create a 3D mesh representing a soccer ball.
%
%   It is basically a wrapper of the 'bucky' function in matlab.
%   [V, E, F] = createSoccerBall
%   return vertices, edges and faces that constitute a soccerball
%   V is a 60-by-3 array containing vertex coordinates
%   E is a 90-by-2 array containing indices of neighbor vertices
%   F is a 32-by-1 cell array containing vertex indices of each face
%   Example
%   [v, f] = createSoccerBall;
%   drawMesh(v, f);
%
%   See also
%   meshes, drawMesh, bucky

% ------
% Author: David Legland
% e-mail: david.legland@inra.fr
% Created: 2006-08-09
% Copyright 2006 INRA - CEPIA Nantes - MIAJ (Jouy-en-Josas).

%   HISTORY
%   2007-01-04 remove unused variables, enhance output processing
%   2010-12-07 clean up edges, uses formatMeshOutput


% get vertices and adjacency matrix of the buckyball
[b, n] = bucky;

% compute edges
[i, j] = find(b);
e = [i j];
e = unique(sort(e, 2), 'rows');

% compute polygons that correspond to each 3D face
f = minConvexHull(n)';

% format output
varargout = formatMeshOutput(nargout, n, e, f);
