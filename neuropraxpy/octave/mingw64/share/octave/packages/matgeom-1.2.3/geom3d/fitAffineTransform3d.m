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

function trans = fitAffineTransform3d(ref, src)
% Compute the affine transform that best register two 3D point sets.
%
%   TRANS = fitAffineTransform3d(REF, SRC)
%   Returns the affine transform matrix that minimizes the distance between
%   the reference point set REF and the point set SRC after transformation.
%   Both REF and SRC must by N-by-3 arrays with the same number of rows,
%   and the points must be in correspondence.
%   The function minimizes the sum of the squared distances:
%   CRIT = sum(distancePoints3d(REF, transformPoint3d(PTS, TRANSFO)).^2);
%
%   Example
%     N = 50;
%     pts = rand(N, 3)*10;
%     trans = createRotationOx([5 4 3], pi/4);
%     pts2 = transformPoint3d(pts, trans);
%     pts3 = pts2 + randn(N, 3)*2;
%     fitted = fitAffineTransform3d(pts, pts2);
%   
%
%   See also
%     transforms3d, transformPoint3d, transformVector3d,
%     fitAffineTransform2d, registerPoints3dAffine
%

% ------
% Author: David Legland
% e-mail: david.legland@inrae.fr
% Created: 2009-07-31,    using Matlab 7.7.0.471 (R2008b)
% Copyright 2009 INRAE - Cepia Software Platform.


% number of points 
N = size(src, 1);
if size(ref, 1) ~= N
    error('Requires the same number of points for both arrays');
end

% main matrix of the problem
tmp = [src(:,1) src(:,2) src(:,3) ones(N,1)];
A = [...
    tmp zeros(N, 8) ; ...
    zeros(N, 4) tmp zeros(N, 4) ; ...
    zeros(N, 8) tmp ];

% conditions initialisations
B = [ref(:,1) ; ref(:,2) ; ref(:,3)];

% compute coefficients using least square
coefs = A\B;

% format to a matrix
trans = [coefs(1:4)' ; coefs(5:8)'; coefs(9:12)'; 0 0 0 1];
