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

function varargout = drawAxis3d(varargin)
%DRAWAXIS3D Draw a coordinate system and an origin.
%
%   drawAxis3d
%	Adds three 3D arrows to the current axis, corresponding to the 
%	directions of the 3 basis vectors Ox, Oy and Oz.
%	Ox vector is red, Oy vector is green, and Oz vector is blue.
%
%   drawAxis3d(L, R)
%   Specifies the length L and the radius of the cylinders representing the
%   different axes.
%   
%   drawAxis3d(..., 'TFM', TRANSFORM)
%   Transforms the coordinate system before drawing using TRANSFORM.
%
%   H = drawAxis3d(...) returns the group handle of the axis object.
%
%   Example
%   drawAxis3d
%
%   figure;
%   drawAxis3d(20, 1);
%   view([135,15]); lighting('phong'); camlight('head'); axis('equal')
%   xlabel X; ylabel Y; zlabel Z
%
%   See also
%   drawAxisCube
%
% ------
% Author: David Legland
% e-mail: david.legland@nantes.inra.fr
% Created: 2007-08-14,    using Matlab 7.4.0.287 (R2007a)
% Copyright 2007 INRA - BIA PV Nantes - MIAJ Jouy-en-Josas.

% Check if axes handle is specified
hAx = gca;
if ~isempty(varargin)
    if isAxisHandle(varargin{1})
        hAx = varargin{1};
        varargin(1)=[];
    end
end

% Parsing
p = inputParser;
addOptional(p,'L',1, @(x)validateattributes(x,{'numeric'},...
    {'scalar','nonempty','real','finite','positive','nonnan'}));
addOptional(p,'R',[], @(x)validateattributes(x,{'numeric'},...
    {'scalar','nonempty','real','finite','positive','nonnan'}));
addParameter(p,'TFM',eye(4), @isTransform3d);
parse(p,varargin{:});

L = p.Results.L;
R = p.Results.R;
if isempty(R)
    R=L/10;
elseif R/L > 0.1
    R = (0.1-eps)*L;
    warning('Value of R is invalid and was ignored!')
end
TFM = p.Results.TFM;

% geometrical data
origin = transformPoint3d(zeros(3,3), TFM);
vector = transformVector3d(eye(3,3), TFM);
color = eye(3,3);

% draw three arrows and a ball
hold on;
sh=drawArrow3d(hAx, origin, vector*L, color, 'arrowRadius', R/L);
sh(4)=drawSphere(hAx,[origin(1,:) 2*R], 'faceColor', 'black');
gh = hggroup(hAx);
set(sh,'Parent',gh)

if nargout > 0
    varargout = {gh};
end
