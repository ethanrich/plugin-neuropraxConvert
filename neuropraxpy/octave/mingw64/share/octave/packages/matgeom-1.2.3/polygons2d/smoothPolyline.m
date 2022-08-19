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

function res = smoothPolyline(poly, M)
%SMOOTHPOLYLINE Smooth a polyline using local averaging.
%
%   RES = smoothPolygon(POLY, M)
%   POLY contains the polyline vertices, and M is the size of smoothing
%   (given as the length of the convolution window).
%   Extremities of the polyline are smoothed with reduced window (last and
%   first vertices are kept identical, second and penultimate vertices are
%   smoothed with 3 values, etc.).
%
%   Example
%     img = imread('circles.png');
%     img = imfill(img, 'holes');
%     contours = bwboundaries(img');
%     poly = contours{1}(201:500,:);
%     figure; drawPolyline(poly, 'b'); hold on;
%     poly2 = smoothPolyline(poly, 21);
%     drawPolygon(poly2, 'm');
%
%   See also
%     polygons2d, smoothPolygon, simplifyPolyline, resamplePolyline
 
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2015-02-17,    using Matlab 8.4.0.150421 (R2014b)
% Copyright 2015 INRA - Cepia Software Platform.

% compute the number of elements before and after
M1 = floor((M - 1) / 2);
M2 = ceil((M - 1) / 2);

% create convolution vector
v2 = ones(M, 1) / M;

% apply filtering on central part of the polyline
res(:,1) = conv(poly(:,1), v2, 'same');
res(:,2) = conv(poly(:,2), v2, 'same');

% need to recompute the extremities
for i = 1:M1
    i2 = 2 * i - 1;
    res(i, 1) = mean(poly(1:i2, 1));
    res(i, 2) = mean(poly(1:i2, 2));
end
for i = 1:M2
    i2 = 2 * i - 1;
    res(end - i + 1, 1) = mean(poly(end-i2+1:end, 1));
    res(end - i + 1, 2) = mean(poly(end-i2+1:end, 2));
end
