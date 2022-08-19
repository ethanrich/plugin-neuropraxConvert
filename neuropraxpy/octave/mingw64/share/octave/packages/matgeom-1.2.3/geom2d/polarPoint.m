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

function point = polarPoint(varargin)
%POLARPOINT Create a point from polar coordinates (rho + theta).
%
%   POINT = polarPoint(RHO, THETA);
%   Creates a point using polar coordinate. THETA is angle with horizontal
%   (counted counter-clockwise, and in radians), and RHO is the distance to
%   origin.
%
%   POINT = polarPoint(THETA)
%   Specify angle, radius RHO is assumed to be 1.
%
%   POINT = polarPoint(POINT, RHO, THETA)
%   POINT = polarPoint(X0, Y0, RHO, THETA)
%   Adds the coordinate of the point to the coordinate of the specified
%   point. For example, creating a point with :
%     P = polarPoint([10 20], 30, 2*pi);
%   will give a result of [40 20].
%   
%
%   See Also:
%   points2d
%
%   ---------
%
%   author : David Legland 
%   INRA - TPV URPOI - BIA IMASTE
%   created the 03/05/2004
%


% default values
x0 = 0; y0=0;
rho = 1;
theta =0;

% process input parameters
if length(varargin)==1
    theta = varargin{1};
elseif length(varargin)==2
    rho = varargin{1};
    theta = varargin{2};
elseif length(varargin)==3
    var = varargin{1};
    x0 = var(:,1);
    y0 = var(:,2);
    rho = varargin{2};
    theta = varargin{3};
elseif length(varargin)==4
    x0 = varargin{1};
    y0 = varargin{2};
    rho = varargin{3};
    theta = varargin{4};
end


point = [x0 + rho.*cos(theta) , y0+rho.*sin(theta)];
