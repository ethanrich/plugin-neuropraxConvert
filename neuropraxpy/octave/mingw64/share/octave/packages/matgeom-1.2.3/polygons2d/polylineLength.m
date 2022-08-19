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

function len = polylineLength(poly, varargin)
%POLYLINELENGTH Return length of a polyline given as a list of points.
%
%   L = polylineLength(POLY);
%   POLY should be a N-by-D array, where N is the number of points and D is
%   the dimension of the points.
%
%   L = polylineLength(..., TYPE);
%   Specifies if the last point is connected to the first one. TYPE can be
%   either 'closed' or 'open'.
%
%   L = polylineLength(POLY, POS);
%   Compute the length of the polyline between its origin and the position
%   given by POS. POS should be between 0 and N-1, where N is the number of
%   points of the polyline.
%
%
%   Example:
%   % Compute the perimeter of a circle with radius 1
%   polylineLength(circleAsPolygon([0 0 1], 500), 'closed')
%   ans = 
%       6.2831
%
%   See also:
%   polygons2d, polylineCentroid, polygonLength
%
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2009-04-30,    using Matlab 7.7.0.471 (R2008b)
% Copyright 2009 INRA - Cepia Software Platform.


%   HISTORY
%   2006-05-22 manage any dimension for points, closed and open curves, 
%       and update doc accordingly.
%   2009-04-30 rename as polylineLength
%   2011-03-31 add control for empty polylines

% check there are enough points
if size(poly, 1) < 2
    len = 0;
    return;
end

% check whether the curve is closed or not (default is open)
closed = false;
if ~isempty(varargin)
    var = varargin{end};
    if ischar(var)
        if strcmpi(var, 'closed')
            closed = true;
        end
        varargin = varargin(1:end-1);
    end
end

% if the length is computed between 2 positions, compute only for a
% subcurve
if ~isempty(varargin)
    % values for 1 input argument
    t0 = 0;
    t1 = varargin{1};
    
    % values for 2 input arguments
    if length(varargin)>1
        t0 = varargin{1};
        t1 = varargin{2};
    end
    
    % extract a portion of the polyline
    poly = polylineSubcurve(poly, t0, t1);
end

% compute lengths of each line segment, and sum up
if closed
    len = sum(sqrt(sum(diff(poly([1:end 1],:)).^2, 2)));
else
    len = sum(sqrt(sum(diff(poly).^2, 2)));
end
