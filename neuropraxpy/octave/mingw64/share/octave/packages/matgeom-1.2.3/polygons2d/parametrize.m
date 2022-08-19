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

function par = parametrize(varargin)
%PARAMETRIZE Parametrization of a polyline, based on edges lengths.
%
%   PAR = parametrize(POLY);
%   Returns a parametrization of the curve defined by the serie of points,
%   based on euclidean distance between two consecutive points. 
%   POLY is a N-by-2 array, representing coordinates of vertices. The
%   result PAR is N-by-1, and contains the cumulative length of edges until
%   corresponding vertex.
%
%   PAR = parametrize(PX, PY);
%   is the same, but specify points coordinates in separate column vectors.
%
%   PAR = parametrize(..., 'normalize', 1);
%   PAR = parametrize(..., 'normalize', true);
%   Rescales the result such that the last element of PAR is 1.
% 
%   Example
%     % Parametrize a circle approximation
%     poly = circleToPolygon([0 0 1], 200);
%     p = parametrize(poly);
%     p(end)
%     ans = 
%         6.2829
%
%   See also:
%   polygons2d, polylineLength
%
%   ---------
%   author : David Legland 
%   INRA - TPV URPOI - BIA IMASTE
%   created the 06/04/2003.
%


%% Process inputs

% extract vertex coordinates
if size(varargin{1}, 2) > 1
    % vertices in a single array
    pts = varargin{1};
    varargin(1) = [];
    
elseif length(varargin) == 2
    % points as separate arrays
    pts = [varargin{1} varargin{2}];
    varargin(1:2) = [];
    
end

% by default, do not normalize
normalize = false;

% extract options
while length(varargin) > 1
    param = varargin{1};
    switch lower(param)
        case 'normalize'
            normalize = varargin{2};
        otherwise
            error('Unknown parameter name: %s', param);
    end
    varargin(1:2) = [];
end


%% Parametrize polyline

% compute cumulative sum of euclidean distances between consecutive
% vertices, setting distance of first vertex to 0.
if size(pts, 2) == 2
    % process points in 2D
    par = [0 ; cumsum(hypot(diff(pts(:,1)), diff(pts(:,2))))];
else
    % process points in arbitrary dimension
    par = [0 ; cumsum(sqrt(sum(diff(pts).^2, 2)))];
end

% eventually rescale between 0 and 1
if normalize
    par = par / par(end);
end

