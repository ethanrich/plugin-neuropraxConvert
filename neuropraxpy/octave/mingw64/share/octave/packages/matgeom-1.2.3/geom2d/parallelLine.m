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

function res = parallelLine(line, point)
%PARALLELLINE Create a line parallel to another one.
%
%   RES = parallelLine(LINE, POINT);
%   Returns the line with same direction vector than LINE and going through
%   the point given by POINT. 
%   LINE is given as [x0 y0 dx dy] and POINT is [xp yp].
%
%
%   RES = parallelLine(LINE, DIST);
%   Uses relative distance to specify position. The new line will be
%   located at distance DIST, counted positive in the right side of LINE
%   and negative in the left side.
%
%   Examples
%     P1 = [20 30]; P2 = [50 10];
%     L1 = createLine([50 10], [20 30]);
%     figure; hold on; axis equal; axis([0 60 0 50]);
%     drawPoint([P1; P2], 'ko');
%     drawLine(L1, 'k');
%     P = [30 40];
%     drawPoint(P, 'ko');
%     L2 = parallelLine(L1, P);
%     drawLine(L2, 'Color', 'b');
%
%   See also:
%   lines2d, orthogonalLine, distancePointLine, parallelEdge
%
%   ---------
%
%   author : David Legland 
%   INRA - TPV URPOI - BIA IMASTE
%   created the 31/10/2003.
%

%   HISTORY
%   31/07/2005 add usage of distance
%   15/06/2009 change convention for distance sign
%   31/09/2012 adapt for multiple lines

if size(point, 2) == 1
    % use a distance. Compute position of point located at distance DIST on
    % the line orthogonal to the first one.
    point = pointOnLine([line(:,1) line(:,2) line(:,4) -line(:,3)], point);
end

% normal case: compute line through a point with given direction
res = zeros(size(line, 1), 4);
res(:, 1:2) = point;
res(:, 3:4) = line(:, 3:4);
