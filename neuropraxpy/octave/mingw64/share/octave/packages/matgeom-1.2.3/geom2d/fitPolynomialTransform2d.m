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

function coeffs = fitPolynomialTransform2d(pts, ptsRef, degree)
%FITPOLYNOMIALTRANSFORM2D Coefficients of polynomial transform between two point sets.
%
%   COEFFS = fitPolynomialTransform2d(PTS, PTSREF, DEGREE)
%
%   Example
%  
%   See also
%     polynomialTransform2d, fitAffineTransform2d

% ------
% Author: David Legland
% e-mail: david.legland@nantes.inra.fr
% Created: 2013-11-05,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2013 INRA - Cepia Software Platform.


%% Extract data

% ensure degree is valid
if nargin < 3
    degree = 3;
end

% polygon coordinates
xi = pts(:,1);
yi = pts(:,2);
nCoords = size(pts, 1);

% check inputs have same size
if size(ptsRef, 1) ~= nCoords
    error('fitPolynomialTransform2d:sizeError', ...
        'input arrays must have same number of points');
end
    

%% compute coefficient matrix

% number of coefficients of polynomial transform
nCoeffs = prod(degree + [1 2]) / 2;

% initialize matrix
A1 = zeros(nCoords, nCoeffs);

% iterate over degrees
iCoeff = 0;
for iDegree = 0:degree
    
    % iterate over binomial coefficients of a given degree
    for k = 0:iDegree
        iCoeff = iCoeff + 1;
        A1(:, iCoeff) = ones(nCoords, 1) .* power(xi, iDegree-k) .* power(yi, k);
    end
end

% concatenate matrix for both coordinates
A = kron(A1, [1 0;0 1]);


%% solve linear system that minimizes least squares

% create the vector of expected values
b = ptsRef';
b = b(:);

% solve the system
coeffs = (A \ b)';


