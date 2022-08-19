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

function edge = createEdge3d(varargin)
%CREATEEDGE3D Create an edge between two 3D points, or from a 3D line.
%
%   E = createEdge3d(P1, P2)
%   Creates the 3D edge joining the two points P1 and P2.
%
%   E = createEdge3d(LIN)
%   Creates the 3D edge with same origin and same direction vector as the
%   3D line LIN.
%
%   Example
%     p1 = [1 1 1];
%     p2 = [3 4 5];
%     edge = createEdge3d(p1, p2);
%     edgeLength3d(edge)
%     ans =
%         5.3852
%   
%   See also
%     edges3d, drawEdge3d, clipEdge3d, edgelength3d
 
% ------
% Author: David Legland
% e-mail: david.legland@inra.fr
% Created: 2018-08-29,    using Matlab 9.4.0.813654 (R2018a)
% Copyright 2018 INRA - Cepia Software Platform.


if nargin == 1
    % Only one input parameter. Assumes it corresponds to a 3D line with
    % 6 params.
    var = varargin{1};
    
    if size(var, 2) ~= 6
        error('single input must have 6 columns');
    end
    
    % converts 3D line into 3D edge
    edge = zeros(size(var));
    edge(:, 1:3) = var(:, 1:3);
    edge(:, 4:6) = edge(:, 1:3) + var(:,4:6);
    
elseif nargin == 2    
    % 2 input parameters correspond to two 3D points
    
    % extract the two arguments
    v1 = varargin{1};
    v2 = varargin{2};
    
    if size(v1, 2) ~= 3 || size(v2, 2) ~= 3
        error('Input points must be arrays with 3 columns');
    end
    
    % first input parameter is first point, and second input is the
    % second point. Allows multiple points.
    n1 = size(v1, 1);
    n2 = size(v2, 1);
    if n1 == n2
        edge = [v1 v2];
    elseif n1 == 1 || n2 == 1
        edge = [repmat(v1, n2, 1) repmat(v2, n1, 1)];
    end
    
else
    error('Wrong number of arguments in ''%s''', mfilename);
end
