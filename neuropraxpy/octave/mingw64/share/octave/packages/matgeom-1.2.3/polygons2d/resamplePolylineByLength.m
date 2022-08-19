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

function poly2 = resamplePolylineByLength(poly, step)
%RESAMPLEPOLYLINEBYLENGTH Resample a polyline with a fixed sampling step.
%
%   RES = resamplePolyline(POLY, STEP)
%   Resample the input polyline POLY by distributing new vertices on the
%   original polyline such that the (curvilinear) distance between the new
%   vertices is approximately equal to STEP. 
%
%   Example
%     poly = [0 10;0 0;10 0; 10 10; 20 10;20 0];
%     figure; drawPolyline(poly, 'k');
%     poly2 = resamplePolylineByLength(poly, 4);
%     hold on; 
%     drawPolyline(poly2, 'm');
%     drawPoint(poly2, 'mo');
%     axis equal; axis([-10 30 -10 20]);
%     legend('Original polyline', 'Resampled polyline');
%
%   See also
%     polygons2d, drawPolyline, resamplePolygon
%

% ------
% Author: David Legland
% e-mail: david.legland@inra.fr
% Created: 2011-12-09,    using Matlab 7.9.0.529 (R2009b)
% Copyrightf 2011 INRA - Cepia Software Platform.

% parametrisation of the curve
s = parametrize(poly);

% compute the number of points for sampling the polygon
% (equal to the number of segments plus one)
Lmax = s(end);
n = round(Lmax / step) + 1;

% distribute N points equally spaced
pos = linspace(0, Lmax, n);

poly2 = zeros(n, size(poly, 2));
for i = 1:n
    % index of surrounding vertices before and after
    ind0 = find(s <= pos(i), 1, 'last');
    ind1 = find(s >= pos(i), 1, 'first');
    
    if ind0 == ind1
        % get position of a vertex in input polyline
        poly2(i, :) = poly(ind0, :);
        continue;
    end
    
    % position of surrounding vertices
    pt0 = poly(ind0, :);
    pt1 = poly(ind1, :);
    
    % weights associated to each neighbor
    l0 = pos(i) - s(ind0);
    l1 = s(ind1) - pos(i);
    
    % linear interpolation of neighbor positions
    if (l0 + l1) > Lmax * 1e-12
        poly2(i, :) = (pt0 * l1 + pt1 * l0) / (l0 + l1);
    else
        % if neighbors are too close, do not use interpolation
        poly2(i, :) = pt0;
    end
end
