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

function poly = boxToPolygon(box)
%BOXTOPOLYGON Convert a bounding box to a square polygon.
%
%   poly = boxToPolygon(box)
%   Utility function that convert box data in [XMIN XMAX YMIN YMAX] format
%   to polygon data corresponding to the box boundary. The resulting POLY
%   is a 4-by-2 array.
%
%
%   Example
%     box = [ 10 50 20 40];
%     poly = boxToPolygon(box)
%     poly = 
%         10    20
%         50    20
%         50    40
%         10    40
%
%   See also
%     boxes2d, polygons2d, boxToRect
 
% ------
% Author: David Legland
% e-mail: david.legland@nantes.inra.fr
% Created: 2017-09-10,    using Matlab 8.6.0.267246 (R2015b)
% Copyright 2017 INRA - Cepia Software Platform.

% extreme coordinates
xmin = box(1);  
xmax = box(2);
ymin = box(3);  
ymax = box(4);

% convert to polygon
poly = [...
    xmin ymin; ...
    xmax ymin; ...
    xmax ymax; ...
    xmin ymax];
