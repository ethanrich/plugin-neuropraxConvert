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

function trans = createScaling(varargin)
%CREATESCALING Create the 3*3 matrix of a scaling in 2 dimensions.
%
%   TRANS = createScaling(SX, SY);
%   return the matrix corresponding to scaling by SX and SY in the 2
%   main directions.
%   The returned matrix has the form:
%   [SX  0  0]
%   [0  SY  0]
%   [0   0  1]
%
%   TRANS = createScaling(SX);
%   Assume SX and SY are equals.
%
%   TRANS = createScaling(CENTER, ...);
%   Specifies the center of the scaling transform. The argument CENTER
%   should be a 1-by-2 array representing coordinates of center.
%
%   See also:
%   transforms2d, transformPoint, createTranslation, createRotation

%
%   ---------
%   author : David Legland 
%   INRA - TPV URPOI - BIA IMASTE
%   created the 07/04/2004.


%   HISTORY
%   04/01/2007: rename as scaling
%   22/04/2009: rename as createScaling

% defined default arguments
sx = 1;
sy = 1;
cx = 0;
cy = 0;

% process input arguments
if nargin == 1
    % the argument is either the scaling factor in both direction,
    % or a 1x2 array containing scaling factor in each direction
    var = varargin{1};
    sx = var(1);
    sy = var(1);
    if length(var)>1
        sy = var(2);
    end
elseif nargin == 2
    % the 2 arguments are the scaling factors in each dimension
    sx = varargin{1};
    sy = varargin{2};
elseif nargin == 3
    % first argument is center, 2nd and 3d are scaling factors
    center = varargin{1};
    cx = center(1);
    cy = center(2);
    sx = varargin{2};
    sy = varargin{3};
end

% concatenate results in a 3-by-3 matrix
trans = [sx 0 cx*(1-sx); 0 sy cy*(1-sy); 0 0 1];

