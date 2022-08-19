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

function varargout = cart2cyl(varargin)
%CART2CYL  Convert cartesian to cylindrical coordinates.
%
%   CYL = cart2cyl(POINT)
%   convert the 3D cartesian coordinates of points POINT (given by [X Y Z]
%   where X, Y, Z have the same size) into cylindrical coordinates CYL,
%   given by [THETA R Z]. 
%   THETA is the arctangent of the ratio Y/X (between 0 and 2*PI)
%   R     can be computed using sqrt(X^2+Y^2)
%   Z     keeps the same value.
%   The size of THETA, and R is the same as the size of X, Y and Z.
%
%   CYL = cart2cyl(X, Y, Z)
%   provides coordinates as 3 different parameters
%
%   Example
%   cart2cyl([-1 0 2])
%   gives : 4.7124    1.0000     2.0000
%
%   See also agles3d, cart2pol, cart2sph2
%
%
% ------
% Author: David Legland
% e-mail: david.legland@jouy.inra.fr
% Created: 2006-03-23
% Copyright 2006 INRA - CEPIA Nantes - MIAJ (Jouy-en-Josas).

% process input parameters
if length(varargin)==1
    var = varargin{1};
    x = var(:,1);
    y = var(:,2);
    z = var(:,3);
elseif length(varargin)==3
    x = varargin{1};
    y = varargin{2};
    z = varargin{3};
end

% convert coordinates
dim = size(x);
theta = reshape(mod(atan2(y(:), x(:))+2*pi, 2*pi), dim);
r = reshape(sqrt(x(:).*x(:) + y(:).*y(:)), dim);

% process output parameters
if nargout==0 ||nargout==1
    if length(dim)>2 || dim(2)>1
        varargout{1} = {theta r z};
    else
        varargout{1} = [theta r z];
    end
elseif nargout==3
    varargout{1} = theta;
    varargout{2} = r;
    varargout{3} = z;
end
