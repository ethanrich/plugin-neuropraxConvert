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

function b = isPerpendicular3d(v1, v2, varargin)
%ISPERPENDICULAR3D Check orthogonality of two 3D vectors.
%
%   B = isPerpendicular3d(V1, V2)
%   where V1 and V2 are 2 [1x3] arrays, returns 1 if the vectors are
%   orthogonal, and 0 otherwise.
%
%   Also works when V1 and V2 are two [Nx3] arrays with same number of
%   rows. In this case, return a [Nx1] array containing 1 at the positions
%   of parallel vectors.
%
%   Also works when one of V1 or V2 is scalar and the other one is [Nx3]
%   array, in this case return [Nx1] results.
%
%   B = isPerpendicular3d(V1, V2, TOL)
%   Specifies the absolute tolerance (default is 1e-14).
%
%
%   Example
%   isPerpendicular3d([1 0 0], [0 1 0])
%   ans =
%       1
%
%   isPerpendicular3d([1 0 1], [1 0 0])
%   ans =
%       0
%
%   See also
%   vectors3d, isParallel3d
%
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2006-04-25
% Copyright 2006 INRA - CEPIA Nantes - MIAJ (Jouy-en-Josas).

% 2011.03.20 add support for tolerance, fix computation

% check if tolerance is specified
tol = 1e-14;
if ~isempty(varargin)
    tol = varargin{1};
end

% compute perpendicularity test
b = abs(sum(bsxfun(@times, v1, v2), 2)) < tol;
