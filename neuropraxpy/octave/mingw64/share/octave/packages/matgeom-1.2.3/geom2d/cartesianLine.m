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

function line = cartesianLine(varargin)
%CARTESIANLINE Create a straight line from cartesian equation coefficients.
%
%   L = cartesianLine(A, B, C);
%   Create a line verifying the Cartesian equation:
%   A*x + B*x + C = 0;
%
%   See also:
%   lines2d, createLine
%
%   ---------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% created the 25/05/2004.
% Copyright 2010 INRA - Cepia Software Platform.


if length(varargin)==1
    var = varargin{1};
    a = var(:,1);
    b = var(:,2);
    c = var(:,3);
elseif length(varargin)==3
    a = varargin{1};
    b = varargin{2};
    c = varargin{3};
end

% normalisation factor
d = a.*a + b.*b;

x0 = -a.*c./d;
y0 = -b.*c./d;
theta = atan2(-a, b);
dx = cos(theta);
dy = sin(theta);

line = [x0 y0 dx dy];
