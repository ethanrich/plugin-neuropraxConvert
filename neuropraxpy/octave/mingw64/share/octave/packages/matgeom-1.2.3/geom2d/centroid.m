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

function center = centroid(varargin)
%CENTROID Compute centroid (center of mass) of a set of points.
%
%   PTS = centroid(POINTS)
%   PTS = centroid(PTX, PTY)
%   Computes the ND-dimensional centroid of a set of points. 
%   POINTS is an array with as many rows as the number of points, and as
%   many columns as the number of dimensions. 
%   PTX and PTY are two column vectors containing coordinates of the
%   2-dimensional points.
%   The result PTS is a row vector with Nd columns.
%
%   PTS = centroid(POINTS, MASS)
%   PTS = centroid(PTX, PTY, MASS)
%   Computes center of mass of POINTS, weighted by coefficient MASS.
%   POINTS is a Np-by-Nd array, MASS is Np-by-1 array, and PTX and PTY are
%   also both Np-by-1 arrays.
%
%   Example:
%   pts = [2 2;6 1;6 5;2 4];
%   centroid(pts)
%   ans =
%        4     3
%
%   See Also:
%   points2d, polygonCentroid
%   
% ---------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% created the 07/04/2003.
% Copyright 2010 INRA - Cepia Software Platform.
%

%   HISTORY
%   2009-06-22 support for 3D points
%   2010-04-12 fix bug in weighted centroid
%   2010-12-06 update doc


%% extract input arguments

% use empty mass by default
mass = [];

if nargin==1
    % give only array of points
    pts = varargin{1};
    
elseif nargin==2
    % either POINTS+MASS or PX+PY
    var = varargin{1};
    if size(var, 2)>1
        % arguments are POINTS, and MASS
        pts = var;
        mass = varargin{2};
    else
        % arguments are PX and PY
        pts = [var varargin{2}];
    end
    
elseif nargin==3
    % arguments are PX, PY, and MASS
    pts = [varargin{1} varargin{2}];
    mass = varargin{3};
end

%% compute centroid

if isempty(mass)
    % no weight
    center = mean(pts);
    
else
    % format mass to have sum equal to 1, and column format
    mass = mass(:)/sum(mass(:));
    
    % compute weighted centroid
    center = sum(bsxfun(@times, pts, mass), 1);
    % equivalent to:
    % center = sum(pts .* mass(:, ones(1, size(pts, 2))));
end
