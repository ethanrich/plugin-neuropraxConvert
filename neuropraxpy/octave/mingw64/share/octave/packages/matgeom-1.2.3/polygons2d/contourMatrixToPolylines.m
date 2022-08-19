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

function polys = contourMatrixToPolylines(C)
%CONTOURMATRIXTOPOLYLINES Converts a contour matrix array into a polyline set.
%
%   POLYS = contourMatrixToPolylines(C)
%   Converts the contour matrix array, as given as the result of the
%   contourc function, into a set of polylines.
%
%   Example
%     img = imread('circles.png');
%     C = contourc(img, 1);
%     polys = contourMatrixToPolylines(C);
%     imshow(img); hold on;
%     drawPolyline(polys, 'Color', 'r', 'LineWidth', 2);
%
%   See also
%     polygons2d, contour, contourc

% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2013-08-22,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2013 INRA - Cepia Software Platform.

% size of the contour matrix array
nCoords = size(C, 2);

% first, compute the number of contours
nContours = 0;
offset = 1;
while offset < nCoords
    nContours = nContours + 1;
    offset = offset + C(2, offset) + 1;
end

% extract each contour as a polygon or polyline
polys = cell(nContours, 1);
offset = 1;
for iContour = 1:nContours
    nv = C(2, offset);
    polys{iContour} = C(:, offset + (1:nv))';
    offset = offset + nv + 1;
end
