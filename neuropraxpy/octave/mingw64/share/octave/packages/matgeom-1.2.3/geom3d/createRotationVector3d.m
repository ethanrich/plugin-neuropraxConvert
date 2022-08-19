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

function ROT = createRotationVector3d(A,B)
%CREATEROTATIONVECTOR3D Calculates the rotation between two vectors.
%
%   ROT = createRotationVector3d(A, B) returns the 4x4 rotation matrix ROT
%   to transform vector A in the same direction as vector B.
%
%   Example
%     A=[ .1  .2  .3];
%     B=-1+2.*rand(1,3);
%     ROT = createRotationVector3d(A,B);
%     C = transformVector3d(A,ROT);
%     figure('color','w'); hold on; view(3)
%     O=[0 0 0];
%     drawVector3d(O, A,'r');
%     drawVector3d(O, B,'g');
%     drawVector3d(O, C,'r');
%
%   See also
%   transformPoint3d, createRotationOx, createRotationOy, createRotationOz
%
%   Source
%     https://math.stackexchange.com/a/897677
%
% ---------
% Author: oqilipo
% Created: 2017-08-07
% Copyright 2017

if isParallel3d(A,B)
    if A*B'>0
        ROT = eye(4);
    else
        ROT = -1*eye(4); ROT(end)=1;
    end
else
    a=normalizeVector3d(A);
    b=normalizeVector3d(B);
    a=reshape(a,3,1);
    b=reshape(b,3,1);
    
    v = cross(a,b);
    ssc = [0 -v(3) v(2); v(3) 0 -v(1); -v(2) v(1) 0];
    ROT = eye(3) + ssc + ssc^2*(1-dot(a,b))/(norm(v))^2;
    
    ROT = [ROT, [0;0;0]; 0 0 0 1];
end

end
