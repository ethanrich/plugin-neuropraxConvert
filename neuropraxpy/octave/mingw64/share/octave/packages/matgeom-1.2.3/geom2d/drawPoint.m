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

function h = drawPoint(varargin)
%DRAWPOINT Draw the point on the axis.
%
%   drawPoint(X, Y);
%   Draws points defined by coordinates X and Y.
%   X and Y should be array the same size.
%
%   drawPoint(COORD);
%   Packs coordinates in a single N-by-2 array.
%
%   drawPoint(..., OPT);
%   Draws each point with given option. OPT is a series of arguments pairs
%   compatible with 'plot' model. Default drawing option is 'bo',
%   corresponding to blue circles.
%   If a format string is used then only the color is effective.
%   Markers can be set using the 'marker' property.
%   The property 'linestyle' cannot be set.
%
%   drawPoint(AX, ...);
%   Specifies the axis to draw the points in. AX should be a handle to a axis
%   object. By default, display on current axis.
%
%   H = drawPoint(...) also return a handle to each of the drawn points.
%
%   Example
%     % display a single point
%     figure;
%     drawPoint([10 10]);
%
%     % display several points forming a circle
%     t = linspace(0, 2*pi, 20)';
%     drawPoint([5*cos(t)+10 3*sin(t)+10], 'r+');
%     axis equal;
%
%   See also
%     points2d, clipPoints

%   ---------
%   author : David Legland
%   INRA - TPV URPOI - BIA IMASTE
%   created the 31/10/2003.
%

%   HISTORY
%   23/02/2004 add more documentation. Manage different kind of inputs.
%     Does not draw points outside visible area.
%   26/02/2007 update processing of input arguments.
%   30/04/2009 remove clipping of points (use clipPoints if necessary)
%   2011-10-11 add management of axes handle
%   2018-31-06 fix the bug reported in https://savannah.gnu.org/bugs/index.php?53659

% extract handle of axis to draw on
if isAxisHandle(varargin{1})
    ax = varargin{1};
    varargin(1) = [];
else
    ax = gca;
end

% extract point(s) coordinates
if size(varargin{1}, 2) == 2
    % points packed in one array
    var = varargin{1};
    px = var(:, 1);
    py = var(:, 2);
    varargin(1) = [];
    
elseif isvector(varargin{1})
    % points stored in separate arrays
    if nargin == 1 || ~isnumeric(varargin{2})
        error('Missing array of y-coordinates');
    end
    px = varargin{1};
    py = varargin{2};
    varargin(1:2) = [];
    px = px(:);
    py = py(:);
    
else
    error('Points should be two 1D arrays or one N-by-2 array');
end

if length(varargin) > 1
    % Check if linestyle is given
    char_opt = cellfun(@lower, varargin(cellfun(@ischar, varargin)), ...
        'UniformOutput', false);
    tf = ismember('linestyle', char_opt);
    if tf
        error('Points cannot be draw with lines, use plot or drawPolygon instead');
    end
    hh = plot(ax, px, py, 'marker', 'o', 'linestyle', 'none', varargin{:});
    
elseif length(varargin) == 1
    % use the specified single option (for example: 'b.', or 'k+')
    hh = plot(ax, px, py, varargin{1});
else
    % use a default marker
    hh = plot(ax, px, py, 'o');
end

if nargout == 1
    h = hh;
end

end
