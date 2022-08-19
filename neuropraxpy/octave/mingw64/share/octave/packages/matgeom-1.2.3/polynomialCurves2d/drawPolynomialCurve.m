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

function varargout = drawPolynomialCurve(tBounds, varargin)
%DRAWPOLYNOMIALCURVE Draw a polynomial curve approximation.
%
%   Usage
%   drawPolynomialCurve(BND, XCOEFS, YCOEFS)
%   drawPolynomialCurve(BND, XCOEFS, YCOEFS, NPTS)
%
%   Example
%   drawPolynomialCurve
%
%   See also
%
%
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2011-03-21,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2011 INRA - Cepia Software Platform.


%% Extract input parameters

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
    varargin(1:2) = [];
    
else
    xCoef = var(1,:);
    yCoef = var(2,:);
    varargin(1) = [];
end

nPts = 120;
if ~isempty(varargin)
    nPts = varargin{1};
end


%% Drawing the polyline approximation

% generate vector of absissa
t = linspace(t0, t1, nPts+1)';

% compute corresponding positions
pts = polynomialCurvePoint(t, xCoef, yCoef);

% draw the resulting curve
h = drawPolyline(pts);

if nargout > 0
    varargout = {h};
end
