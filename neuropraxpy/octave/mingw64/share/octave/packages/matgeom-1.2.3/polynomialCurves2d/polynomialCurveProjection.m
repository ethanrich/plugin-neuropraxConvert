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

function pos = polynomialCurveProjection(tBounds, varargin)
%POLYNOMIALCURVEPROJECTION Projection of a point on a polynomial curve.
%
%   T = polynomialCurveProjection([T0 T1], XCOEFS, YCOEFS, POINT); 
%   Computes the position of POINT on the polynomial curve, such that 
%   polynomialCurvePoint([T0 T1], XCOEFS, YCOEFS) is the same as POINT.
%
%   See also
%   polynomialCurves2d, polynomialCurvePoint
%
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2007-12-21
% Copyright 2007 INRA - BIA PV Nantes - MIAJ Jouy-en-Josas.

% parametrization bounds
t0 = tBounds(1);
t1 = tBounds(end);

% polynomial coefficients for each coordinate
var = varargin{1};
if iscell(var)
    xCoef = var{1};
    yCoef = var{2};
    varargin(1) = [];
elseif size(var, 1)==1
    xCoef = varargin{1};
    yCoef = varargin{2};
    varargin(1:2)=[];
else
    xCoef = var(1,:);
    yCoef = var(2,:);
    varargin(1)=[];
end


% the point to project
point = varargin{1};
varargin(1)=[];

% tolerance
tol = 1e-6;
if ~isempty(varargin)
    tol = varargin{1};
end

% update coefficient according to point position
xCoef(1) = xCoef(1) - point(1);
yCoef(1) = yCoef(1) - point(2);

% convert to format of polyval
c1 = xCoef(end:-1:1);
c2 = yCoef(end:-1:1);

% avoid warning for t=0
warning off 'MATLAB:quad:MinStepSize'

% set up precision for t
options = optimset('TolX', tol^2);

% compute minimisation of the distance function
pos = fminbnd(@(t) polyval(c1, t).^2+polyval(c2, t).^2, t0, t1, options);
