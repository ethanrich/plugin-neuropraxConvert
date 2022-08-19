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

function S = prolateSurfaceArea(elli, varargin)
%PROLATESURFACEAREA  Approximated surface area of a prolate ellipsoid.
%
%   S = prolateSurfaceArea(R1,R2)
%
%   Example
%   prolateSurfaceArea
%
%   See also
%   geom3d, ellipsoidSurfaceArea, oblateSurfaceArea
%

% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2015-07-03,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2015 INRA - Cepia Software Platform.

%% Parse input argument

if size(elli, 2) == 7
    R1 = elli(:, 4);
    R2 = elli(:, 5);
    
elseif size(elli, 2) == 1 && ~isempty(varargin)
    R1 = elli(:, 1);
    R2 = varargin{1};
end

assert(R1 > R2, 'first radius must be larger than second radius');

% surface theorique d'un ellipsoide prolate 
% cf http://fr.wikipedia.org/wiki/Ellipso%C3%AFde_de_r%C3%A9volution
e = sqrt(R1.^2 - R2.^2) ./ R1;
S = 2 * pi * R2.^2 + 2 * pi * R1 .* R2 .* asin(e) ./ e;
