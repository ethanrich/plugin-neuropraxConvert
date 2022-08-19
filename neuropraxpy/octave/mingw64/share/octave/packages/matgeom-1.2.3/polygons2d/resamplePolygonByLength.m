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

function poly2 = resamplePolygonByLength(poly, step)
%RESAMPLEPOLYGONBYLENGTH  Resample a polygon with a fixed sampling step.
%
%   RES = resamplePolygon(POLY, STEP)
%   Resample the input polygon POLY by distributing new vertices on the
%   original polygon such that the (curvilinear) distance between the new
%   vertices is approximately equal to STEP. 
%
%   Example
%     % creates a polygon from an ellipse
%     elli = [20 30 40 20 30];
%     poly = ellipseToPolygon(elli, 500);
%     figure; drawPolygon(poly, 'b');
%     poly2 = resamplePolygonByLength(poly, 10);
%     hold on; 
%     drawPolygon(poly2, 'm');
%     drawPoint(poly2, 'mo');
%     axis equal; axis([-20 60 0 60]);
%     legend('Original polygon', 'Resampled polygon', 'Location', 'NorthWest');
%
%   See also
%     polygons2d, simplifyPolygon, resamplePolygon,
%     resamplePolylineByLength
%

% ------
% Author: David Legland
% e-mail: david.legland@inra.fr
% Created: 2011-12-09,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2011 INRA - Cepia Software Platform.

poly2 = resamplePolylineByLength(poly([1:end 1],:), step);
poly2(end, :) = [];
