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

function varargout = circumCenter(a, b, c)
%CIRCUMCENTER  Circumcenter of three points.
%
%   CC = circumCenter(P1, P2, P3)
%
%   Example
%     A = [10 10]; B = [30 10]; C = [10 20];
%     circumCenter(A, B, C)
%     ans =
%         20    15
%
%     % works also for multiple input points
%     circumCenter([A;A;A], [B;B;B], [C;C;C])
%     ans =
%         20    15
%         20    15
%         20    15
%
%
%   See also
%     points2d, circles2d, circumCircle, centroid
%

% ------
% Author: David Legland
% e-mail: david.legland@inra.fr
% Created: 2011-12-09,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2011 INRA - Cepia Software Platform.

% pre-compute some terms
ah = sum(a .^ 2, 2);
bh = sum(b .^ 2, 2);
ch = sum(c .^ 2, 2);

dab = a - b;
dbc = b - c;
dca = c - a;

% common denominator
D  = .5 ./ (a(:,1) .* dbc(:,2) + b(:,1) .* dca(:,2) + c(:,1) .* dab(:,2));

% center coordinates
xc =  (ah .* dbc(:,2) + bh .* dca(:,2) + ch .* dab(:,2) ) .* D;
yc = -(ah .* dbc(:,1) + bh .* dca(:,1) + ch .* dab(:,1) ) .* D;

if nargout <= 1
    varargout = {[xc yc]};
else
    varargout = {xc, yc};
end
