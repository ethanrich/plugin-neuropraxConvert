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

function [poly, keepInds] = simplifyPolygon(poly, varargin)
%SIMPLIFYPOLYGON  Douglas-Peucker simplification of a polygon.
%
%   POLY2 = simplifyPolygon(POLY, TOL)
%   Simplifies the input polygon using the Douglas-Peucker algorithm. 
%
%   Example
%     elli = [20 30 40 20 30];
%     poly = ellipseToPolygon(elli, 500);
%     poly2 = simplifyPolygon(poly, 1); % use a tolerance equal to 1.
%     figure; hold on;
%     drawEllipse(elli);
%     drawPoint(poly2, 'mo');
%
%   See also
%   polygons2d, smoothPolygon, simplifyPolyline, resamplePolygon
%
%   References
%   http://en.wikipedia.org/wiki/Ramer-Douglas-Peucker_algorithm
%

% ------
% Author: David Legland
% e-mail: david.legland@inra.fr
% Created: 2013-03-14,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2013 INRA - Cepia Software Platform.

% call the simplifyPolyline function by ensuring the last vertex is present
poly = poly([1:end 1], :);
[poly, keepInds] = simplifyPolyline(poly, varargin{:});

% remove last vertex
poly(end, :) = [];
keepInds(end) = [];
