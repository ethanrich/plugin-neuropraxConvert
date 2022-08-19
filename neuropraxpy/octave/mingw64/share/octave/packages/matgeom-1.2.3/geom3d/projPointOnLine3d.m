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

function point = projPointOnLine3d(point, line)
%PROJPOINTONLINE3D Project a 3D point orthogonally onto a 3D line.
%
%   PT2 = projPointOnLine3d(PT, LINE).
%   Computes the (orthogonal) projection of 3D point PT onto the 3D line
%   LINE. 
%   
%   Function works also for multiple points and lines. In this case, it
%   returns multiple points.
%   Point PT1 is a N-by-3 array, and LINE is a N-by-6 array.
%   Result PT2 is a N-by-3 array, containing coordinates of orthogonal
%   projections of PT1 onto lines LINE. 
%
%
%   See also:
%   projPointOnLine, distancePointLine3d
%
%   ---------
%   author : David Legland 
%   INRA - TPV URPOI - BIA IMASTE
%   created the 2012-08-23.
%

%   HISTORY

% direction vector of the line
vx = line(:, 4);
vy = line(:, 5);
vz = line(:, 6);

% difference of point with line origin
dx = point(:,1) - line(:,1);
dy = point(:,2) - line(:,2);
dz = point(:,3) - line(:,3);

% Position of projection on line, using dot product
delta = vx .* vx + vy .* vy + vz .* vz;
tp = (dx .* vx + dy .* vy + dz .* vz) ./ delta;

% convert position on line to cartesian coordinates
point = [line(:,1) + tp .* vx, line(:,2) + tp .* vy, line(:,3) + tp .* vz];
