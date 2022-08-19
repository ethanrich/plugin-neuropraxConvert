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

function varargout = revolutionSurface(varargin)
%REVOLUTIONSURFACE Create a surface of revolution from a planar curve.
%
%   usage 
%   [X Y Z] = revolutionSurface(C1, C2, N);
%   create the surface of revolution of parametrized function (xt, yt),
%   with N+1 equally spaced slices, around the Oz axis.
%   It assumed that C1 corresponds to the x coordinate, and that C2
%   corresponds to the Oz coordinate.
%
%   [X Y Z] = revolutionSurface(CURVE, N);
%   is the same, but generating curve is given in a single parameter CURVE,
%   which is a [Nx2] array of 2D points.
%
%   [X Y Z] = revolutionSurface(..., THETA)
%   where THETA is a vector, uses values of THETA for computing revolution
%   angles.
%
%   [X Y Z] = revolutionSurface(..., LINE);
%   where LINE is a 1x4 array, specifes the revolution axis in the
%   coordinate system of the curve. LINE is a row vector of 4 parameters,
%   containing [x0 y0 dx dy], where (x0,y0) is the origin of the line and
%   (dx,dy) is a direction vector of the line.
%   The resulting revolution surface still has Oz axis as symmetry axis. It
%   can be transformed using transformPoint3d function.
%   Surface can be displayed using :
%   H = surf(X, Y, Z);
%   H is a handle to the created patch.
%
%   revolutionSurface(...);
%   by itself, directly shows the created patch.
%
%   Example
%   % draws a piece of torus
%   circle = circleAsPolygon([10 0 3], 50);
%   [x y z] = revolutionSurface(circle, linspace(0, 4*pi/3, 50));
%   surf(x, y, z);
%   axis equal;
%
%
%
%   See also
%       surf, transformPoint3d, drawSphere, drawTorus, drawEllipsoid
%       surfature (on Matlab File Exchange)
%
%
%   ------
%   Author: David Legland
%   e-mail: david.legland@grignon.inra.fr
%   Created: 2004-04-09
%   Copyright 2005 INRA - CEPIA Nantes - MIAJ Jouy-en-Josas.

%   based on function cylinder from matlab
%   31/06/2006 fix bug when passing 3 parameters
%   20/04/2007 rewrite processing of input parameters, add psb to specify
%       revolution axis
%   24/10/2008 fix angle vector
%   29/07/2010 doc update


%% Initialisations

% default values

% use revolution using the full unit circle, decomposed into 24 angular
% segments (thus, some vertices correspond to particular angles 30°,
% 45°...)
theta = linspace(0, 2*pi, 25);

% use planar vertical axis as default revolution axis
revol = [0 0 0 1];

% extract the generating curve
var = varargin{1};
if size(var, 2)==1
    xt = var;
    yt = varargin{2};
    varargin(1:2) = [];
else
    xt = var(:,1);
    yt = var(:,2);
    varargin(1) = [];
end

% extract optional parameters: angles, axis of revolution
% parameters are identified from their length
while ~isempty(varargin)
    var = varargin{1};
    
    if length(var) == 4
        % axis of rotation in the base plane
        revol = var;
        
    elseif length(var) == 1
        % number of points -> create row vector of angles
        theta = linspace(0, 2*pi, var);
        
    else
        % use all specified angle values
        theta = var(:)';
        
    end
    varargin(1) = [];
end


%% Create revolution surface

% ensure length is enough
m = length(xt);
if m==1
    xt = [xt xt];
end

% ensure x and y are vertical vectors
xt = xt(:);
yt = yt(:);

% transform xt and yt to replace in the reference of the revolution axis
tra = createTranslation(-revol(1:2));
rot = createRotation(pi/2 - lineAngle(revol));
[xt, yt] = transformPoint(xt, yt, tra*rot);

% compute surface vertices
x = xt * cos(theta);
y = xt * sin(theta);
z = yt * ones(size(theta));


%% Process output arguments

% format output depending on how many output parameters are required
if nargout == 0
    % draw the revolution surface
    surf(x, y, z);
    
elseif nargout == 1
    % draw the surface and return a handle to the shown structure
    h = surf(x, y, z);
    varargout{1} = h;
    
elseif nargout == 3
    % return computed mesh
    varargout = {x, y, z};
end


