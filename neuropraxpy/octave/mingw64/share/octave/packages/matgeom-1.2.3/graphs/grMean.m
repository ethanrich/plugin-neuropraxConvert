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

function varargout = grMean(varargin)
% Compute mean value from neighbour nodes.
%
%   LBL2 = grMean(EDGES, LBL1)
%   new label for each node of the graph is computed as the mean of the
%   values of neighbours and of old value.
%
%   Example
%   grMean
%
%   See also
%   grMedian, grDilate, grErode
%

% ------
% Author: David Legland
% e-mail: david.legland@inrae.fr
% Created: 2006-01-20
% Copyright 2006 INRA - CEPIA Nantes - MIAJ (Jouy-en-Josas).


if length(varargin) == 2
    edges   = varargin{1};
    values 	= varargin{2};
elseif length(varargin) == 3
    edges   = varargin{2};
    values  = varargin{3};
else
    error('Wrong number of arguments in "grMean"');
end
   

res = zeros(size(values));

uni = unique(edges(:));
for n = 1:length(uni)
    neigh = grAdjacentNodes(edges, uni(n));
    res(uni(n)) = mean(values([uni(n); neigh]));    
end

varargout{1} = res;
