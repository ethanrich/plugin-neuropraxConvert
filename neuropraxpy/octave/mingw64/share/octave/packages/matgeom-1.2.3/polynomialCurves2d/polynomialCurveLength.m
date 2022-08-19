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

function L = polynomialCurveLength(tBounds, varargin)
%POLYNOMIALCURVELENGTH Compute the length of a polynomial curve.
%
%   LENGTH = polynomialCurveLength(T, XCOEF, YCOEF)
%   XCOEF and YCOEF are row vectors of coefficients, in the form:
%       [a0 a1 a2 ... an]
%   T is a 1x2 row vector, containing the bounds of the parametrization
%   variable: T = [T0 T1], with T taking all values between T0 and T1.
%
%   LENGTH = polynomialCurveLength(T, COEFS)
%   COEFS is either a 2xN matrix (one row for the coefficients of each
%   coordinate), or a cell array.
%
%   LENGTH = polynomialCurveLength(..., TOL)
%   TOL is the tolerance fo computation (absolute).
%
%   Example
%   polynomialCurveLength
%
%   See also
%   polynomialCurves2d, polynomialCurveCentroid
%
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2007-02-23
% Copyright 2007 INRA - BIA PV Nantes - MIAJ Jouy-en-Josas.

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
    varargin(1:2)=[];
else
    xCoef = var(1,:);
    yCoef = var(2,:);
    varargin(1)=[];
end
    
% tolerance
tol = 1e-6;
if ~isempty(varargin)
    tol = varargin{1};
end

%% compute length by numerical integration

% compute derivative of the polynomial
dx = polynomialDerivate(xCoef);
dy = polynomialDerivate(yCoef);

% convert to polyval format
dx = dx(end:-1:1);
dy = dy(end:-1:1);

% numerical integration of the Jacobian of parametrized curve
if verLessThan('matlab', '7.14')
    L = quad(@(t)sqrt(polyval(dx, t).^2+polyval(dy, t).^2), t0, t1, tol); %#ok<DQUAD>
else
    L = integral(@(t)sqrt(polyval(dx, t).^2+polyval(dy, t).^2), ...
        t0, t1, 'AbsTol', tol);
end
