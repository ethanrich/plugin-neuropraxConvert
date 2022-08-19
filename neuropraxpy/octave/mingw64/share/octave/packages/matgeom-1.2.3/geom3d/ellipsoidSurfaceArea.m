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

function s = ellipsoidSurfaceArea(elli)
%ELLIPSOIDSURFACEAREA  Approximated surface area of an ellipsoid.
%
%   S = ellipsoidSurfaceArea(ELLI)
%   Computes an approximation of the surface area of an ellipsoid. 
%   ELLI is a 1-by-9 row vector given by [XC YC ZC A B C THETA PHI PSI],
%   where (XC YC ZC) is the center, (A B C) is the length of each semi axis
%   and (THETA PHI PSI) representes the orientation.
%   If ELLI is a 1-by-3 row vector, it is assumed to contain only the
%   lengths of semi-axes.
%
%   This functions computes an approximation of the surface area, given by:
%   S = 4 * pi * ( (a^p * b^p + a^p * c^p + b^p * c^p) / 3) ^ (1/p)
%   with p = 1.6075. The resulting error should be less than 1.061%.
%
%   Example
%   ellipsoidSurfaceArea
%
%   See also
%   geom3d, ellipsePerimeter, oblateSurfaceArea, prolateSurfaceArea
%
%   References
%   * http://en.wikipedia.org/wiki/Ellipsoid
%   * http://mathworld.wolfram.com/Ellipsoid.html
%

% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2012-02-24,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2012 INRA - Cepia Software Platform.

%% Parse input argument

if size(elli, 2) == 9
    a = elli(:, 4);
    b = elli(:, 5);
    c = elli(:, 6);
    
elseif size(elli, 2) == 3
    a = elli(:, 1);
    b = elli(:, 2);
    c = elli(:, 3);    
end

p = 1.6075;
s = 4 * pi * ( (a.^p .* b.^p + a.^p .* c.^p + b.^p .* c.^p) / 3) .^ (1 / p);
