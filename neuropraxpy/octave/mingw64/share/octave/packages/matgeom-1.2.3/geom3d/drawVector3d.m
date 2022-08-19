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

function varargout = drawVector3d(pos, vect, varargin)
%DRAWVECTOR3D Draw vector at a given position.
%
%   drawVector3d(POS, VECT)
%   Draws the vector VECT starting at the position POS. Both VECT and POS
%   are N-by-3 arrays.
%
%   drawVector3d(..., PNAME, PVALUE)
%   Specifies additional optional parameters that will be given to the
%   quiver3 function.
%
%   Example
%     figure; hold on;
%     drawVector3d([2 3 4], [1 0 0]);
%     drawVector3d([2 3 4], [0 1 0]);
%     drawVector3d([2 3 4], [0 0 1]);
%     view(3);
%
%   See also
%   vectors3d, quiver3
%

% ------
% Author: David Legland
% e-mail: david.legland@nantes.inra.fr
% Created: 2011-12-19,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2011 INRA - Cepia Software Platform.

if isAxisHandle(pos)
    hAx = pos;
    pos = vect;
    vect = varargin{1};
    varargin(1) = [];
else
    hAx = gca;
end

h = quiver3(hAx, pos(:, 1), pos(:, 2), pos(:, 3), ...
    vect(:, 1), vect(:, 2), vect(:, 3), 0, varargin{:});

% format output
if nargout > 0
    varargout{1} = h;
end
