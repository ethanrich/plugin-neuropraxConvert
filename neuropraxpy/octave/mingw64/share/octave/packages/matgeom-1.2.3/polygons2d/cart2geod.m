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

function point = cart2geod(src, curve)
%CART2GEOD Convert cartesian coordinates to geodesic coord.
%
%   PT2 = cart2geod(PT1, CURVE)
%   PT1 is the point to transform, in Cartesian coordinates (same system
%   used for the curve).
%   CURVE is a N-by-2 array which represents coordinates of curve vertices.
%
%   The function first compute the projection of PT1 on the curve. Then,
%   the first geodesic coordinate is the length of the curve to the
%   projected point, and the second geodesic coordinate is the 
%   distance between PT1 and it projection.
%
%
%   TODO : add processing of points not projected on the curve.
%   -> use the closest end 
%
%   See also
%   polylines2d, geod2cart, curveLength
%

% ---------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% created the 08/04/2004.
% Copyright 2010 INRA - Cepia Software Platform.

%   HISTORY
%   15/02/2007 replace minDistance by minDistancePoints


% parametrization approximation
t = parametrize(curve);

% compute distance between each src point and the curve
[dist, ind] = minDistancePoints(src, curve);

% convert to 'geodesic' coordinate
point = [t(ind) dist];

% Old version:
% for i=1:size(pt1, 1)
%     [dist, ind] = minDistance(src(i,:), curve);
%     point(i,:) = [t(ind) dist];
% end
