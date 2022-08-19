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

function edge = lineToEdge3d(line)
%LINETOEDGE3D Convert a 3D straight line to a 3D finite edge.
%
%   EDGE = lineToEdge3d(LINE)
%   Returns the edge with same origin as the line LINE, and with second
%   extremity corresponding to the addition of line origin and direction.
%   LINE is represented as [X0 Y0 Z0  DX DY DZ]
%   EDGE is represented as [X1 Y1 Z1  X2 Y2 Z2]
%
%   Example
%     line = [3 4 5  1 2 3];
%     edge = lineToEdge3d(line)
%     edge =
%          3   4   5   4   6   8
%
%   See also
%     lines3d, edges3d, edgeToLine3d
 
% ------
% Author: David Legland
% e-mail: david.legland@inra.fr
% Created: 2019-05-07,    using Matlab 9.6.0.1072779 (R2019a)
% Copyright 2019 INRA - Cepia Software Platform.

edge = [line(:, 1:3) line(:,1:3)+line(:,4:6)];
