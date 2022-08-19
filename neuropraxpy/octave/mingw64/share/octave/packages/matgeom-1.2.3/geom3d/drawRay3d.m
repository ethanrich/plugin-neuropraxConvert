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

function h = drawRay3d(ray, varargin)
% Draw a 3D ray on the current axis.
%
%   drawRay3d(RAY)
%   With RAY having the syntax: [x0 y0 z0 dx dy dz], draws the ray starting
%   from point (x0 y0 z0) and going to direction (dx dy dz), clipped with
%   the current window axis.
%
%   drawRay3d(RAY, PARAMS, VALUE)
%   Can specify parameter name-value pairs to change draw style.
%
%   H = drawRay3d(...)
%   Returns handle on line object
%
%   See also:
%   rays2d, drawLine
%
%   Example
%     % generate 50 random 3D rays
%     origin = [29 28 27];
%     v = rand(50, 3);
%     v = v - centroid(v);
%     ray = [repmat(origin, size(v,1),1) v];
%     % draw the rays in the current axis
%     figure; axis equal; axis([0 50 0 50 0 50]); hold on; view(3);
%     drawRay3d(ray);
%
%   See also
%     drawLine3d, clipRay3d
 
% ------
% Author: David Legland
% e-mail: david.legland@inrae.fr
% INRAE - BIA Research Unit - BIBS Platform (Nantes)
% Created: 2020-05-25,    using Matlab 9.8.0.1323502 (R2020a)
% Copyright 2020 INRAE.

% extract handle of axis to draw in
if isAxisHandle(ray)
    hAx = ray;
    ray = varargin{1};
    varargin(1) = [];
else
    hAx = gca;
end

% get bounding box limits
box = axis(hAx);

% clip the ray(s) with the limits of the current axis
edge = clipLine3d(ray, box);

% identify valid edges
inds = sum(isnan(edge), 2) == 0;

% draw the clipped line
hh = [];
if any(inds)
    edge = edge(inds, :);
    hh = drawEdge3d(hAx, edge);
    if ~isempty(varargin)
        set(hh, varargin{:});
    end
end

% process output
if nargout > 0
    h = hh;
end
