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

function h = drawPoint3d(varargin)
%DRAWPOINT3D Draw 3D point on the current axis.
%
%   drawPoint3d(X, Y, Z) 
%   will draw points defined by coordinates X, Y and Z. 
%   X, Y and Z are N*1 array, with N being number of points to be drawn.
%   
%   drawPoint3d(COORD) packs coordinates in a single [N*3] array.
%
%   drawPoint3d(..., OPT) will draw each point with given option. OPT is a 
%   string compatible with 'plot' model.
%
%   drawPoint3d(AX,...) plots into AX instead of GCA.
%
%   H = drawPoint3d(...) returns a handle H to the line object
%
%   Example
%     % generate points on a 3D circle
%     pts = circleToPolygon([40 30 20], 120);
%     mat = eulerAnglesToRotation3d([30 20 10]);
%     pts3d = transformPoint3d([pts zeros(120,1)],mat);
%     figure; drawPoint3d(pts3d, 'b.');
%     view(3); axis equal;
%
%   See also
%     points3d, clipPoints3d, drawPoint
%

% ---------
% Author : David Legland 
% INRA - TPV URPOI - BIA IMASTE
% created the 18/02/2005.
%
%   HISTORY
%   04/01/2007: remove unused variables, and enhance support for plot
%       options
%   12/02/2010 does not clip points anymore
%   12/01/2018 added axes handle input
%

if isAxisHandle(varargin{1})
    hAx = varargin{1};
    varargin(1)=[];
else
    hAx = gca;
end

if length(varargin) == 1 && size(varargin{1}, 2) == 3
    % points are given as one single array with 3 columns
    px = varargin{1}(:,1);
    py = varargin{1}(:,2);
    pz = varargin{1}(:,3);
    varargin = {};
elseif length(varargin) == 2 && size(varargin{1}, 2) == 3
    % points are given as one single array with 3 columns
    px = varargin{1}(:,1);
    py = varargin{1}(:,2);
    pz = varargin{1}(:,3);
    varargin = varargin(2);
elseif length(varargin) >= 3 && size(varargin{1}, 2) == 3
    % points are given as one single array with 3 columns
    px = varargin{1}(:,1);
    py = varargin{1}(:,2);
    pz = varargin{1}(:,3);
    varargin = varargin(2:end);
elseif length(varargin) == 3 && numel(varargin{1})==numel(varargin{2}) && numel(varargin{1})==numel(varargin{3})
    % points are given as 3 columns with equal lengths
    px = varargin{1};
    py = varargin{2};
    pz = varargin{3};
    varargin = {};
elseif length(varargin) > 3
    % points are given as 3 columns with equal lengths
    px = varargin{1};
    py = varargin{2};
    pz = varargin{3};
    varargin = varargin(4:end);
else
    error('wrong number of arguments in drawPoint3d');
end

% default draw style: no line, marker is 'o'
if length(varargin) ~= 1
    varargin = ['linestyle', 'none', 'marker', 'o', varargin];
end

% plot only points inside the axis.
hh = plot3(hAx, px, py, pz, varargin{:});

if nargout > 0
    h = hh;
end
