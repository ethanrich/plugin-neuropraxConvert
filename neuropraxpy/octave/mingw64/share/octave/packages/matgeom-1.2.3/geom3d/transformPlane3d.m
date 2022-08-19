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

function plane2 = transformPlane3d(plane, trans)
%TRANSFORMPLANE3D Transform a 3D plane with a 3D affine transform.
%
%   PLANE2 = transformPlane3d(PLANE, TRANS)
%
%   Example
%     p1 = [10 20 30];
%     p2 = [30 40 50];
%     p3 = [0 -10 -20];
%     plane = createPlane(p1, p2, p3);
%     rot = createRotationOx(p1, pi/6);
%     plane2 = transformPlane3d(plane, rot);
%     figure; hold on;
%     axis([0 100 0 100 0 100]); view(3);
%     drawPlane3d(plane, 'b');
%     drawPlane3d(plane2, 'm');
%
%   See also:
%   lines3d, transforms3d, transformPoint3d, transformVector3d,
%   transformLine3d
%

% ------
% Author: David Legland, oqilipo
% e-mail: david.legland@inra.fr
% Created: 2017-07-09
% Copyright 2017 INRA - BIA PV Nantes - MIAJ Jouy-en-Josas.

plane2 = [...
    transformPoint3d( plane(:,1:3), trans) ...  % transform origin point
    transformVector3d(plane(:,4:6), trans) ...  % transform 1st dir. vect.
    transformVector3d(plane(:,7:9), trans)];    % transform 2nd dir. vect.
