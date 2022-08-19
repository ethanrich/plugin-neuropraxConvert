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

function TFM = createRotationAboutPoint3d(ROT, point)
%CREATEROTATIONABOUTPOINT3D Rotate about a point using a rotation matrix.
%
%   TFM = createRotationAboutPoint3d(ROT, POINT) Returns the transformation 
%   matrix corresponding to a translation(-POINT), rotation with ROT and 
%   translation(POINT). Ignores a possible translation in ROT(1:3,4).
%
%   See also:
%   transforms3d, transformPoint3d, createRotationOx, createRotationOy, 
%   createRotationOz, createRotation3dLineAngle, createRotationVector3d,
%   createRotationVectorPoint3d
%
% ---------
% Author: oqilipo
% Created: 2021-01-31
% Copyright 2021

% Extract only the rotation
ROT = [ROT(1:3,1:3), [0 0 0]'; [0 0 0 1]];

TFM = createTranslation3d(point) * ROT * createTranslation3d(-point);

end
    

