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

function transforms2d(varargin)
%TRANSFORMS2D Description of functions operating on transforms.
%
%   By 'transform' we mean an affine transform. A planar affine transform
%   can be represented by a 3x3 matrix.
%
%   Example
%     % create a translation by the vector [10 20]:
%     T = createTranslation([10 20])
%     T =
%          1     0    10
%          0     1    20
%          0     0     1
%
%     % apply a rotation on a polygon
%     poly = [0 0; 30 0;30 10;10 10;10 20;0 20];
%     trans = createRotation([10 20], pi/6);
%     polyT = transformPoint(poly, trans);
%     % display the original and the rotated polygons
%     figure; hold on; axis equal; axis([-10 40 -10 40]);
%     drawPolygon(poly, 'k');
%     drawPolygon(polyT, 'b');
%
%
%   See also:
%   createTranslation, createRotation, createRotation90, createScaling
%   createHomothecy, createLineReflection, createBasisTransform
%   transformPoint, transformVector, transformLine, transformEdge
%   rotateVector, principalAxesTransform, fitAffineTransform2d
%   polynomialTransform2d, fitPolynomialTransform2d


% ------
% Author: David Legland
% e-mail: david.legland@inra.fr
% Created: 2008-10-13,    using Matlab 7.4.0.287 (R2007a)
% Copyright 2008 INRA - BIA PV Nantes - MIAJ Jouy-en-Josas.

help('transforms2d');
