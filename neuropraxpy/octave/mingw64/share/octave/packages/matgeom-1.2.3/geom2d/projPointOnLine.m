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

function point = projPointOnLine(point, line)
%PROJPOINTONLINE Project of a point orthogonally onto a line.
%
%   PT2 = projPointOnLine(PT, LINE).
%   Computes the (orthogonal) projection of point PT onto the line LINE.
%   
%   Function works also for multiple points and lines. In this case, it
%   returns multiple points.
%   Point PT1 is a [N*2] array, and LINE is a [N*4] array (see createLine
%   for details). Result PT2 is a [N*2] array, containing coordinates of
%   orthogonal projections of PT1 onto lines LINE.
%
%   Example
%     line = [0 2  2 1];
%     projPointOnLine([3 1], line)
%     ans = 
%          2   3
%
%   See also:
%   lines2d, points2d, isPointOnLine, linePosition
%
%   ---------
%   author : David Legland 
%   INRA - TPV URPOI - BIA IMASTE
%   created the 07/04/2005.
%

%   HISTORY
%   2005-08-06 correct bug when several points were passed as param.
%   2012-08-23 remove repmats

% direction vector of the line
vx = line(:, 3);
vy = line(:, 4);

% difference of point with line origin
dx = point(:,1) - line(:,1);
dy = point(:,2) - line(:,2);

% Position of projection on line, using dot product
tp = (dx .* vx + dy .* vy ) ./ (vx .* vx + vy .* vy);

% convert position on line to cartesian coordinates
point = [line(:,1) + tp .* vx, line(:,2) + tp .* vy];
