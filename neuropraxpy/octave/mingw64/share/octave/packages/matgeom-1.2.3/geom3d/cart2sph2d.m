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

function varargout = cart2sph2d(x, y, z)
%CART2SPH2D Convert cartesian coordinates to spherical coordinates in degrees.
%
%   [THETA PHI RHO] = cart2sph2d([X Y Z])
%   [THETA PHI RHO] = cart2sph2d(X, Y, Z)
%
%   The following convention is used:
%   THETA is the colatitude, in degrees, 0 for north pole, 180 degrees for
%   south pole, 90 degrees for points with z=0.
%   PHI is the azimuth, in degrees, defined as matlab cart2sph: angle from
%   Ox axis, counted counter-clockwise.
%   RHO is the distance of the point to the origin.
%   Discussion on choice for convention can be found at:
%   http://www.physics.oregonstate.edu/bridge/papers/spherical.pdf
%
%   Example:
%     cart2sph2d([1 0 0])
%     ans =
%       90   0   1
%
%     cart2sph2d([1 1 0])
%     ans =
%       90   45   1.4142
%
%     cart2sph2d([0 0 1])
%     ans =
%       0    0    1
%
%
%   See also:
%   angles3d, sph2cart2d, cart2sph, cart2sph2
%
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2011-06-29,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2011 INRA - Cepia Software Platform.

% if data are grouped, extract each coordinate
if nargin == 1
    y = x(:, 2);
    z = x(:, 3);
    x = x(:, 1);
end

% cartesian to spherical conversion
hxy     = hypot(x, y);
rho     = hypot(hxy, z);
theta   = 90 - atan2(z, hxy) * 180 / pi;
phi     = atan2(y, x) * 180 / pi;

% % convert to degrees and theta to colatitude
% theta   = 90 - rad2deg(theta);
% phi     = rad2deg(phi);

% format output
if nargout <= 1
    varargout{1} = [theta phi rho];
    
elseif nargout == 2
    varargout{1} = theta;
    varargout{2} = phi;
    
else
    varargout{1} = theta;
    varargout{2} = phi;
    varargout{3} = rho;
end
    
