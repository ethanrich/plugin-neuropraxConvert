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

function v = polynomialCurveNormal(t, varargin)
%POLYNOMIALCURVENORMAL Compute the normal of a polynomial curve.
%
%   N = polynomialCurveNormal(T, XCOEF, YCOEF)
%   XCOEF and YCOEF are row vectors of coefficients, in the form:
%       [a0 a1 a2 ... an]
%   T is a 1x2 row vector, containing the bounds of the parametrization
%   variable: T = [T0 T1], with T taking all values between T0 and T1.
%   T can also be a larger vector, in this case only bounds are kept.
%   N is a 1x2 row vector, containing direction of curve normal in T.
%   If T is column vector, the result is a matrix with 2 columns containing
%   normal vector for each position.
%
%   The normal is oriented such that oriented angle from derivative
%   vector to normal vector equals PI/2. The normal points to the 'left'
%   when travelling along the curve.

%   N = polynomialCurveNormal(T, COEFS)
%   COEFS is either a 2xN matrix (one row for the coefficients of each
%   coordinate), or a cell array.
%
%   N = polynomialCurveNormal(..., TOL)
%   TOL is the tolerance fo computation (absolute).
%
%   Example
%   polynomialCurveNormal
%
%   See also
%   polynomialCurves2d, polynomialCurveDerivative
%
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2007-02-23
% Copyright 2007 INRA - BIA PV Nantes - MIAJ Jouy-en-Josas.

% extract the derivative
v = polynomialCurveDerivative(t, varargin{:});

% rotate by PI/2 Counter clockwise
v = [-v(:,2) v(:,1)];
