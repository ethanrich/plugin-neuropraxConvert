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

function pt = steinerPoint(varargin)
%STEINERPOINT Compute steiner point (weighted centroid) of a polygon.
%
%   PT = steinerPoint(POINTS);
%   PT = steinerPoint(PTX, PTY);
%   Computes steiner point of a polygon defined by POINTS. POINTS is a
%   [N*2] array of double.
%
%   The steiner point is computed the same way as the polygon centroid,
%   except that a weight depending on the angle is given to each vertex.
%
%   See also:
%   polygons2d, polygonArea, polygonCentroid, drawPolygon
%
%   ---------
%   author : David Legland 
%   INRA - TPV URPOI - BIA IMASTE
%   created the 11/11/2004.
%


if nargin==1
    var = varargin{1};
    px = var(:,1);
    py = var(:,2);
elseif nargin==2
    px = varargin{1};
    py = varargin{2};
end

% Algorithme P. Bourke
sx = 0;
sy = 0;
N = length(px);
for i=1:N-1
    sx = sx + (px(i)+px(i+1))*(px(i)*py(i+1) - px(i+1)*py(i));
    sy = sy + (py(i)+py(i+1))*(px(i)*py(i+1) - px(i+1)*py(i));
end
sx = sx + (px(N)+px(1))*(px(N)*py(1) - px(1)*py(N));
sy = sy + (py(N)+py(1))*(px(N)*py(1) - px(1)*py(N));

pt = [sx sy]/6/polygonArea(px, py);
