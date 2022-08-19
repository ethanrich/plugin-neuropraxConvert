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

function alpha = normalizeAngle(alpha, varargin)
%NORMALIZEANGLE  Normalize an angle value within a 2*PI interval.
%
%   ALPHA2 = normalizeAngle(ALPHA);
%   ALPHA2 is the same as ALPHA modulo 2*PI and is positive.
%
%   ALPHA2 = normalizeAngle(ALPHA, CENTER);
%   Specifies the center of the angle interval.
%   If CENTER==0, the interval is [-pi ; +pi]
%   If CENTER==PI, the interval is [0 ; 2*pi] (default).
%
%   Example:
%   % normalization between 0 and 2*pi (default)
%   normalizeAngle(5*pi)
%   ans =
%       3.1416
%
%   % normalization between -pi and +pi
%   normalizeAngle(7*pi/2, 0)
%   ans =
%       -1.5708
%
%   See also
%   vectorAngle, lineAngle
%

% ------
% Author: David Legland
% e-mail: david.legland@nantes.inra.fr
% Created: 2008-03-10,    using Matlab 7.4.0.287 (R2007a)
% Copyright 2008 INRA - BIA PV Nantes - MIAJ Jouy-en-Josas.

% HISTORY
% 2010-03-31 rename as normalizeAngle, and add psb to specify interval
%   center

center = pi;
if ~isempty(varargin)
    center = varargin{1};
end

alpha = mod(alpha-center+pi, 2*pi) + center-pi;
