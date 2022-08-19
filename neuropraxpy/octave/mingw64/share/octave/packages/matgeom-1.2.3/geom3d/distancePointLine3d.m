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

function d = distancePointLine3d(point, line)
%DISTANCEPOINTLINE3D Euclidean distance between 3D point and line.
%
%   D = distancePointLine3d(POINT, LINE);
%   Returns the distance between point POINT and the line LINE, given as:
%   POINT : [x0 y0 z0]
%   LINE  : [x0 y0 z0 dx dy dz]
%   D     : (positive) scalar  
%   
%   See also:
%   lines3d, isPointOnLine3d, distancePointEdge3d, projPointOnLine3d,
%   
%
%   References
%   http://mathworld.wolfram.com/Point-LineDistance3-Dimensional.html

%   ---------
%   author : David Legland 
%   INRA - TPV URPOI - BIA IMASTE
%   created the 23/05/2005.
%

%   HISTORY
%   15/01/2007 unify size of input data
%   31/01/2007 typo in data formatting, and replace norm by vecnorm3d
%   12/12/2010 changed to bsxfun implementation - Sven Holcombe

% cf. Mathworld (distance point line 3d)  for formula
d = bsxfun(@rdivide, vectorNorm3d( ...
        crossProduct3d(line(:,4:6), bsxfun(@minus, line(:,1:3), point)) ), ...
        vectorNorm3d(line(:,4:6)));
