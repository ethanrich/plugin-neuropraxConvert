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

function varargout = drawRay(ray, varargin)
%DRAWRAY Draw a ray on the current axis.
%
%   drawRay(RAY)
%   With RAY having the syntax: [x0 y0 dx dy], draws the ray starting from
%   point (x0 y0) and going to direction (dx dy), clipped with the current
%   window axis.
%
%   drawRay(RAY, PARAMS, VALUE)
%   Can specify param-pair values.
%
%   H = drawRay(...)
%   Returns handle on line object
%
%   See also:
%   rays2d, drawLine
%
%   ---------
%
%   author : David Legland 
%   INRA - TPV URPOI - BIA IMASTE
%   created the 31/10/2003.
%

%   HISTORY
%   2005-07-06 add support for multiple rays
%   2007-10-18 add support for drawing options
%   2011-03-12 rewrite using clipRay
%   2011-10-11 add management of axes handle

% extract handle of axis to draw in
if isAxisHandle(ray)
    ax = ray;
    ray = varargin{1};
    varargin(1) = [];
else
    ax = gca;
end

% get bounding box limits
box = axis(ax);

% compute clipped shapes
[clipped, isInside] = clipRay(ray, box);

% allocate memory for handle
h = -ones(size(ray, 1), 1);

% draw visible rays
h(isInside) = drawEdge(ax, clipped(isInside, :), varargin{:});

% process output
if nargout > 0
    varargout = {h};
end
