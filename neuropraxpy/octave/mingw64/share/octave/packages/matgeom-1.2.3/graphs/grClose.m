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

function varargout = grClose(varargin)
%GRCLOSE Morphological closing on graph.
%
%   LBL2 = grClose(EDGES, LBL1)
%   First performs dilatation, then erosion.
%
%   Example
%   grOpen
%
%   See also
%
%
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2006-01-20
% Copyright 2006 INRA - CEPIA Nantes - MIAJ (Jouy-en-Josas).


if length(varargin) == 2
    edges   = varargin{1};
    lbl     = varargin{2};
elseif length(varargin) == 3
    edges   = varargin{2};
    lbl     = varargin{3};
else
    error('Wrong number of arguments in "grOpen"');
end

uni = unique(edges(:));

% performs dilation
lbl2 = zeros(size(lbl));
for n = 1:length(uni)
    neigh = grAdjacentNodes(edges, uni(n));
    lbl2(uni(n)) = max(lbl([uni(n); neigh]));    
end

% performs erosion
for n = 1:length(uni)
    neigh = grAdjacentNodes(edges, uni(n));
    lbl(uni(n)) = min(lbl2([uni(n); neigh]));    
end

varargout{1} = lbl;
