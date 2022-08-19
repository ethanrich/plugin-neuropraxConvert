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

function poly = removeMultipleVertices(poly, varargin)
%REMOVEMULTIPLEVERTICES Remove multiple vertices of a polygon or polyline.
%
%   POLY2 = removeMultipleVertices(POLY, EPS)
%   Remove adjacent vertices that are closer than the distance EPS to each
%   other and merge them to a unique vertex.
%
%   POLY2 = removeMultipleVertices(POLY, EPS, CLOSED)
%   If CLOSED is true, also check if first and last vertices need to be
%   merged. If not specified, CLOSED is false.
%
%   Example
%     poly = [10 10; 20 10;20 10;20 20;10 20; 10 10];
%     poly2 = removeMultipleVertices(poly, true);
%     size(poly2, 1)
%     ans = 
%         4
%
%   See also
%   polygons2d, mergeClosePoints

% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2013-10-04,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2013 INRA - Cepia Software Platform.

% default values
eps = 1e-14;
closed = false;

% process input options
while ~isempty(varargin)
    var = varargin{1};
    if islogical(var)
        closed = var;
    elseif isnumeric(var)
        eps = var;
    else
        error('MatGeom:removeMultipleVertices:IllegalArgument',...
            'Can not interpret optional argument');
    end
    varargin(1) = [];
end

% distance between adjacent vertices
dist = sqrt(sum((poly(2:end,:) - poly(1:end-1,:)).^2, 2));
multi = dist < eps;

% process extremities
if closed
    dist = sqrt(sum((poly(end,:) - poly(1,:)).^2, 2));
    multi = [multi ; dist < eps];
else
    multi = [multi ; false];
end

% remove multiple vertices
poly(multi, :) = [];

