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

function co = convexification(varargin)
%CONVEXIFICATION Compute the convexification of a polygon.
%
%   CO = convexification(H)
%   Creates convexification from support function. Support function is
%   supposed to be uniformly distributed over [0 2pi].
%
%   CO = convexification(POLYGON)
%   Computes support function of the polygon, then the corresponding
%   convexification.
%
%   CO = convexification(POLYGON, N)
%   Uses N points for convexification computation. Note that the number of
%   points of CO can be lower than N.
%   
%   CAUTION: The result will be valid only for convex polygons.
%
%   See also
%   polygons2d, supportFunction 
%
% ---------
% author: David Legland 
% created the 12/01/2005.
% Copyright 2010 INRA - Cepia Software Platform.
%

%   HISTORY
%   13/06/2007: clean up code

if ~isempty(varargin)>0
    var = varargin{1};
    if size(var, 2)==1
        h = var;
    else
        poly = var;
        N = 128;
        if length(varargin)>1
            N = varargin{2};
        end
        h = supportFunction(poly, N);
    end
else
    error('not enough input arguments');
end

N   = length(h);
u   = (0:2*pi/N:2*pi*(1-1/N))';
v   = [cos(u) sin(u)].*[h h];

i1  = 1:N;
i2  = [2:N 1];
i3  = [3:N 1 2];

circ = zeros(N, 4);
for i=1:N
    circ(i, 1:4) = createDirectedCircle(v(i1(i),:), v(i2(i),:), v(i3(i), :));
end

% remove non direct-oriented circles
circ = circ(circ(:,4)==0, :);

% keep only circles seen several times
dp = diff(circ(:,1:2));
dp = sum(dp.*dp, 2);
ind1 = [1; find(dp<1e-10)+1];
circ = circ(ind1, :);

% keep only one instance of each circle
dp = diff(circ(:,1:2));
dp = sum(dp.*dp, 2);
ind = [1; find(dp>1e-10)+1];
co = 2*circ(ind, 1:2);

% eventually remove the last point if it is the same as the first one
if distancePoints(co(1,:), co(end, :))<1e-10 && size(co, 1)>1
    co = co(1:end-1,:);
end


