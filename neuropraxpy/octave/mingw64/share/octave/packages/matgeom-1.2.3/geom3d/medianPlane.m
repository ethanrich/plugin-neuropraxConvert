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

function plane = medianPlane(p1, p2)
%MEDIANPLANE Create a plane in the middle of 2 points.
%
%   PLANE = medianPlane(P1, P2)
%   Creates a plane in the middle of 2 points.
%   PLANE is perpendicular to line (P1 P2) and contains the midpoint of P1
%   and P2.
%   The direction of the normal of PLANE is the same as the vector from P1
%   to P2.
%
%   See also:
%   planes3d, createPlane
%
%   ---------
%   author : David Legland 
%   INRA - TPV URPOI - BIA IMASTE
%   created the 18/02/2005.
%

%   HISTORY
%   28/06/2007: add doc, and manage multiple inputs

% unify data dimension
if size(p1, 1)==1
    p1 = repmat(p1, [size(p2, 1) 1]);
elseif size(p2, 1)==1
    p2 = repmat(p2, [size(p1, 1) 1]);
elseif size(p1, 1)~=size(p2, 1)    
    error('data should have same length, or one data should have length 1');
end

% middle point
p0  = (p1 + p2)/2;

% normal to plane
n   = p2-p1;

% create plane from point and normal
plane = createPlane(p0, n);
