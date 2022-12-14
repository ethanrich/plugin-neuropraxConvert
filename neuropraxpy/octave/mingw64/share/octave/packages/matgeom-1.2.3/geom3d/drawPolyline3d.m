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

function varargout = drawPolyline3d(varargin)
%DRAWPOLYLINE3D Draw a 3D polyline specified by a list of vertex coords.
%
%   drawPolyline3d(POLY);
%   packs coordinates in a single N-by-3 array.
%
%   drawPolyline3d(PX, PY, PZ);
%   specifies coordinates in separate numeric vectors (either row or
%   columns)
%
%   drawPolyline3d(..., CLOSED);
%   Specifies if the polyline is closed or open. CLOSED can be one of:
%   - 'closed'
%   - 'open'    (the default)
%   - a boolean variable with value TRUE for closed polylines.
%
%   drawPolyline3d(..., PARAM, VALUE);
%   Specifies style options to draw the polyline, see plot for details.
%
%   H = drawPolyline3d(...);
%   also returns a handle to the list of created line objects.
%
%   Example
%     t = linspace(0, 2*pi, 100)';
%     xt = 10 * cos(t);
%     yt = 5 * sin(t);
%     zt = zeros(1,100);
%     figure; drawPolyline3d(xt, yt, zt, 'b');
% 
%   See Also:
%   polygons3d, drawPolygon3d, fillPolygon3d
%

% ---------
% Author : David Legland 
% e-mail: david.legland@inra.fr
% Created: 2005-02-15
% Copyright 2005 INRA - TPV URPOI - BIA IMASTE

% HISTORY
% 2010-03-08 rename to drawPolyline3d


%% Process input arguments
hAx = gca;
if isAxisHandle(varargin{1})
    hAx = varargin{1};
    varargin(1) = [];
end

% check case we want to draw several curves, stored in a cell array
var = varargin{1};
if iscell(var)
    hold on;
    h = zeros(length(var(:)), 1);
    for i = 1:length(var(:))
        h(i) = drawPolyline3d(hAx, var{i}, varargin{2:end});
    end
    if nargout > 0
        varargout = {h};
    end
    return;
end

% extract curve coordinates
if min(size(var)) == 1
    % if first argument is a vector (either row or column), then assumes
    % first argument contains x coords, second argument contains y coords
    % and third one the z coords
    px = var;
    if length(varargin) < 3
        error('geom3d:drawPolyline3d:Wrong number of arguments in drawPolyline3d');
    end
    if  isnumeric(varargin{2}) && isnumeric(varargin{3})
        py = varargin{2};
        pz = varargin{3};
        varargin(1:3) = [];
    else
        px = var(:, 1);
        py = var(:, 2);
        pz = var(:, 3);
        varargin(1) = [];
    end
else
    % all coordinates are grouped in the first argument
    px = var(:, 1);
    py = var(:, 2);
    pz = var(:, 3);
    varargin(1) = [];
end

% check if curve is closed or open (default is open)
closed = false;
if ~isempty(varargin)
    var = varargin{1};
    if islogical(var)
        % check boolean flag
        closed = var;
        varargin = varargin(2:end);
        
    elseif ischar(var)
        % check string indicating close or open
        if strncmpi(var, 'close', 5)
            closed = true;
            varargin = varargin(2:end);
            
        elseif strncmpi(var, 'open', 4)
            closed = false;
            varargin = varargin(2:end);
        end
        
    end
end


%% draw the curve

% for closed curve, add the first point at the end to close curve
if closed
    px = [px(:); px(1)];
    py = [py(:); py(1)];
    pz = [pz(:); pz(1)];
end

h = plot3(hAx, px, py, pz, varargin{:});

if nargout > 0
    varargout = {h};
end
