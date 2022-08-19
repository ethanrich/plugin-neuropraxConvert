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

function varargout = drawEllipse3d(varargin)
%DRAWELLIPSE3D Draw a 3D ellipse.
%
%   Possible calls for the function :
%   drawEllipse3d([XC YC ZC A B THETA PHI])
%   drawEllipse3d([XC YC ZC A B THETA PHI PSI])
%   drawEllipse3d([XC YC ZC A B], [THETA PHI])
%   drawEllipse3d([XC YC ZC A B], [THETA PHI PSI])
%   drawEllipse3d([XC YC ZC A B], THETA, PHI)
%   drawEllipse3d([XC YC ZC], A, B, THETA, PHI)
%   drawEllipse3d([XC YC ZC A B], THETA, PHI, PSI)
%   drawEllipse3d([XC YC ZC], A, B, THETA, PHI, PSI)
%   drawEllipse3d(XC, YC, ZC, A, B, THETA, PHI)
%   drawEllipse3d(XC, YC, ZC, A, B, THETA, PHI, PSI)
%
%   where XC, YC, ZY are coordinate of ellipse center, A and B are the
%   half-lengths of the major and minor axes of the ellipse,
%   PHI and THETA are 3D angle (in degrees) of the normal to the plane
%   containing the ellipse (PHI between 0 and 360 corresponding to
%   longitude, and THETA from 0 to 180, corresponding to angle with
%   vertical).
%   
%   H = drawEllipse3d(...)
%   return handle on the created LINE object
%   
%   Example
%     figure; axis([-10 10 -10 10 -10 10]); hold on;
%     ellXY = [0 0 0  8 5  0 0 0];
%     drawEllipse3d(ellXY, 'color', [.8 0 0], 'linewidth', 2)
%     ellXZ = [0 0 0  8 2  90 90 90];
%     drawEllipse3d(ellXZ, 'color', [0 .8 0], 'linewidth', 2)
%     ellYZ = [0 0 0  5 2  90 0 90];
%     drawEllipse3d(ellYZ, 'color', [0 0 .8], 'linewidth', 2)
% 
 
%   ------
%   Author: David Legland
%   e-mail: david.legland@inra.fr
%   Created: 2008-05-07
%   Copyright 2008 INRA - CEPIA Nantes - MIAJ (Jouy-en-Josas).

%   HISTORY

%   Possible calls for the function, with number of arguments :
%   drawEllipse3d([XC YC ZC A B THETA PHI])             1
%   drawEllipse3d([XC YC ZC A B THETA PHI PSI])         1
%   drawEllipse3d([XC YC ZC A B], [THETA PHI])          2
%   drawEllipse3d([XC YC ZC A B], [THETA PHI PSI])      2
%   drawEllipse3d([XC YC ZC A B], THETA, PHI)           3
%   drawEllipse3d([XC YC ZC A B], THETA, PHI, PSI)      4
%   drawEllipse3d([XC YC ZC], A, B, THETA, PHI)         5
%   drawEllipse3d([XC YC ZC], A, B, THETA, PHI, PSI)    6
%   drawEllipse3d(XC, YC, ZC, A, B, THETA, PHI)         7
%   drawEllipse3d(XC, YC, ZC, A, B, THETA, PHI, PSI)    8


% extract drawing options
ind = find(cellfun(@ischar, varargin), 1, 'first');
options = {};
if ~isempty(ind)
    options = varargin(ind:end);
    varargin(ind:end) = [];
end

if length(varargin)==1
    % get center and radius
    ellipse = varargin{1};
    xc = ellipse(:,1);
    yc = ellipse(:,2);
    zc = ellipse(:,3);
    a  = ellipse(:,4);
    b  = ellipse(:,5);
    
    % get colatitude of normal
    if size(ellipse, 2)>=6
        theta = ellipse(:,6);
    else
        theta = zeros(size(ellipse, 1), 1);
    end

    % get azimut of normal
    if size(ellipse, 2)>=7
        phi     = ellipse(:,7);
    else
        phi = zeros(size(ellipse, 1), 1);
    end
    
    % get roll
    if size(ellipse, 2)==8
        psi = ellipse(:,8);
    else
        psi = zeros(size(ellipse, 1), 1);
    end
    
elseif length(varargin)==2
    % get center and radius
    ellipse = varargin{1};
    xc = ellipse(:,1);
    yc = ellipse(:,2);
    zc = ellipse(:,3);
    a  = ellipse(:,4);
    b  = ellipse(:,5);
    
    % get angle of normal
    angle = varargin{2};
    theta   = angle(:,1);
    phi     = angle(:,2);
    
    % get roll
    if size(angle, 2)==3
        psi = angle(:,3);
    else
        psi = zeros(size(angle, 1), 1);
    end

elseif length(varargin)==3    
    % get center and radius
    ellipse = varargin{1};
    xc = ellipse(:,1);
    yc = ellipse(:,2);
    zc = ellipse(:,3);
    a  = ellipse(:,4);
    b  = ellipse(:,5);
    
    % get angle of normal and roll
    theta   = varargin{2};
    phi     = varargin{3};
    psi     = zeros(size(phi, 1), 1);
    
elseif length(varargin)==4
    % get center and radius
    ellipse = varargin{1};
    xc = ellipse(:,1);
    yc = ellipse(:,2);
    zc = ellipse(:,3);
    
    if size(ellipse, 2)==5
        a  = ellipse(:,4);
        b  = ellipse(:,5);
    end
    
    theta   = varargin{2};
    phi     = varargin{3};
    psi     = varargin{4};
    
elseif length(varargin)==5
    % get center and radius
    ellipse = varargin{1};
    xc      = ellipse(:,1);
    yc      = ellipse(:,2);
    zc      = ellipse(:,3);
    a       = varargin{2};
    b       = varargin{3};
    theta   = varargin{4};
    phi     = varargin{5};
    psi     = zeros(size(phi, 1), 1);

elseif length(varargin)==6
    ellipse = varargin{1};
    xc      = ellipse(:,1);
    yc      = ellipse(:,2);
    zc      = ellipse(:,3);
    a       = varargin{2};
    b       = varargin{3};
    theta   = varargin{4};
    phi     = varargin{5};
    psi     = varargin{6};
  
elseif length(varargin)==7   
    xc      = varargin{1};
    yc      = varargin{2};
    zc      = varargin{3};
    a       = varargin{4};
    b       = varargin{5};
    theta   = varargin{6};
    phi     = varargin{7};
    psi     = zeros(size(phi, 1), 1);
    
elseif length(varargin)==8   
    xc      = varargin{1};
    yc      = varargin{2};
    zc      = varargin{3};
    a       = varargin{4};
    b       = varargin{5};
    theta   = varargin{6};
    phi     = varargin{7};
    psi     = varargin{8};

else
    error('drawEllipse3d: please specify center and radius');
end

% uses 60 intervals
t = linspace(0, 2*pi, 61)';

% polyline approximation of ellipse, centered and parallel to main axes
x       = a * cos(t);
y       = b * sin(t);
z       = zeros(length(t), 1);
base    = [x y z];

% compute transformation from local basis to world basis
trans   = localToGlobal3d(xc, yc, zc, theta, phi, psi);

% transform points composing the ellipse
ellipse = transformPoint3d(base, trans);

% draw the curve
h = drawPolyline3d(ellipse, options{:});

if nargout > 0
    varargout = {h};
end

