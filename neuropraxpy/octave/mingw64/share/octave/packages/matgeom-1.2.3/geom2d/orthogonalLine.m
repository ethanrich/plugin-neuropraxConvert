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

function res = orthogonalLine(line, point)
%ORTHOGONALLINE Create a line orthogonal to another one through a point.
%
%   PERP = orthogonalLine(LINE, POINT);
%   Returns the line orthogonal to the line LINE and going through the
%   point given by POINT. Directed angle from LINE to PERP is pi/2.
%   LINE is given as [x0 y0 dx dy] and POINT is [xp yp].
%
%   Works also when LINE is a N-by-4 array, or POINT is a N-by-2 array. In
%   this case, the result is a N-by-4 array.
%
%
% Example
%     refLine = createLine([10 10], [30 20]);
%     pt = [20 40];
%     figure; hold on; axis equal; axis([0 50 0 50]);
%     drawLine(refLine, 'lineWidth', 2);
%     drawPoint(pt);
%     perp = orthogonalLine(refLine, pt);
%     drawLine(perp, 'color', 'r');
% 
%   See also:
%   lines2d, parallelLine, intersectLines
%
%   ---------
%   author : David Legland 
%   INRA - TPV URPOI - BIA IMASTE
%   created the 31/10/2003.
%

%   HISTORY
%   19/02/2004 added control for multiple lines and/or points
%   31/12/2013 added example

N = max(size(point, 1), size(line, 1));

if size(point, 1)>1
    res = point;
else
    res = ones(N, 1)*point;
end

if size(line, 1)>1
    res(:,3) = -line(:,4);
    res(:,4) = line(:,3);
else
    res(:,3) = -ones(N,1)*line(4);
    res(:,4) = ones(N,1)*line(3);
end

