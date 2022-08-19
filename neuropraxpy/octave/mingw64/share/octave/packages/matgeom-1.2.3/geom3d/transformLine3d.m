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

function res = transformLine3d(line, trans)
%TRANSFORMLINE3D Transform a 3D line with a 3D affine transform.
%
%   LINE2 = transformLine3d(LINE1, TRANS)
%
%   Example
%   P1 = [10 20 30];
%   P2 = [30 40 50];
%   L = createLine3d(P1, P2);
%   T = createRotationOx(P1, pi/6);
%   L2 = transformLine3d(L, T);
%   figure; hold on;
%   axis([0 100 0 100 0 100]); view(3);
%   drawPoint3d([P1;P2]);
%   drawLine3d(L, 'b');
%   drawLine3d(L2, 'm');
%
%   See also:
%   lines3d, transforms3d, transformPoint3d, transformVector3d
%
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2008-11-25,    using Matlab 7.7.0.471 (R2008b)
% Copyright 2008 INRA - BIA PV Nantes - MIAJ Jouy-en-Josas.

res = [...
    transformPoint3d(line(:, 1:3), trans) ...   % transform origin point
    transformVector3d(line(:,4:6), trans)];     % transform direction vect.
