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

function polygons = splitPolygons3d(polygon)
%SPLITPOLYGONS3D Convert a NaN separated polygon list to a cell array of polygons.
%
%   Same function as splitpolygons for planar case, included in private
%   directory of geom3d to avoid missing file problems.
%

% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2007-10-12,    using Matlab 7.4.0.287 (R2007a)
% Copyright 2007 INRA - BIA PV Nantes - MIAJ Jouy-en-Josas.

if iscell(polygon)
    % case of a cell array
    polygons = polygon;
    
elseif sum(isnan(polygon(:))) == 0
    % single polygon -> no break
    polygons = {polygon};
    
else
    % find indices of NaN couples
    inds = find(sum(isnan(polygon), 2) > 0);
    
    % number of polygons
    N = length(inds) + 1;
    polygons = cell(N, 1);

    % iterate over NaN-separated regions to create new polygon
    inds = [0; inds; size(polygon, 1)+1];
    for i = 1:N
        polygons{i} = polygon((inds(i)+1):(inds(i+1)-1), :);    
    end
end
