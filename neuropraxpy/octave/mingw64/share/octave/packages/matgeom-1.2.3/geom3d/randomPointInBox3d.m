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

function points = randomPointInBox3d(box, N, varargin)
%RANDOMPOINTINBOX3D Generate random point(s) within a 3D box.
%
%   PTS = randomPointInBox3d(BOX)
%   Generate a random point within the 3D box BOX. The result is a 1-by-3
%   row vector.
%
%   PTS = randomPointInBox3d(BOX, N)
%   Generates N points within the box. The result is a N-by-3 array.
%
%   BOX has the format:
%   BOX = [XMIN XMAX YMIN YMAX ZMIN ZMAX].
%
%   Example
%     % draw points within a box
%     box = [10 40 20 60 30 50];
%     pts =  randomPointInBox3d(box, 500);
%     figure(1); hold on;
%     drawBox3d(box);
%     drawPoint3d(pts, '.');
%     axis('equal');
%     axis([0 100 0 100 0 100]);
%     view(3);
%
%   See also
%   points3d, boxes3d
%
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2011-06-27,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2011 INRA - Cepia Software Platform.

if nargin < 2
    N = 1;
end

% extract box bounds
xmin = box(1);
ymin = box(3);
zmin = box(5);

% compute size of box
dx = box(2) - xmin;
dy = box(4) - ymin;
dz = box(6) - zmin;

% compute point coordinates
points = [rand(N, 1)*dx+xmin , rand(N, 1)*dy+ymin , rand(N, 1)*dz+zmin];

