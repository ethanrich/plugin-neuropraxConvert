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

function poly = signatureToPolygon(signature, varargin)
%SIGNATURETOPOLYGON Reconstruct a polygon from its polar signature.
%
%   POLY = signatureToPolygon(SIGNATURE)
%   POLY = signatureToPolygon(SIGNATURE, ANGLES)
%
%   Example
%   signatureToPolygon
%
%   See also
%     polygonSignature
 
% ------
% Author: David Legland
% e-mail: david.legland@nantes.inra.fr
% Created: 2015-04-28,    using Matlab 8.4.0.150421 (R2014b)
% Copyright 2015 INRA - Cepia Software Platform.

nAngles = length(signature);

% compute default signature
angleList = linspace(0, 360, nAngles+1);
angleList(end) = [];

if ~isempty(varargin)
    angleList = varargin{1};
    if length(angleList) ~= nAngles
        msg = 'signature and angle list must have same length (here %d and %d)';
        error(sprintf(msg, nAngles, length(angleList))); %#ok<SPERR>
    end
end

poly = zeros(nAngles, 2);
for iAngle = 1:nAngles
    angle = angleList(iAngle);
    
    poly(iAngle, :) = signature(iAngle) * [cosd(angle) sind(angle)];
end
