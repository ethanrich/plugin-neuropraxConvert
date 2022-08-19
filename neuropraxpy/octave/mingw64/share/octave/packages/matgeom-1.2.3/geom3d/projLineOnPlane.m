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

function [newLine, isOrthogonal] = projLineOnPlane(line, plane)
%PROJLINEONPLANE Return the orthogonal projection of a line on a plane.
% 
%   NEWLINE = PROJLINEONPLANE(LINE, PLANE) Returns the orthogonal
%   projection of LINE or multiple lines on the PLANE.
%
%   [..., ISORTHOGONAL] = PROJLINEONPLANE(LINE, PLANE) Also returns if the
%   LINE is orthogonal to the PLANE.
%
%   Example
%     plane = [.1 .2 .3 .4 .5 .6 .7 .8 .9];
%     lines = [0 .3 0 1 0 0;0  .5 .5 0 0 1;...
%         .4 .1 .5 1 0 2;.2 .7 .1 0 1 0;...
%         plane(1:3) planeNormal(plane)];
%     [newLines, isOrthogonal] = projLineOnPlane(lines, plane);
%     figure('color','w'); axis equal; view(3)
%     drawLine3d(lines,'b')
%     drawPlane3d(plane)
%     drawLine3d(newLines(~isOrthogonal,:), 'r')
%
%   See also:
%   planes3d, lines3d, intersectLinePlane, projPointOnPlane
%
% ---------
% Author: oqilipo 
% Created: 2017-08-06
% Copyright 2017

p1 = projPointOnPlane(line(:,1:3), plane);
p2 = projPointOnPlane(line(:,1:3)+line(:,4:6), plane);

newLine=createLine3d(p1, p2);
isOrthogonal = ismembertol(p1,p2,'ByRows',true);


