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

function varargout = transformPoint(varargin)
% Apply an affine transform to a point or a point set.
%
%   PT2 = transformPoint(PT1, TRANSFO);
%   Returns the result of the transformation TRANSFO applied to the point
%   PT1. PT1 has the form [xp yp], and TRANSFO is either a 2-by-2, a
%   2-by-3, or a 3-by-3 matrix, 
%
%   Format of TRANSFO can be one of :
%   [a b]   ,   [a b c] , or [a b c]
%   [d e]       [d e f]      [d e f]
%                            [0 0 1]
%
%   PT2 = transformPoint(PT1, TRANSFO);
%   Also works when PTA is a N-by-2 array representing point coordinates.
%   In this case, the result PT2 has the same size as PT1.
%
%   [X2, Y2] = transformPoint(X1, Y1, TRANS);
%   Also works when PX1 and PY1 are two arrays the same size. The function
%   transforms each pair (PX1, PY1), and returns the result in (X2, Y2),
%   which has the same size as (PX1 PY1). 
%
%
%   See also:
%     points2d, transforms2d, translation, rotation
%

%   ---------
%   author : David Legland 
%   INRA - TPV URPOI - BIA IMASTE
%   created the 06/04/2004.
%

%   HISTORY
%   25/04/2005 : support for 2D arrays of points (px, py, trans).

% parse input arguments
if length(varargin) == 2
    var = varargin{1};
    px = var(:,1);
    py = var(:,2);
    trans = varargin{2};
elseif length(varargin) == 3
    px = varargin{1};
    py = varargin{2};
    trans = varargin{3};
else
    error('wrong number of arguments in "transformPoint"');
end


% apply linear part of the transform
px2 = px * trans(1,1) + py * trans(1,2);
py2 = px * trans(2,1) + py * trans(2,2);

% add translation vector, if exist
if size(trans, 2) > 2
    px2 = px2 + trans(1,3);
    py2 = py2 + trans(2,3);
end

% format output arguments
if nargout < 2
    varargout{1} = [px2 py2];
elseif nargout
    varargout{1} = px2;
    varargout{2} = py2;
end
