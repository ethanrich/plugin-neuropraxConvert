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

function len = edgeLength(varargin)
%EDGELENGTH Return length of an edge.
%
%   L = edgeLength(EDGE);  
%   Returns the length of an edge, with parametric representation:
%   [x1 y1 x2 y2].
%
%   The function also works for several edges, in this case input is a
%   N-by-4 array, containing parametric representation of each edge, and
%   output is a N-by-1 array containing length of each edge.
%
%   See also:
%   edges2d, edgeAngle
%
%   ---------
%
%   author : David Legland 
%   INRA - TPV URPOI - BIA IMASTE
%   created the 19/02/2004
%

%   HISTORY
%   15/04/2005 changes definition for edge, uses [x1 y1 x2 y2] instead of
%       [x0 y0 dx dy].

if nargin == 1
    % input is an edge [X1 Y1 X2 Y2]
    edge = varargin{1};
    len = hypot(edge(:,3)-edge(:,1), edge(:,4)-edge(:,2));
    
elseif nargin == 2
    % input are two points [X1 Y1] and [X2 Y2]
    p1 = varargin{1};
    p2 = varargin{2};
    len = hypot(p2(:,1)-p1(:,1), p2(:,2)-p1(:,2));
    
end
