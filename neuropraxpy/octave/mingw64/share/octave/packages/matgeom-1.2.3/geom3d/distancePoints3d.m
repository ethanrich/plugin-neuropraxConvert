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

function dist = distancePoints3d(p1, p2, varargin)
%DISTANCEPOINTS3D Compute euclidean distance between pairs of 3D Points.
%
%   D = distancePoints3d(P1, P2) return distance between points P1 and
%   P2, given as [X Y Z].
%   
%   If P1 and P2 are two arrays of points, result is a N1*N2 array
%   containing distance between each point of P1 and each point of P2. 
%
%
%   D = distancePoints3d(P1, P2, NOR)
%   with NOR being 1, 2, or Inf, corresponfing to the norm used. Default is
%   2 (euclidean norm). 1 correspond to manhattan (or taxi driver) distance
%   and Inf to maximum difference in each coordinate.
%
%
%   See also:
%   points3d, minDistancePoints, distancePoints
%
%   ---------
%
%   author : David Legland 
%   INRA - TPV URPOI - BIA IMASTE
%   created the 18/02/2005.
%

%   HISTORY
%   21/02/2005: add different norms
%   28/08/2007: deprecate

norm = 2;
if length(varargin)==1
    norm = varargin{1};
end

% compute difference of coordinate for each pair of points
ptsDiff = bsxfun(@minus, p2, p1);

% Return dist based on the type of measurement requested
switch(norm)
    case 1
        dist = sum(abs(ptsDiff),2);
    case 2
        dist = vectorNorm3d(ptsDiff);
    case Inf
        dist = max(abs(ptsDiff), [], 2);
    otherwise
        dist = power(sum(power(ptsDiff, norm),2), 1/norm);
end
