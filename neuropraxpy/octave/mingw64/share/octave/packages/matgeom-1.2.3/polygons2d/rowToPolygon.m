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

function poly = rowToPolygon(row, varargin)
%ROWTOPOLYGON  Create a polygon from a row vector.
%
%   POLY = rowToPolygon(ROW)
%   Convert a 1-by-2*N row vector that concatenates all polygon vertex
%   coordinates into a N-by-2 array of coordinates.
%   Default ordering of coordinates in ROW is:
%   [X1 Y1 X2 Y2 X3 Y3 .... XN YN].
%
%   POLY = rowToPolygon(ROW, METHOD)
%   Specifies the method for concatenating coordinates. METHOS is one of:
%   'interlaced': default method, described above.
%   'packed': the vector ROW has format:
%   [X1 X2 X3 ... XN Y1 Y2 Y3 ... YN].
%
%   POLYS = rowToPolygon(ROWS, ...)
%   When ROWS is a NP-by-NV array containing the vertex coordinates of NP
%   polygons, returns a 1-by-NP cell array containing in each cell the
%   coordinates of the polygon.
%
%
%   Example
%   % Concatenate coordinates of a circle and draw it as a polygon
%     t = linspace (0, 2*pi, 200);
%     row = [cos(t) sin(t)];
%     poly = rowToPolygon(row, 'packed');
%     figure;drawPolygon(poly)
%
%   See also
%   polygons2d, polygonToRow

% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2010-07-23,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2010 INRA - Cepia Software Platform.

%   HISTORY
%   2014-01-29 add support for multiple rows

type = 'interlaced';
if ~isempty(varargin)
    type = varargin{1};
end

% number of polygons
nPolys = size(row, 1);
    
% polygon vertex number
Np = size(row, 2) / 2;


if strcmp(type, 'interlaced')
    % ordering is [X1 Y1 X2 X2... XN YN]
    if nPolys == 1
        poly = reshape(row, [2 Np])';
    else
        poly = cell(1, nPolys);
        for i = 1:nPolys
            poly{i} = reshape(row(i,:), [2 Np])';
        end
    end
    
elseif strcmp(type, 'packed')
    % ordering is [X1 X2 X3... XN Y1 Y2 Y3... YN]
    if nPolys == 1
        poly = [row(1:Np)' row(Np+1:end)'];
    else
        poly = cell(1, nPolys);
        for i = 1:nPolys
            poly{i} = [row(i, 1:Np)' row(i, Np+1:end)'];
        end
    end
end
