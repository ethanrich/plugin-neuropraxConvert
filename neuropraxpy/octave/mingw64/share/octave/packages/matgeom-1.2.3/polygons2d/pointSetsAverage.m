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

function average = pointSetsAverage(pointSets, varargin)
%POINTSETSAVERAGE Compute the average of several point sets.
%
%   AVERAGESET = pointSetsAverage(POINTSETS)
%   POINTSETS is a cell array containing several liste of points with the
%   same number of points. The function compute the average coordinate of
%   each vertex, and return the resulting average point set.
%
%   Example
%   pointSetsAverage
%
%   See also
%   
%
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2011-04-01,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2011 INRA - Cepia Software Platform.

% check input
if ~iscell(pointSets)
    error('First argument must be a cell array');
end

% number of sets
nSets   = length(pointSets);

% get reference size of coordinates array
set1    = pointSets{1};
refSize = size(set1);

% allocate memory for result
average = zeros(refSize);

% iterate on point sets
for i = 1:nSets
    % get current point set, and check its size
    set = pointSets{i};
    if sum(size(set) ~= refSize) > 0
        error('All point sets must have the same size');
    end
    
    % cumulative sum of coordinates
    average = average + set;
end

% normalize by the number of sets
average = average / nSets;
