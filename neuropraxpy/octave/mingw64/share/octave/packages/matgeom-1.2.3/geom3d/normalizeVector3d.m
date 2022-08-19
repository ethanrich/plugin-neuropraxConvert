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

function vn = normalizeVector3d(v)
%NORMALIZEVECTOR3D Normalize a 3D vector to have norm equal to 1.
%
%   V2 = normalizeVector3d(V);
%   Returns the normalization of vector V, such that ||V|| = 1. Vector V is
%   given as a row vector.
%
%   If V is a N-by-3 array, normalization is performed for each row of the
%   input array.
%
%   If V is a M-by-N-by-3 array, normalization is performed along the last
%   dimension of the array.
%
%   See also:
%     vectors3d, vectorNorm3d
%

%   ---------
%   author : David Legland 
%   INRA - TPV URPOI - BIA IMASTE
%   created the 29/11/2004.
%

% HISTORY
% 2005-11-30 correct a bug
% 2009-06-19 rename as normalizeVector3d
% 2010-11-16 use bsxfun (Thanks to Sven Holcombe)

if ismatrix(v)
    vn = bsxfun(@rdivide, v, sqrt(sum(v.^2, 2)));
else
    vn = bsxfun(@rdivide, v, sqrt(sum(v.^2, ndims(v))));
end
