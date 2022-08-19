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

function box = mergeBoxes(box1, box2)
%MERGEBOXES Merge two boxes, by computing their greatest extent.
%
%   BOX = mergeBoxes(BOX1, BOX2);
%
%   Example
%   box1 = [5 20 5 30];
%   box2 = [0 15 0 15];
%   mergeBoxes(box1, box2)
%   ans = 
%       0 20 0 30
%
%
%   See also
%   boxes2d, drawBox, intersectBoxes
%
%
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2010-07-26,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2010 INRA - Cepia Software Platform.

% unify sizes of data
if size(box1,1) == 1
    box1 = repmat(box1, size(box2,1), 1);
elseif size(box2, 1) == 1
    box2 = repmat(box2, size(box1,1), 1);
elseif size(box1,1) ~= size(box2,1)
    error('Bad size for inputs');
end

% compute extreme coords
mini = min(box1(:,[1 3]), box2(:,[1 3]));
maxi = max(box1(:,[2 4]), box2(:,[2 4]));

% concatenate result into a new box structure
box = [mini(:,1) maxi(:,1) mini(:,2) maxi(:,2)];
