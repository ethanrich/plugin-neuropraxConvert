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

function res = smoothPolygon(poly, M)
%SMOOTHPOLYGON Smooth a polygon using local averaging.
%
%   RES = smoothPolygon(POLY, M)
%   POLY contains the polygon vertices, and M is the size of smoothing
%   (given as the length of the convolution window).
%
%
%   Example
%     img = imread('circles.png');
%     img = imfill(img, 'holes');
%     contours = bwboundaries(img');
%     contour = contours{1};
%     imshow(img); hold on; drawPolygon(contour, 'b');
%     contourf = smoothPolygon(contour, 11);
%     drawPolygon(contourf, 'm');
%
%   See also
%     polygons2d, smoothPolyline, simplifyPolygon, resamplePolygon
 
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2015-02-17,    using Matlab 8.4.0.150421 (R2014b)
% Copyright 2015 INRA - Cepia Software Platform.

% compute the number of elements before and after
M1 = floor((M - 1) / 2);
M2 = ceil((M - 1) / 2);

% repeat beginning and end of contour
poly2 = [poly(end-M1+1:end, :) ; poly ; poly(1:M2,:)];

% create convolution vector
v2 = ones(M, 1) / M;

% apply contour filtering
res(:,1) = conv(poly2(:,1), v2, 'same');
res(:,2) = conv(poly2(:,2), v2, 'same');

% keep the interesting part
res = res(M1+1:end-M2, :);
