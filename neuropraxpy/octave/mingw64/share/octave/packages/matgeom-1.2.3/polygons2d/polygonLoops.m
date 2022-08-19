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

function loops = polygonLoops(poly, varargin)
%POLYGONLOOPS Divide a possibly self-intersecting polygon into a set of simple loops.
%
%   LOOPS = polygonLoops(POLYGON);
%   POLYGON is a polygone defined by a series of vertices,
%   LOOPS is a cell array of polygons, containing the same vertices of the
%   original polygon, but no loop self-intersect, and no couple of loops
%   intersect each other.
%
%   Example:
%       poly = [0 0;0 10;20 10;20 20;10 20;10 0];
%       loops = polygonLoops(poly);
%       figure(1); hold on;
%       drawPolygon(loops);
%       polygonArea(loops)
%
%   See also
%   polygons2d, polygonSelfIntersections
%

% ------
% Author: David Legland
% e-mail: david.legland@nantes.inra.fr
% Created: 2009-06-15,    using Matlab 7.7.0.471 (R2008b)
% Copyright 2009 INRA - Cepia Software Platform.


% tolerance for detecting two vertices as equal
tol = 1e-14;

% parse optional arguments
while length(varargin) > 1
    pname = varargin{1};
    if ~ischar(pname)
        error('Expect optional arguments as name-value pairs');
    end
    
    if strcmpi(pname, 'tolerance')
        tol = varargin{2};
    else
        error(['Unknown parameter name: ' pname]);
    end
    varargin(1:2) = [];
end


%% Initialisations

% compute intersections
[inters, pos1, pos2] = polygonSelfIntersections(poly, 'tolerance', tol);

% case of a polygon without self-intersection
if isempty(inters)
    loops = {poly};
    return;
end

% array for storing loops
loops = cell(0, 1);

% sort intersection points with respect to their position on the polygon
[positions, order] = sortrows([pos1 pos2 ; pos2 pos1]);
inters = [inters ; inters];
inters = inters(order, :);


%% First loop

% initialize the beginning of the loop
pos0 = 0;
loop = polygonSubcurve(poly, pos0, positions(1, 1));
loop(end, :) = inters(1,:);
vertex = inters(1,:);

% prepare iteration on positions
pos = positions(1, 2);
positions(1, :) = [];
inters(1,:) = [];

while true
    % index of next intersection point
    ind = find(positions(:,1) > pos, 1, 'first');
    
    % if not index is found, the current loop is complete
    if isempty(ind)
        break;
    end

    % compute the portion of curve between the two intersection points
    portion = polygonSubcurve(poly, pos, positions(ind, 1));
    
    % ensure extremities have been computed only once
    portion(1, :) = vertex;
    vertex = inters(ind, :);
    portion(end, :) = vertex;
    
    % add the current portion of curve
    loop = [loop; portion]; %#ok<AGROW>
    
    % update current position on the polygon
    pos = positions(ind, 2);
    
    % remove processed intersection
    positions(ind, :) = [];
    inters(ind,:) = [];
end

% append the last portion of curve
loop = [loop ; polygonSubcurve(poly, pos, pos0)];

% remove redundant vertices
loop(sum(loop(1:end-1,:) == loop(2:end,:) ,2)==2, :) = [];
if sum(diff(loop([1 end], :)) == 0) == 2
    loop(end, :) = [];
end

% add current loop to the list of loops
loops{1} = loop;


%% Other loops

Nl = 1;
while ~isempty(positions)

    % initialize the next loop
    loop    = [];
    pos0    = positions(1, 2);
    pos     = positions(1, 2);
    vertex  = inters(1,:);
    
    while true
        % index of next intersection point
        ind = find(positions(:,1) > pos, 1, 'first');

        % compute the portion of curve between the two intersection points
        portion = polygonSubcurve(poly, pos, positions(ind, 1));
        
        % ensure extremities have been computed only once
        portion(1, :) = vertex;
        vertex = inters(ind, :);
        portion(end, :) = vertex;
        
        % append the current portion of curve
        loop = [loop ; portion]; %#ok<AGROW>

        % update current position on the polygon
        pos = positions(ind, 2);

        % remove processed intersection
        positions(ind, :) = [];
        inters(ind,:) = [];

        % if not found, current loop is processed
        if pos == pos0
            break;
        end
    end

    % remove redundant vertices
    loop(sum(loop(1:end-1,:) == loop(2:end,:) ,2)==2, :) = []; %#ok<AGROW>
    if sum(diff(loop([1 end], :))==0) == 2
        loop(end, :) = []; 
    end

    % add current loop to the list of loops
    Nl = Nl + 1;
    loops{Nl} = loop;
end
