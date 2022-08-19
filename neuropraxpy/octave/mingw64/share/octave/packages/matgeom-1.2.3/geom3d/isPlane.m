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

function d = isPlane(plane)
%ISPLANE Check if input is a plane.
%
%   B = isPlane(PLANE) where PLANE should be a plane or multiple planes
%
%   Example
%     isPlane([...
%         0 0 0 1 0 0 0 1 0;...
%         0 0 0 1 0 0 -1 0 0;...
%         0 0 0 1i 0 0 -1 0 0;...
%         0 0 0 nan 0 0 0 1 0;...
%         0 0 0 inf 0 0 0 1 0])
%
%   See also
%   createPlane3d
%
% ------
% Author: oqilipo
% Created: 2017-07-09
% Copyright 2017

narginchk(1,1)

if size(plane,2)~=9
    d=false(size(plane,1),1);
    return
end

a = ~any(isnan(plane),2);
b = ~any(isinf(plane),2);
c = ~isParallel3d(plane(:,4:6), plane(:,7:9));

d = a & b & c;

end
