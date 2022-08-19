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

function T = createHomothecy(point, ratio)
%CREATEHOMOTHECY Create the the 3x3 matrix of an homothetic transform.
%
%   TRANS = createHomothecy(POINT, K);
%   POINT is the center of the homothecy, K is its factor.
%   TRANS is a 3-by-3 matrix representing the homothetic transform in
%   homogeneous coordinates.
%
%   Example:
%
%      p  = [0 0; 1 0; 0 1];
%      s  = [-0.5 0.4];
%      T  = createHomothecy (s, 1.5);
%      pT = transformPoint (p, T);
%      drawPolygon (p,'-b')
%      hold on;
%      drawPolygon (pT, '-r');
%      
%      drawEdge (p(:,1), p(:,2), pT(:,1), pT(:,2), ...
%                'color', 'k','linestyle','--')
%      hold off
%      axis tight equal
%

% ---------
% Author: David Legland
% e-mail: david.legland@inra.fr
% INRA - TPV URPOI - BIA IMASTE
% created the 20/01/2005.


%   HISTORY
%   22/04/2009: rename as createHomothecy
%   05/04/2017: improved code by JuanPi Carbajal <ajuanpi+dev@gmail.com>

point = point(:);
if length (point) > 2
    error('Only one point accepted.');
end
if length (ratio) > 1
    error('Only one ratio accepted.');
end

T        = diag ([ratio ratio 1]);
T(1:2,3) = point .* (1 - ratio);
