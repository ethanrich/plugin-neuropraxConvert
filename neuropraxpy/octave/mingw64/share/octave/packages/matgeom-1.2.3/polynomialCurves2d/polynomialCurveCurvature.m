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

function kappa = polynomialCurveCurvature(t, varargin)
%POLYNOMIALCURVECURVATURE Compute the local curvature of a polynomial curve.
%
%   KAPPA = polynomialCurveCurvature(T, XCOEF, YCOEF)
%   XCOEF and YCOEF are row vectors of coefficients, in the form:
%       [a0 a1 a2 ... an]
%   KAPPA is the local curvature of the polynomial curve, computed for
%   position T. If T is a vector, KAPPA has the same length as T.
%
%   KAPPA = polynomialCurveCurvature(T, COEFS)
%   COEFS is either a 2xN matrix (one row for the coefficients of each
%   coordinate), or a cell array.
%
%   Example
%   polynomialCurveCurvature
%
%   See also
%   polynomialCurves2d, polynomialCurveLength, polynomialCurveDerivative
%
%
% ------
% Author: David Legland
% e-mail: david.legland@nantes.inra.fr
% Created: 2007-02-23
% Copyright 2007 INRA - BIA PV Nantes - MIAJ Jouy-en-Josas.

%% Extract input parameters

% polynomial coefficients for each coordinate
var = varargin{1};
if iscell(var)
    xCoef = var{1};
    yCoef = var{2};
elseif size(var, 1)==1
    xCoef = varargin{1};
    yCoef = varargin{2};
else
    xCoef = var(1,:);
    yCoef = var(2,:);
end
    

%% compute derivative

% compute first derivatives of the polynomials
dx  = polynomialDerivate(xCoef);
dy  = polynomialDerivate(yCoef);

% compute second derivatives
sx  = polynomialDerivate(dx);
sy  = polynomialDerivate(dy);

% convert to polyval convention
dx  = dx(end:-1:1);
dy  = dy(end:-1:1);
sx  = sx(end:-1:1);
sy  = sy(end:-1:1);

% compute local first and second derivatives
xp  = polyval(dx, t);
yp  = polyval(dy, t);
xs  = polyval(sx, t);
ys  = polyval(sy, t);

% compute local curvature of polynomial curve
kappa  = (xp.*ys - xs.*yp) ./ power(xp.*xp + yp.*yp, 3/2);

