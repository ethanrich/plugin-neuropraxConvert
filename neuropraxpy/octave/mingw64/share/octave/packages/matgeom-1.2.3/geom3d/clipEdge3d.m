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

function clipped = clipEdge3d(edge, box)
%CLIPEDGE3D Clip a 3D edge with a cuboid box.
%
%   CLIPPED = clipEdge3d(EDGE, BOX)
%
%   Example
%   clipEdge3d
%
%   See also
%     lines3d, edges3d, clipLine3d
 
% ------
% Author: David Legland
% e-mail: david.legland@inra.fr
% Created: 2018-04-12,    using Matlab 9.3.0.713579 (R2017b)
% Copyright 2018 INRA - Cepia Software Platform.

% compute supporting line of edge
line = [edge(:, 1:3) edge(:,4:6)-edge(:,1:3)];

% clip supporting line
clipped = clipLine3d(line, box);

% for each clipped line, check that extremities are contained in edge
nEdges = size(edge, 1);
for i = 1:nEdges
    % if supporting line does not intersect the box, the edge is totally
    % clipped.
    if isnan(clipped(i,1))
        continue;
    end
    
    % position of intersection points on the current supporting line
    pos1 = linePosition3d(clipped(i,1:3), line(i,:));
    pos2 = linePosition3d(clipped(i,4:6), line(i,:));
    
    if pos1 > 1 || pos2 < 0
        % case of an edge totally clipped
        clipped(i,:) = NaN;
    elseif pos1 > 0 && pos2 < 1
        % case of an edge already contained within the bounding box
        % -> nothin to do...
        continue;
    else
        % otherwise, need to adjust bounds of the clipped edge
        pos1 = max(pos1, 0);
        pos2 = min(pos2, 1);
        p1 = line(i,1:3) + pos1 * line(i,4:6);
        p2 = line(i,1:3) + pos2 * line(i,4:6);
        clipped(i,:) = [p1 p2];
    end
end
