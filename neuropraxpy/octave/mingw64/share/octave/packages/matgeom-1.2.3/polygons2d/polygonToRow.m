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

function row = polygonToRow(polygon, varargin)
%POLYGONTOROW Convert polygon coordinates to a row vector.
%
%   ROW = polygonToRow(POLY);
%   where POLY is a N-by-2 array of points representing vertices of the
%   polygon, converts the vertex coordinates into a linear array:
%   ROW = [X1 Y1 X2 Y2 .... XN YN]
%
%   ROW = polygonToRow(POLY, TYPE);
%   Can coose another format for converting polygon. Possibilities are:
%   'interlaced' (default}, as described above
%   'packed': ROW has format [X1 X2 ... XN Y1 Y2 ... YN].
%
%   Example
%   square = [10 10 ; 20 10 ; 20 20 ; 10 20];
%   row = polygonToRow(square)
%   row = 
%       10   10   20   10   20   20   10   20 
%
%   % the same with different ordering
%   row = polygonToRow(square, 'packed')
%   row = 
%       10   20   20   10   10   10   20   20 
%
%
%   See also
%   polygons2d, rowToPolygon
%
%
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2010-07-23,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2010 INRA - Cepia Software Platform.

% determines ordering type
type = 'interlaced';
if ~isempty(varargin)
    type = varargin{1};
end


if strcmp(type, 'interlaced')
    % ordering is [X1 Y1 X2 X2... XN YN]
    Np = size(polygon, 1);
    row = reshape(polygon', [1 2*Np]);
    
elseif strcmp(type, 'packed')
    % ordering is [X1 X2 X3... XN Y1 Y2 Y3... YN]
    row = polygon(:)';
end
