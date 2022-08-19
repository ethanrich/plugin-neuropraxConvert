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

function varargout = cart2sph2(varargin)
%CART2SPH2 Convert cartesian coordinates to spherical coordinates.
%
%   [THETA PHI RHO] = cart2sph2([X Y Z])
%   [THETA PHI RHO] = cart2sph2(X, Y, Z)
%
%   The following convention is used:
%   THETA is the colatitude, in radians, 0 for north pole, +pi for south
%   pole, pi/2 for points with z=0. 
%   PHI is the azimuth, in radians, defined as matlab cart2sph: angle from
%   Ox axis, counted counter-clockwise.
%   RHO is the distance of the point to the origin.
%   Discussion on choice for convention can be found at:
%   http://www.physics.oregonstate.edu/bridge/papers/spherical.pdf
%
%   Example:
%   cart2sph2([1 0 0])  returns [pi/2 0 1];
%   cart2sph2([1 1 0])  returns [pi/2 pi/4 sqrt(2)];
%   cart2sph2([0 0 1])  returns [0 0 1];
%
%   See also:
%   angles3d, sph2cart2, cart2sph, cart2sph2d
%

%   ---------
%   author : David Legland 
%   INRA - TPV URPOI - BIA IMASTE
%   created the 18/02/2005.
%

%   HISTORY
%   02/11/2006: update doc, and manage case RHO is empty
%   03/11/2006: change convention for angle : uses order [THETA PHI RHO]
%   27/06/2007: manage 2 output arguments

if length(varargin)==1
    var = varargin{1};
elseif length(varargin)==3
    var = [varargin{1} varargin{2} varargin{3}];
end

if size(var, 2)==2
    var(:,3)=1;
end

[p, t, r] = cart2sph(var(:,1), var(:,2), var(:,3));

if nargout == 1 || nargout == 0
    varargout{1} = [pi/2-t p r];
elseif nargout==2
    varargout{1} = pi/2-t;
    varargout{2} = p;
else
    varargout{1} = pi/2-t;
    varargout{2} = p;
    varargout{3} = r;
end
    
