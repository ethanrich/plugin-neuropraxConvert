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

function points = randomPointInBox(box, N, varargin)
%RANDOMPOINTINBOX Generate random point within a box.
%
%   PTS = randomPointInBox(BOX)
%   Generate a random point within the box BOX. The result is a 1-by-2 row
%   vector.
%
%   PTS = randomPointInBox(BOX, N)
%   Generates N points within the box. The result is a N-by-2 array.
%
%   BOX has the format:
%   BOX = [xmin xmax ymin ymax].
%
%   Example
%     % draw points within a box
%     box = [10 80 20 60];
%     pts =  randomPointInBox(box, 500);
%     figure(1); clf; hold on;
%     drawBox(box);
%     drawPoint(pts, '.');
%     axis('equal');
%     axis([0 100 0 100]);
%
%   See also
%     geom2d, points2d, boxes2d, randomPointInBox3d, randomPointInPolygon
%

% ------
% Author: David Legland
% e-mail: david.legland@inra.fr
% Created: 2007-10-10,    using Matlab 7.4.0.287 (R2007a)
% Copyright 2007 INRA - BIA PV Nantes - MIAJ Jouy-en-Josas.

if nargin < 2
    N = 1;
end

% extract box bounds
xmin = box(1);
xmax = box(2);
ymin = box(3);
ymax = box(4);

% compute size of box
dx = xmax - xmin;
dy = ymax - ymin;

% compute point coordinates
points = [rand(N, 1)*dx+xmin , rand(N, 1)*dy+ymin];
