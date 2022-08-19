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

function n = vectorNorm(v, varargin)
% Compute norm of a vector, or of a set of vectors.
%
%   N = vectorNorm(V);
%   Returns the euclidean norm of vector V.
%
%   N = vectorNorm(V, N);
%   Specifies the norm to use. N can be any value greater than 0. 
%   N=1 -> city lock norm
%   N=2 -> euclidean norm
%   N=inf -> compute max coord.
%
%   When V is a MxN array, compute norm for each vector of the array.
%   Vector are given as rows. Result is then a [M*1] array.
%
%   Example
%   n1 = vectorNorm([3 4])
%   n1 =
%       5
%
%   n2 = vectorNorm([1, 10], inf)
%   n2 =
%       10
%
%   See Also:
%     vectors2d, vectorAngle
%

%   ---------
%   author : David Legland 
%   INRA - TPV URPOI - BIA IMASTE
%   created the 21/02/2005.
%

%   HISTORY
%   02/05/2006 manage several norms
%   18/09/2007 use 'isempty'
%   15/10/2008 add comments
%   22/05/2009 rename as vectorNorm
%   01/03/2010 fix bug for inf norm
%   03/01/2020 make it work for more dimensions

% extract the type of norm to compute
d = 2;
if ~isempty(varargin)
    d = varargin{1};
end

if d==2
    % euclidean norm: sum of squared coordinates, and take square root
    n = sqrt(sum(v.*v, ndims(v)));
    
elseif d==1 
    % absolute norm: sum of absolute coordinates
    n = sum(abs(v), ndims(v));

elseif d==inf
    % infinite norm: uses the maximal corodinate
    n = max(v, [], ndims(v));

else
    % Other norms, use explicit but slower expression  
    n = power(sum(power(v, d), ndims(v)), 1/d);
    
end
