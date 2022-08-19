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

function TFM = createRotationVectorPoint3d(A,B,P)
%CREATEROTATIONVECTORPOINT3D Calculates the rotation between two vectors.
%   around a point
%   
%   TFM = createRotationVectorPoint3d(A,B,P) returns the transformation 
%   to rotate the vector A in the direction of vector B around point P
%   
%   Example
%     A=-5+10.*rand(1,3);
%     B=-10+20.*rand(1,3);
%     P=-50+100.*rand(1,3);
%     ROT = createRotationVectorPoint3d(A,B,P);
%     C = transformVector3d(A,ROT);
%     figure('color','w'); hold on; view(3)
%     drawPoint3d(P,'k')
%     drawVector3d(P, A,'r')
%     drawVector3d(P, B,'g')
%     drawVector3d(P, C,'r')
%
%   See also
%   transformPoint3d, createRotationVector3d
%
% ---------
% Author: oqilipo
% Created: 2017-08-07
% Copyright 2017

P = reshape(P,3,1);

% Translation from P to origin
invtrans = [eye(3),-P; [0 0 0 1]];

% Rotation from A to B
rot = createRotationVector3d(A, B);

% Translation from origin to P
trans = [eye(3),P; [0 0 0 1]];

% Combine
TFM = trans*rot*invtrans;

end
