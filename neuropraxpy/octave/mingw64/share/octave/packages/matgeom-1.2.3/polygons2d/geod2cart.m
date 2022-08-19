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

function point = geod2cart(src, curve, normal)
%GEOD2CART Convert geodesic coordinates to cartesian coord.
%
%   PT2 = geod2cart(PT1, CURVE, NORMAL)
%   CURVE and NORMAL are both [N*2] array with the same length, and
%   represent positions of the curve, and normal to each point.
%   PT1 is the point to transform, in geodesic  coordinate (first coord is
%   distance from the curve start, and second coord is distance between
%   point and curve).
%
%   The function return the coordinate of PT1 in the same coordinate system
%   than for the curve.
%
%   TODO : add processing of points not projected on the curve.
%   -> use the closest end 
%
%   See also
%   polylines2d, cart2geod, curveLength
%
%   ---------
%   author : David Legland 
%   INRA - TPV URPOI - BIA IMASTE
%   created the 08/04/2004.
%

t = parametrize(curve);
N = size(src, 1);
ind = zeros(N, 1);
for i=1:N
    indices = find(t>=src(i,1));
    ind(i) = indices(1);
end

theta = lineAngle([zeros(N,1) zeros(N,1) normal(ind,:)]);
d = src(:,2);
point = [curve(ind,1)+d.*cos(theta), curve(ind,2)+d.*sin(theta)];
