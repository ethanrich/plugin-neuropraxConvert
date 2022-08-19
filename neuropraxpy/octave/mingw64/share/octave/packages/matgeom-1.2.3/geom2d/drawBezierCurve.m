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

function varargout = drawBezierCurve(points, varargin)
%DRAWBEZIERCURVE Draw a cubic bezier curve defined by 4 control points.
%
%   drawBezierCurve(POINTS)
%   Draw the Bezier curve defined by the 4 control points stored in POINTS.
%   POINTS is either a 4-by-2 array (vertical concatenation of control
%   points coordinates), or a 1-by-8 array (horizontal concatenation of
%   control point coordinates). 
%
%   drawBezierCurve(..., PARAM, VALUE)
%   Specifies additional drawing parameters, see the line function for
%   details.
%
%   drawBezierCurve(AX, ...);
%   Spcifies the handle of the axis to draw on.
%
%   H = drawBezierCurve(...);
%   Return a handle to the created graphic object.
%
%
%   Example
%     drawBezierCurve([0 0;5 10;10 5;10 0]);
%     drawBezierCurve([0 0;5 10;10 5;10 0], 'linewidth', 2, 'color', 'g');
%
%   See also
%     drawPolyline, cubicBezierToPolyline
%
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2011-03-16,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2011 INRA - Cepia Software Platform.

%   HISTORY
%   2011-10-11 add management of axes handle

% extract handle of axis to draw on
if isAxisHandle(points)
    ax = points;
    points = varargin{1};
    varargin(1) = [];
else
    ax = gca;
end

% default number of discretization steps
N = 64;

% check if discretization step is specified
if ~isempty(varargin)
    var = varargin{1};
    if length(var) == 1 && isnumeric(var)
        N = round(var);
        varargin(1) = [];
    end
end

% convert control coordinates to polyline
poly = cubicBezierToPolyline(points, N);

% draw the curve
h = drawPolyline(ax, poly, varargin{:});

% eventually return a handle to the created object
if nargout > 0
    varargout = {h};
end
