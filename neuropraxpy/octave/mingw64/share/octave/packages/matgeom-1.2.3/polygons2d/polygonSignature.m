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

function [res, thetaList] = polygonSignature(poly, varargin)
%POLYGONSIGNATURE Polar signature of a polygon (polar distance to origin).
%
%   DISTS = polygonSignature(POLY, THETALIST)
%   Computes the polar signature of a polygon, for a set of angles in
%   degrees. If a ray at a given angle does not intersect the polygon, the
%   corresponding distance value is set to NaN.
%
%   DISTS = polygonSignature(POLY, N)
%   When N is a scalar, uses N angles equally distributed between 0 and 360
%   degrees.
%   
%   [DISTS, THETA] = polygonSignature(...)
%   Also returns the angle set for which the signature was computed.
%
%   Example
%   polygonSignature
%
%   See also
%     polygons2d, signatureToPolygon, intersectRayPolygon
%

% ------
% Author: David Legland
% e-mail: david.legland@nantes.inra.fr
% Created: 2013-03-14,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2013 INRA - Cepia Software Platform.

% default angle list
thetaList = 0:359;

% get user-defined angle list
if ~isempty(varargin)
    var = varargin{1};
    if isscalar(var)
        thetaList = linspace(0, 360, var+1);
        thetaList(end) = [];
    else
        thetaList = var;
    end
end

% also extract reference point if needed
center = [0 0];
if nargin > 2
    center = varargin{2};
end

% allocate memory
nTheta = length(thetaList);
res = NaN * ones(nTheta, 1);

% iterate on angles
for i = 1:length(thetaList)
    theta = deg2rad(thetaList(i));
    ray = [center cos(theta) sin(theta)];

    ptInt = intersectRayPolygon(ray, poly);
    if ~isempty(ptInt)
        res(i) = distancePoints(center, ptInt(1,:));
    end
end
