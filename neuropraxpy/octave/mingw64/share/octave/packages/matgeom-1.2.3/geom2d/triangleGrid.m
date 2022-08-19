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

function varargout = triangleGrid(bounds, origin, size, varargin)
%TRIANGLEGRID Generate triangular grid of points in the plane.
%
%   usage
%   PTS = triangleGrid(BOUNDS, ORIGIN, SIZE)
%   generate points, lying in the window defined by BOUNDS, given in form
%   [xmin ymin xmax ymax], starting from origin with a constant step equal
%   to size. 
%   SIZE is constant and is equals to the length of the sides of each
%   triangles. 
%
%   TODO: add possibility to use rotated grid
%
%   ---------
%
%   author : David Legland 
%   INRA - TPV URPOI - BIA IMASTE
%   created the 06/08/2005.
%

dx = size(1);
dy = size(1)*sqrt(3);

% consider two square grids with different centers
pts1 = squareGrid(bounds, origin, [dx dy], varargin{:});
pts2 = squareGrid(bounds, origin + [dx dy]/2, [dx dy], varargin{:});

% gather points
pts = [pts1;pts2];


% process output
if nargout>0
    varargout{1} = pts;
end
