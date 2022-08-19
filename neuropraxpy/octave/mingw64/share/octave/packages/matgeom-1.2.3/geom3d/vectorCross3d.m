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

function c = vectorCross3d(a,b)
%VECTORCROSS3D Vector cross product faster than inbuilt MATLAB cross.
%
%   C = vectorCross3d(A, B) 
%   returns the cross product of the 3D vectors A and B, that is: 
%       C = A x B
%   A and B must be N-by-3 element vectors. If either A or B is a 1-by-3
%   row vector, the result C will have the size of the other input and will
%   be the  concatenation of each row's cross product. 
%
%   Example
%     v1 = [2 0 0];
%     v2 = [0 3 0];
%     vectorCross3d(v1, v2)
%     ans =
%         0   0   6
%
%
%   Class support for inputs A,B:
%      float: double, single
%
%   See also DOT.

%   Sven Holcombe

% needed_colons = max([3, length(size(a)), length(size(b))]) - 3;
% tmp_colon = {':'};
% clnSet = tmp_colon(ones(1, needed_colons));
% 
% c = bsxfun(@times, a(:,[2 3 1],clnSet{:}), b(:,[3 1 2],clnSet{:})) - ...
%     bsxfun(@times, b(:,[2 3 1],clnSet{:}), a(:,[3 1 2],clnSet{:}));

% deprecation warning
warning('geom3d:deprecated', ...
    [mfilename ' is deprecated, use ''crossProduct3d'' instead']);

sza = size(a);
szb = size(b);

% Initialise c to the size of a or b, whichever has more dimensions. If
% they have the same dimensions, initialise to the larger of the two
switch sign(numel(sza) - numel(szb))
    case 1
        c = zeros(sza);
    case -1
        c = zeros(szb);
    otherwise
        c = zeros(max(sza, szb));
end

c(:) =  bsxfun(@times, a(:,[2 3 1],:), b(:,[3 1 2],:)) - ...
        bsxfun(@times, b(:,[2 3 1],:), a(:,[3 1 2],:));
