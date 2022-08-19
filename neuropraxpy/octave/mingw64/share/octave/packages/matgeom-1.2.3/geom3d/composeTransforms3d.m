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

function trans = composeTransforms3d(varargin)
%COMPOSETRANSFORMS3D Concatenate several space transformations.
%
%   TRANS = composeTransforms3d(TRANS1, TRANS2, ...);
%   Computes the affine transform equivalent to performing successively
%   TRANS1, TRANS2, ...
%   
%   Example:
%   PTS  = rand(20, 3);
%   ROT1 = createRotationOx(pi/3);
%   ROT2 = createRotationOy(pi/4);
%   ROT3 = createRotationOz(pi/5);
%   ROTS = composeTransforms3d(ROT1, ROT2, ROT3);
%   Then:
%   PTS2 = transformPoint3d(PTS, ROTS);
%   will give the same result as:
%   PTS3 = transformPoint3d(transformPoint3d(transformPoint3d(PTS, ...
%       ROT1), ROT2), ROT3);
%
%   See also:
%   transforms3d, transformPoint3d
%
%   ---------
%
%   author : David Legland 
%   INRA - TPV URPOI - BIA IMASTE
%   created the 29/29/2006.
%

trans = varargin{nargin};
for i=length(varargin)-1:-1:1
    trans = trans * varargin{i};
end
