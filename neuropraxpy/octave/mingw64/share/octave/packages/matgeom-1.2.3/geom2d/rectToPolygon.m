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

function [tx, ty] = rectToPolygon(rect)
%RECTTOPOLYGON Convert a rectangle into a polygon (set of vertices).
%
%   POLY = rectToPolygon(RECT);
%   Converts rectangle given as [X0 Y0 W H] or [X0 Y0 W H THETA] into a
%   4-by-2 array double, containing coordinate of rectangle vertices.
%   X0 and Y0 are the coordinates of the "lower left" vertex (before
%   applying rotation), W and H are the width and the height of the
%   rectangle, and THETA is the rotation angle around the first vertex, in
%   degrees.
%
%   See also:
%   orientedBoxToPolygon, ellipseToPolygon, drawRect, drawPolygon
%
%

% ---------
% Author: David Legland
% e-mail: david.legland@nantes.inra.fr
% INRA - TPV URPOI - BIA IMASTE
% created the 06/04/2005.
%

% HISTORY

% extract rectangle parameters
theta = 0;
x0  = rect(1);
y0  = rect(2);
w   = rect(3);
h   = rect(4);
if length(rect) > 4
    theta = rect(5);
end

% precompute angular quantities
cot = cosd(theta);
sit = sind(theta);

% compute vertex coordinates
tx = zeros(4, 1);
ty = zeros(4, 1);
tx(1) = x0;
ty(1) = y0;
tx(2) = x0 + w * cot;
ty(2) = y0 + w * sit;
tx(3) = x0 + w * cot - h * sit;
ty(3) = y0 + w * sit + h * cot;
tx(4) = x0 - h * sit;
ty(4) = y0 + h * cot;

% format output
if nargout <= 1
    tx = [tx ty];
end
