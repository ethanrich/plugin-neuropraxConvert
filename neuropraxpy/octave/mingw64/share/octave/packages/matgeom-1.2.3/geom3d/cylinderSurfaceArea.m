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

function S = cylinderSurfaceArea(cyl)
%CYLINDERSURFACEAREA  Surface area of a cylinder.
%
%   S = cylinderSurfaceArea(CYL)
%   Computes the surface area of the cylinder defined by:
%   CYL = [X1 Y1 Z1  X2 Y2 Z2  R], 
%   where [X1 Y1 Z1] and [X2 Y2 Z2] are the coordinates of the cylinder
%   extremities, and R is the cylinder radius.
%   The surface area of the cylinder comprises the surface area of the two
%   disk-shape end caps.
%
%   Example
%     cyl = [0 0 0  1 0 0  1];
%     cylinderSurfaceArea(cyl)
%     ans =
%        12.5664
%     % equals to 4*pi
%
%   See also
%     geom3d, ellipsoidSurfaceArea, intersectLineCylinder
 
% ------
% Author: David Legland
% e-mail: david.legland@inra.fr
% Created: 2017-11-02,    using Matlab 9.3.0.713579 (R2017b)
% Copyright 2017 INRA - Cepia Software Platform.

H = distancePoints3d(cyl(:, 1:3), cyl(:, 4:6));
R = cyl(:,7);

S1 = 2*pi*R .* H;
S2 = 2 * (pi * R.^2);

S = S1 + S2;
