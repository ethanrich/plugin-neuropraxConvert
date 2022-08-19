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

function varargout = fillPolygon3d(varargin)
%FILLPOLYGON3D Fill a 3D polygon specified by a list of vertex coords.
%
%   fillPolygon3d(COORD, COLOR)
%   packs coordinates in a single [N*3] array.
%   COORD can also be a cell array of polygon, in this case each polygon is
%   drawn using the same color.
%
%   fillPolygon3d(PX, PY, PZ, COLOR)
%   specifies coordinates in separate numeric vectors (either row or
%   columns)
%
%   fillPolygon3d(..., PARAM, VALUE)
%   allows to specify some drawing parameter/value pairs as for the plot
%   function.
%
%   H = fillPolygon3d(...) 
%   also returns a handle to the list of created patch objects. 
%
%   Example
%     t = linspace(0, 2*pi, 100)';
%     xt = 10 * cos(t);
%     yt = 5 * sin(t);
%     zt = zeros(1,100);
%     figure; fillPolygon3d(xt, yt, zt, 'c');
% 
%   See Also:
%   polygons3d, drawPolygon3d, drawPolyline3d
%

% ------
% Author: David Legland
% e-mail: david.legland@inra.fr
% Created: 2007-01-05
% Copyright 2007 INRA - BIA PV Nantes - MIAJ Jouy-en-Josas.

    
% check case we want to draw several curves, stored in a cell array
var1 = varargin{1};
if iscell(var1)
    hold on;
    h = [];
    for i = 1:length(var1(:))
        h = [h; fillPolygon3d(var1{i}, varargin{2:end})]; %#ok<AGROW>
    end
    if nargout>0
        varargout{1}=h;
    end
    return;
end

% extract vertex coordinates
if min(size(var1)) == 1
    % if first argument is a vector (either row or column), then assumes
    % first argument contains x coords, second argument contains y coords
    % and third one the z coords
    px = var1;
    if length(varargin) < 3
        error('geom3d:fillPolygon3d:Wrong number of arguments in fillPolygon3d');
    end
    py = varargin{2};
    pz = varargin{3};
    varargin = varargin(4:end);
else
    % first argument contains all three coordinates
    px = var1(:, 1);
    py = var1(:, 2);
    pz = var1(:, 3);
    varargin = varargin(2:end);
end

% extract color information
if isempty(varargin)
    color = 'c';
else
    color = varargin{1};
    varargin = varargin(2:end);
end

% fill the polygon
h = fill3(px, py, pz, color, varargin{:});

if nargout>0
    varargout{1}=h;
end
