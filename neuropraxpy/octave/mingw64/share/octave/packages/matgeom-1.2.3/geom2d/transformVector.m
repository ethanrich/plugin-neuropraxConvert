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

function varargout = transformVector(varargin)
%TRANSFORMVECTOR Transform a vector with an affine transform.
%
%   VECT2 = transformVector(VECT1, TRANS);
%   where VECT1 has the form [xv yv], and TRANS is a [2*2], [2*3] or [3*3]
%   matrix, returns the vector transformed with affine transform TRANS.
%
%   Format of TRANS can be one of :
%   [a b]   ,   [a b c] , or [a b c]
%   [d e]       [d e f]      [d e f]
%                            [0 0 1]
%
%   VECT2 = transformVector(VECT1, TRANS);
%   Also works when PTA is a [N*2] array of double. In this case, VECT2 has
%   the same size as VECT1.
%
%   [vx2 vy2] = transformVector(vx1, vy1, TRANS);
%   Also works when vx1 and vy1 are arrays the same size. The function
%   transform each couple of (vx1, vy1), and return the result in 
%   (vx2, vy2), which is the same size as (vx1 vy1).
%
%
%   See also:
%   vectors2d, transforms2d, rotateVector, transformPoint
%
%   ---------
%
%   author : David Legland 
%   INRA - TPV URPOI - BIA IMASTE
%   created the 12/03/2007.
%

%   HISTORY


if length(varargin)==2
    var = varargin{1};
    vx = var(:,1);
    vy = var(:,2);
    trans = varargin{2};
elseif length(varargin)==3
    vx = varargin{1};
    vy = varargin{2};
    trans = varargin{3};
else
    error('wrong number of arguments in "transformVector"');
end


% compute new position of vector
vx2 = vx*trans(1,1) + vy*trans(1,2);
vy2 = vx*trans(2,1) + vy*trans(2,2);

% format output
if nargout==0 || nargout==1
    varargout{1} = [vx2 vy2];
elseif nargout==2
    varargout{1} = vx2;
    varargout{2} = vy2;
end
